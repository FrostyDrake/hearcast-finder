package com.hearcast.hearcast_finder

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothStatusCodes
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.LinkedHashMap
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val scanResults = LinkedHashMap<String, Map<String, Any?>>()
    private var activeScanCallback: ScanCallback? = null
    private var activeScanResult: MethodChannel.Result? = null
    private var scanTimeoutRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCANNER_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkCapabilities" -> result.success(checkCapabilities())
                "requestScanPermissions" -> requestScanPermissions(result)
                "startScan" -> startScan(result)
                "stopScan" -> {
                    finishActiveScan()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        finishActiveScan()
        super.onDestroy()
    }

    private fun checkCapabilities(): Map<String, Any> {
        val adapter = bluetoothAdapter()

        return mapOf(
            "androidVersion" to Build.VERSION.SDK_INT,
            "isAndroid13OrNewer" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU),
            "hasBluetooth" to packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE),
            "isBluetoothEnabled" to isBluetoothEnabled(adapter),
            "hasBluetoothScanPermission" to hasPermission(Manifest.permission.BLUETOOTH_SCAN),
            "hasBluetoothConnectPermission" to hasPermission(Manifest.permission.BLUETOOTH_CONNECT),
            "hasLocationPermission" to hasPermission(Manifest.permission.ACCESS_FINE_LOCATION),
            "isLeAudioSupported" to isLeAudioSupported(adapter),
            "isLeAudioBroadcastSourceSupported" to isLeAudioBroadcastSourceSupported(adapter),
        )
    }

    private fun requestScanPermissions(result: MethodChannel.Result) {
        val missingPermissions = requiredScanPermissions().filterNot(::hasPermission)
        if (missingPermissions.isEmpty()) {
            result.success(null)
            return
        }

        requestPermissions(missingPermissions.toTypedArray(), REQUEST_SCAN_PERMISSIONS)
        result.success(null)
    }

    private fun startScan(result: MethodChannel.Result) {
        if (activeScanResult != null) {
            result.error("scan_active", "A Bluetooth scan is already running.", null)
            return
        }

        val missingPermissions = requiredScanPermissions().filterNot(::hasPermission)
        if (missingPermissions.isNotEmpty()) {
            result.error("missing_permissions", "Bluetooth permissions are missing.", missingPermissions)
            return
        }

        val adapter = bluetoothAdapter()
        if (!isBluetoothEnabled(adapter)) {
            result.error("bluetooth_disabled", "Bluetooth is turned off.", null)
            return
        }

        val scanner = adapter?.bluetoothLeScanner
        if (scanner == null) {
            result.error("scanner_unavailable", "Bluetooth LE scanner is unavailable.", null)
            return
        }

        scanResults.clear()
        activeScanResult = result
        activeScanCallback = createScanCallback()

        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setReportDelay(0)
            .build()

        try {
            scanner.startScan(null, settings, activeScanCallback)
        } catch (error: SecurityException) {
            activeScanCallback = null
            activeScanResult = null
            result.error("scan_security_error", error.message, null)
            return
        }

        val timeout = Runnable { finishActiveScan() }
        scanTimeoutRunnable = timeout
        mainHandler.postDelayed(timeout, SCAN_DURATION_MS)
    }

    private fun createScanCallback(): ScanCallback {
        return object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                recordScanResult(result)
            }

            override fun onBatchScanResults(results: MutableList<ScanResult>) {
                results.forEach(::recordScanResult)
            }

            override fun onScanFailed(errorCode: Int) {
                val pendingResult = activeScanResult
                clearActiveScanState()
                pendingResult?.error("scan_failed", "Bluetooth scan failed with code $errorCode.", errorCode)
            }
        }
    }

    private fun recordScanResult(result: ScanResult) {
        val recordBytes = result.scanRecord?.bytes ?: ByteArray(0)
        val address = try {
            result.device.address ?: ""
        } catch (error: SecurityException) {
            ""
        }
        val serviceUuids = result.scanRecord?.serviceUuids
            ?.map { it.uuid.toString() }
            ?: emptyList()
        val deviceName = result.scanRecord?.deviceName ?: safeDeviceName(result)
        val fallbackName = if (serviceUuids.isEmpty()) "BLE audio candidate" else "Nearby BLE signal"
        val key = address.ifBlank { recordBytes.toHexString() }.ifBlank { result.timestampNanos.toString() }

        scanResults[key] = mapOf(
            "id" to key,
            "broadcastName" to (deviceName ?: fallbackName),
            "deviceName" to deviceName,
            "rssi" to result.rssi,
            "rawAdvertisementHex" to recordBytes.toHexString(),
            "deviceAddress" to address,
            "serviceUuids" to serviceUuids,
            "detectedAt" to System.currentTimeMillis(),
        )
    }

    private fun finishActiveScan() {
        val callback = activeScanCallback
        if (callback != null) {
            try {
                bluetoothAdapter()?.bluetoothLeScanner?.stopScan(callback)
            } catch (error: SecurityException) {
                // Return any results already captured.
            }
        }

        val pendingResult = activeScanResult
        clearActiveScanState()
        pendingResult?.success(scanResults.values.toList())
    }

    private fun clearActiveScanState() {
        scanTimeoutRunnable?.let(mainHandler::removeCallbacks)
        scanTimeoutRunnable = null
        activeScanCallback = null
        activeScanResult = null
    }

    private fun requiredScanPermissions(): List<String> {
        return listOf(
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.ACCESS_FINE_LOCATION,
        )
    }

    private fun hasPermission(permission: String): Boolean {
        return checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun bluetoothAdapter(): BluetoothAdapter? {
        return getSystemService(BluetoothManager::class.java)?.adapter
    }

    private fun isBluetoothEnabled(adapter: BluetoothAdapter?): Boolean {
        return try {
            adapter?.isEnabled == true
        } catch (error: SecurityException) {
            false
        }
    }

    private fun isLeAudioSupported(adapter: BluetoothAdapter?): Boolean {
        if (adapter == null || !hasPermission(Manifest.permission.BLUETOOTH_CONNECT)) {
            return false
        }

        return try {
            adapter.isLeAudioSupported == BluetoothStatusCodes.FEATURE_SUPPORTED
        } catch (error: RuntimeException) {
            false
        }
    }

    private fun isLeAudioBroadcastSourceSupported(adapter: BluetoothAdapter?): Boolean {
        if (adapter == null || !hasPermission(Manifest.permission.BLUETOOTH_CONNECT)) {
            return false
        }

        return try {
            adapter.isLeAudioBroadcastSourceSupported == BluetoothStatusCodes.FEATURE_SUPPORTED
        } catch (error: RuntimeException) {
            false
        }
    }

    private fun safeDeviceName(result: ScanResult): String? {
        return try {
            result.device.name
        } catch (error: SecurityException) {
            null
        }
    }

    private fun ByteArray.toHexString(): String {
        return joinToString(separator = "") { byte ->
            String.format(Locale.US, "%02X", byte)
        }
    }

    companion object {
        private const val SCANNER_CHANNEL = "hearcast/auracast_scanner"
        private const val REQUEST_SCAN_PERMISSIONS = 4107
        private const val SCAN_DURATION_MS = 8_000L
    }
}

# Native Scan Setup

Denne omgang (18. august 2026) tilfojer Android-platformen og den foerste native Bluetooth scan bridge.

## Tilfojet Nu

- Android platform genereret med package name `com.hearcast.hearcast_finder`.
- `minSdk` sat til 33.
- Bluetooth LE feature og scan/connect/location permissions.
- Kotlin MethodChannel:
  - `hearcast/auracast_scanner`
- Native methods:
  - `checkCapabilities`
  - `requestScanPermissions`
  - `startScan`
  - `stopScan`
- Dart service og Scan UI.

## Skal Testes Paa Telefon

1. Installer appen paa en Android 13+ telefon.
2. Aabn Scan-fanen.
3. Tryk Permissions.
4. Start scan med Bluetooth slaaet til.
5. Test ogsaa fejltilfaelde med Bluetooth slaaet fra.

## Kendte Begraensninger

- Auracast-detektion er endnu kun baseret paa BLE scan data.
- Scan-resultater gemmes ikke endnu.
- Scan evidence kan nu indsendes lokalt som pending verification request.
- Admin verification kan gennemgaas lokalt i Admin-fanen.

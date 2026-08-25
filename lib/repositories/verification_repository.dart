import '../models/auracast_location.dart';
import '../models/scan_result.dart';
import '../models/verification_request.dart';

class VerificationRepository {
  const VerificationRepository();

  VerificationRequest createLocalRequest({
    required ScanResult scanResult,
    required AuracastLocation location,
  }) {
    return VerificationRequest.local(
      scanResult: scanResult,
      location: location,
    );
  }
}

import 'dart:async';

/// How long the UI waits for the server to acknowledge a write before it
/// stops showing a spinner and says something.
const hcWriteTimeout = Duration(seconds: 12);

/// The message shown when a write is not acknowledged in time.
///
/// It deliberately does not say "failed". Cloud Firestore queues an
/// unacknowledged write locally and replays it when it can reach the server
/// again, so the submission is not lost - it is just not confirmed yet.
const hcWriteTimeoutMessage =
    'The server did not confirm within 12 seconds. Your submission is saved '
    'on this device and will be sent when the app can reach Firebase again.';

extension HcWriteTimeout<T> on Future<T> {
  /// Caps a Firestore write so the interface can never sit on a spinner
  /// indefinitely.
  ///
  /// A write future only completes once the server acknowledges it, so with
  /// no connection - or, as happened on a real device here, an auth token
  /// that cannot be refreshed - it simply never completes and the button
  /// spins forever with nothing said to the user.
  Future<T> withWriteTimeout() {
    return timeout(
      hcWriteTimeout,
      onTimeout: () => throw TimeoutException(hcWriteTimeoutMessage),
    );
  }
}

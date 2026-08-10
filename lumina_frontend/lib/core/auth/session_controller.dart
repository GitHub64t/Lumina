import 'dart:async';

enum SessionExpiredReason {
  missingRefreshToken,
  rejectedRefreshToken,
  invalidRefreshResponse,
}

class SessionExpiredEvent {
  const SessionExpiredEvent(this.reason);

  final SessionExpiredReason reason;
}

class SessionController {
  final _controller = StreamController<SessionExpiredEvent>.broadcast();

  Stream<SessionExpiredEvent> get sessionExpired => _controller.stream;

  void notifySessionExpired(SessionExpiredReason reason) {
    if (!_controller.isClosed) {
      _controller.add(SessionExpiredEvent(reason));
    }
  }

  Future<void> dispose() => _controller.close();
}

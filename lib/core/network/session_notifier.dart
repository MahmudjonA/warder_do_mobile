import 'dart:async';

/// Interceptor 401 ko'rganda butun ilovaga "sessiya tugadi" deb xabar beradi.
///
/// Nima uchun alohida klass: `AuthInterceptor` `AuthBloc` haqida bilmasligi
/// kerak (data qatlami presentation'ga bog'lanmaydi). Shu broadcast orqali
/// bog'liqlik teskari yo'nalishga o'tadi.
class SessionNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}

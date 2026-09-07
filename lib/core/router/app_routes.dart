/// Barcha marshrut manzillari. String'larni ekranlarga sochib yubormaslik
/// uchun bitta joyda turadi.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String today = '/today';
  static const String profile = '/profile';
  static const String habitPicker = '/habits/new';
  static const String organizer = '/habits/reorder';
  static const String habitEdit = '/habits/edit';
  static const String groups = '/groups';
  static const String groupTemplates = '/groups/templates';
  static const String groupEdit = '/groups/edit';

  /// Kirmagan foydalanuvchi kira oladigan ekranlar.
  static const Set<String> publicRoutes = {welcome, login, register};
}

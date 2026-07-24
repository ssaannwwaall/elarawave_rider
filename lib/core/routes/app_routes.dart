abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';

  /// Stub route only — the real Order Detail screen is not built yet
  /// (docs/PROJECT.md "Planned, not built yet"). Expects an `id` param.
  static const String orderDetail = '/order-detail/:id';

  static String orderDetailPath(int id) => '/order-detail/$id';
}

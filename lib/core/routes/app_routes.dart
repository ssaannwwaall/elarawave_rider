abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String customers = '/customers';
  static const String customerCreate = '/customers/create';
  static const String orderCreate = '/orders/create';

  /// Stub route only — the real Order Detail screen is not built yet
  /// (docs/PROJECT.md "Planned, not built yet"). Expects an `id` param.
  static const String orderDetail = '/order-detail/:id';

  static String orderDetailPath(int id) => '/order-detail/$id';
}

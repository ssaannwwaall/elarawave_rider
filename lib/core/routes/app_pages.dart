import 'package:get/get.dart';
import '../../presentation/home/home_binding.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/login/login_binding.dart';
import '../../presentation/login/login_screen.dart';
import '../../presentation/order_detail/order_detail_screen.dart';
import '../../presentation/splash/splash_binding.dart';
import '../../presentation/splash/splash_screen.dart';
import 'app_routes.dart';
import 'water_wipe_route.dart';

class AppPages {
  AppPages._();

  static final WaterWipeTransition _waterWipe = WaterWipeTransition();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      customTransition: _waterWipe,
      transitionDuration: const Duration(milliseconds: 650),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      customTransition: _waterWipe,
      transitionDuration: const Duration(milliseconds: 650),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailScreen(),
    ),
  ];
}

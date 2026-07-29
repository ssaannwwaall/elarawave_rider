import 'package:get/get.dart';
import '../../presentation/home/home_binding.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/login/login_binding.dart';
import '../../presentation/login/login_screen.dart';
import '../../presentation/customers/customer_list_binding.dart';
import '../../presentation/customers/customer_list_screen.dart';
import '../../presentation/customers/customer_create_binding.dart';
import '../../presentation/customers/customer_create_screen.dart';
import '../../presentation/order_create/order_create_binding.dart';
import '../../presentation/order_create/order_create_screen.dart';
import '../../presentation/order_detail/order_detail_binding.dart';
import '../../presentation/order_detail/order_detail_screen.dart';
import '../../presentation/profile/profile_binding.dart';
import '../../presentation/profile/profile_screen.dart';
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
      binding: OrderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      customTransition: _waterWipe,
      transitionDuration: const Duration(milliseconds: 650),
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomerListScreen(),
      binding: CustomerListBinding(),
      customTransition: _waterWipe,
      transitionDuration: const Duration(milliseconds: 650),
    ),
    GetPage(
      name: AppRoutes.customerCreate,
      page: () => const CustomerCreateScreen(),
      binding: CustomerCreateBinding(),
    ),
    GetPage(
      name: AppRoutes.orderCreate,
      page: () => const OrderCreateScreen(),
      binding: OrderCreateBinding(),
    ),
  ];
}

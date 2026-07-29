import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/motion_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const ElaraWaveRiderApp());
}

class ElaraWaveRiderApp extends StatelessWidget {
  const ElaraWaveRiderApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ElaraWave Rider',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        // Honour the platform's "reduce motion" accessibility setting —
        // every water widget checks MotionConfig, so this one sync call
        // disables all of them at once. See docs/ANIMATION.md.
        motion.syncWithPlatform(MediaQuery.disableAnimationsOf(context));
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

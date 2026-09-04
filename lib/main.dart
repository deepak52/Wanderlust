import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'helper/route.dart';
import 'binding/splash_binding.dart';
import 'helper/single_app.dart';
import 'helper/http_service.dart';
import 'helper/core/base/app_base_service.dart';
import 'helper/core/environment/env.dart';
import 'helper/enum.dart';
import 'service/lock_service.dart';
import 'controller/lock_controller.dart';
import 'widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment BEFORE initializing Firebase (matching Agro-Prod)
  AppEnvironment.setEnv(Environment.PROD);
  AppEnvironment.setClient(AppClient.wanderlust);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize singleton classes (matching Agro-Prod AppInit)
  Get.put(MyApplication());
  try {
    await Get.find<MyApplication>().setUpSharedPreference();
    await Get.find<MyApplication>().setVersionNumber();
  } catch (e) {
    debugPrint('Preferences startup initialization error: $e');
  }
  Get.put(HttpService());
  Get.put(AppBaseService());
  Get.put(LockService());
  Get.put(LockController(), permanent: true);

  // Set device type and screen orientation (matching Agro-Prod AppInit)
  _setDeviceType();
  _setUpScreenOrientation();

  runApp(const MyApp());
}

void _setDeviceType() {
  final MediaQueryData data = MediaQueryData.fromView(
    WidgetsBinding.instance.platformDispatcher.views.single,
  );
  AppEnvironment.setDeviceType(
    data.size.shortestSide < 600 ? UserDeviceType.phone : UserDeviceType.tablet,
  );
}

void _setUpScreenOrientation() {
  SystemChrome.setPreferredOrientations(
    AppEnvironment.deviceType == UserDeviceType.phone
        ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
        : [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wanderlust',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: SplashBinding(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AuthGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

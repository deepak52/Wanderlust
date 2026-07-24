// login_binding.dart
// Login Binding - Dependency injection for Login Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/login_controller.dart';
import '../service/auth_service.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}

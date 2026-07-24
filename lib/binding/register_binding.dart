// register_binding.dart
// Register Binding - Dependency injection for Register Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/register_controller.dart';
import '../service/auth_service.dart';

class RegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
  }
}

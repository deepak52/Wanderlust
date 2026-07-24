// admin_home_binding.dart
// Admin Home Binding - Dependency injection for Admin Home Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/admin_home_controller.dart';

class AdminHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminHomeController>(() => AdminHomeController(), fenix: true);
  }
}

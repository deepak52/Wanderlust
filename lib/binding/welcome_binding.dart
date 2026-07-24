// welcome_binding.dart
// Welcome Binding - Dependency injection for Welcome Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/welcome_controller.dart';

class WelcomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(() => WelcomeController(), fenix: true);
  }
}

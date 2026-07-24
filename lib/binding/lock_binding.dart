// lock_binding.dart
// Lock Screen Binding - Dependency injection for Lock Screen
// Follows Agro-Prod patterns: Uses BindingsBuilder for lazy loading

import 'package:get/get.dart';

import '../controller/lock_controller.dart';
import '../service/lock_service.dart';

class LockBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LockService>(() => LockService(), fenix: true);
    Get.lazyPut<LockController>(() => LockController(), fenix: true);
  }
}

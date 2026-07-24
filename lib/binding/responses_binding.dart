// responses_binding.dart
// Responses Binding - Dependency injection for Responses Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/responses_controller.dart';
import '../service/auth_service.dart';

class ResponsesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<ResponsesController>(() => ResponsesController(), fenix: true);
  }
}

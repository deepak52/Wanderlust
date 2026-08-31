// responses_binding.dart
// Responses Binding - Dependency injection for Responses Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/responses_controller.dart';
import '../service/chat_service.dart';

class ResponsesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
    Get.lazyPut<ResponsesController>(() => ResponsesController(), fenix: true);
  }
}

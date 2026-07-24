// chat_binding.dart
// Chat Binding - Dependency injection for Chat Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/chat_controller.dart';
import '../service/chat_service.dart';
import '../service/auth_service.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  }
}

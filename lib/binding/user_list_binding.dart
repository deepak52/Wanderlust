// user_list_binding.dart
// User List Binding - Dependency injection for User List Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/user_list_controller.dart';
import '../service/auth_service.dart';
import '../service/chat_service.dart';

class UserListBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
    Get.lazyPut<UserListController>(() => UserListController(), fenix: true);
  }
}

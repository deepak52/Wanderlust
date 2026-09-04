import 'package:get/get.dart';
import '../controller/adventure_controller.dart';
import '../service/auth_service.dart';
import '../service/chat_service.dart';

class AdventureBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
    Get.lazyPut<AdventureController>(() => AdventureController(), fenix: true);
  }
}

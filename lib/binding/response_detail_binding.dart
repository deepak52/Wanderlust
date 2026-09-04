import 'package:get/get.dart';
import '../controller/response_detail_controller.dart';
import '../service/chat_service.dart';

class ResponseDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
    Get.lazyPut<ResponseDetailController>(() => ResponseDetailController());
  }
}


import 'package:get/get.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../model/response_model.dart';
import '../service/chat_service.dart';

class ResponseDetailController extends AppBaseController {
  final ChatService _chatService = Get.find<ChatService>();

  late final ResponseModel response;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ResponseModel) {
      response = args;
    } else {
      // Fallback empty response
      response = ResponseModel(
        userId: '',
        email: 'Unknown Traveler',
        answers: [],
        timestamp: DateTime.now(),
      );
    }
  }

  Future<void> onOpenConversation() async {
    if (response.userId.isEmpty) {
      Get.snackbar('Error', 'User ID not found');
      return;
    }

    try {
      showLoader();
      final chatId = await _chatService.getOrCreateChatRoom(response.userId);
      final email = response.email;
      final displayName = email.isNotEmpty
          ? email.split('@').first[0].toUpperCase() + email.split('@').first.substring(1)
          : '';
      hideLoader();

      Get.toNamed(
        chatPageRoute,
        arguments: {
          'chatId': chatId,
          'isAdmin': true,
          'userName': displayName,
        },
      );
    } catch (e) {
      hideLoader();
      Get.snackbar(
        'Error',
        'Failed to open conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}


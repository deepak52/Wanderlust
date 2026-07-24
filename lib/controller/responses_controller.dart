import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../model/response_model.dart';
import '../service/chat_service.dart';
import '../service/auth_service.dart';

class ResponsesController extends AppBaseController {
  final RxList<ResponseModel> responses = <ResponseModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final ChatService _chatService = Get.find<ChatService>();
  final AuthService _authService = Get.find<AuthService>();

  // Filtered responses based on search query
  List<ResponseModel> get filteredResponses {
    if (searchQuery.value.isEmpty) {
      return responses;
    }
    final query = searchQuery.value.toLowerCase();
    return responses.where((response) {
      return response.email.toLowerCase().contains(query) ||
          response.answerText.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadResponses();
  }

  Future<void> loadResponses() async {
    try {
      isLoading.value = true;
      final snapshot =
          await FirebaseFirestore.instance
              .collection('responses')
              .orderBy('timestamp', descending: true)
              .get();

      responses.value =
          snapshot.docs.map((doc) {
            return ResponseModel.fromFirestore(doc.data(), doc.id);
          }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load responses: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onResponseTap(ResponseModel response) {
    // Navigate to chat with this user
    onChatPressed(response.userId);
  }

  void onChatPressed(String userId) async {
    try {
      showLoader();
      final chatId = await _chatService.getOrCreateChatRoom(userId);
      hideLoader();
      Get.toNamed(
        chatPageRoute,
        arguments: {'chatId': chatId, 'isAdmin': true},
      );
    } catch (e) {
      hideLoader();
      Get.snackbar(
        'Error',
        'Failed to open chat: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteResponse(ResponseModel response) async {
    try {
      showLoader();
      await FirebaseFirestore.instance
          .collection('responses')
          .doc(response.id)
          .delete();
      hideLoader();
      // Reload responses
      await loadResponses();
      Get.snackbar(
        'Success',
        'Response deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      hideLoader();
      Get.snackbar(
        'Error',
        'Failed to delete response: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onLogout() async {
    await _authService.logout();
    Get.offAllNamed(loginPageRoute);
  }
}

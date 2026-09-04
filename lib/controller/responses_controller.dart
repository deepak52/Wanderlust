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

  Stream<QuerySnapshot>? _responseStream;

  @override
  Future<void> onInit() async {
    super.onInit();
    _initializeResponseStream();
  }

  void _initializeResponseStream() {
    _responseStream = FirebaseFirestore.instance
        .collection('responses')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _responseStream!.listen(
      (snapshot) {
        responses.assignAll(
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ResponseModel.fromFirestore(data, doc.id);
          }).toList(),
        );
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load responses: $error');
      },
    );
  }

  @override
  void onClose() {
    _responseStream = null;
    super.onClose();
  }

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

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onResponseTap(ResponseModel response) {
    // Navigate to dedicated adventure response detail screen
    Get.toNamed(
      responseDetailPageRoute,
      arguments: response,
    );
  }

  void onChatPressed(String userId) async {
    try {
      showLoader();
      final chatId = await _chatService.getOrCreateChatRoom(userId);
      final response = responses.firstWhereOrNull((r) => r.userId == userId);
      final email = response?.email ?? '';
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
      // Stream will auto-update, no need to reload
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

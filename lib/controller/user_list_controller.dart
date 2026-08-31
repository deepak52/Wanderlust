import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../helper/core/base/app_base_controller.dart';
import '../service/auth_service.dart';
import '../service/chat_service.dart';

class UserListController extends AppBaseController {
  final AuthService _authService = Get.find<AuthService>();
  final ChatService _chatService = Get.find<ChatService>();

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  Stream<QuerySnapshot>? _userStream;

  @override
  Future<void> onInit() async {
    super.onInit();
    _initializeUserStream();
  }

  void _initializeUserStream() {
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: false)
        .snapshots();

    _userStream!.listen(
      (snapshot) {
        final docs = snapshot.docs
            .where((doc) => doc.data() != null)
            .map((doc) => doc as QueryDocumentSnapshot<Map<String, dynamic>>)
            .toList();
        users.assignAll(docs);
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load users: $error');
      },
    );
  }

  @override
  void onClose() {
    _userStream = null;
    super.onClose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get filteredUsers {
    if (searchQuery.value.isEmpty) {
      return users;
    }
    return users.where((user) {
      final email = user.data()['email']?.toString().toLowerCase() ?? '';
      return email.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onUserTap(QueryDocumentSnapshot<Map<String, dynamic>> user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'Please log in again',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      showLoader();
      final userId = user.id;
      final chatId = await _chatService.getOrCreateChatRoom(userId);
      hideLoader();

      // STAGE 1: Print exact chatId used by UserListController
      developer.log('🟣 STAGE1 UserListController: chatId=$chatId, currentUserId=${currentUser.uid}, targetUserId=$userId, isAdmin=true');

      Get.toNamed('/chat', arguments: {'chatId': chatId, 'isAdmin': true});
    } catch (e) {
      hideLoader();
      Get.snackbar(
        'Error',
        'Failed to open chat: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onLogout() async {
    await _authService.logout();
    Get.offAllNamed('/login');
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('isAdmin', isEqualTo: false)
              .get();

      users.assignAll(snapshot.docs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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

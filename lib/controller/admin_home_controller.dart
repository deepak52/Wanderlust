import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../service/auth_service.dart';

class AdminHomeController extends AppBaseController {
  final AuthService _authService = Get.find<AuthService>();

  final RxInt adventuresCount = 0.obs;
  final RxInt travelersCount = 0.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _responsesSub;
  StreamSubscription? _usersSub;

  @override
  Future<void> onInit() async {
    super.onInit();
    _subscribeToMetrics();
  }

  void _subscribeToMetrics() {
    _responsesSub = FirebaseFirestore.instance
        .collection('responses')
        .snapshots()
        .listen((snapshot) {
      adventuresCount.value = snapshot.docs.length;
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });

    _usersSub = FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      travelersCount.value = snapshot.docs.length;
    }, onError: (_) {});
  }

  @override
  void onClose() {
    _responsesSub?.cancel();
    _usersSub?.cancel();
    super.onClose();
  }

  void onViewResponses() {
    Get.toNamed(responsesPageRoute);
  }

  void onViewUserList() {
    Get.toNamed(userListPageRoute);
  }

  Future<void> onLogout() async {
    await _authService.logout();
    Get.offAllNamed(loginPageRoute);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../model/chat_model.dart';

class WelcomeController extends AppBaseController {
  final RxString welcomeMessage =
      'Adventure is calling, and this app is your answer.'.obs;

  final RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  /// Checks if the current user has already submitted responses
  Future<bool> hasSubmittedResponses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final responseDoc =
          await FirebaseFirestore.instance
              .collection('responses')
              .doc(user.uid)
              .get();
      return responseDoc.exists;
    } catch (e) {
      debugPrint('Error checking responses: $e');
      return false;
    }
  }

  /// Navigates based on whether user has submitted responses
  Future<void> navigateBasedOnResponses() async {
    isLoading.value = true;
    final hasSubmitted = await hasSubmittedResponses();
    isLoading.value = false;

    if (hasSubmitted) {
      await navigateToChat(isAdmin: true);
    } else {
      Get.offAllNamed(tourDateQuestionPageRoute);
    }
  }

  void onGetStarted() {
    navigateBasedOnResponses();
  }

  void onSkip() {
    // Skip goes directly to chat
    navigateToChat(isAdmin: true);
  }

  /// Navigate to chat with proper arguments
  Future<void> navigateToChat({required bool isAdmin}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      showLoader();

      // Fetch admin user dynamically
      final adminQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        hideLoader();
        Get.snackbar(
          'Error',
          'Admin user not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final adminId = adminQuery.docs.first.id;
      final chatId = ChatUtils.generateChatId(adminId, user.uid);
      
      // STAGE 1: Print exact chatId used by WelcomeController
      developer.log('🟣 STAGE1 WelcomeController: chatId=$chatId, userId=${user.uid}, adminId=$adminId, isAdmin=$isAdmin');

      hideLoader();

      // Navigate to chat with proper arguments
      Get.offAllNamed(
        chatPageRoute,
        arguments: {'chatId': chatId, 'isAdmin': isAdmin},
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
}

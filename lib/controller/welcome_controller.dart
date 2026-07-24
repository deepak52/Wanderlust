import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';

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
      Get.offAllNamed(chatPageRoute);
    } else {
      Get.offAllNamed(tourDateQuestionPageRoute);
    }
  }

  void onGetStarted() {
    navigateBasedOnResponses();
  }

  void onSkip() {
    // Skip goes directly to chat
    Get.offAllNamed(chatPageRoute);
  }
}

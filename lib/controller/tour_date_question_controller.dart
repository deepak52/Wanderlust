import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';

class TourDateQuestionController extends AppBaseController {
  final PageController pageController = PageController();
  final RxList<String> answers = <String>['', '', ''].obs;
  final RxInt currentPage = 0.obs;

  final List<String> questions = [
    'Where would you like to go on a tour?',
    'What kind of experience are you looking for?',
    'Do you prefer solo travel or group travel?',
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  void onAnswerChanged(int index, String value) {
    answers[index] = value;
  }

  Future<void> nextPage() async {
    if (answers[currentPage.value].isEmpty) return;

    if (currentPage.value < questions.length - 1) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      await saveAnswersAndNavigateToChat();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> saveAnswersAndNavigateToChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    try {
      showLoader();

      // Save responses to Firestore
      await FirebaseFirestore.instance.collection('responses').doc(userId).set({
        'answers': answers.toList(),
        'userId': userId,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

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
      final chatId = '${adminId}_$userId';

      hideLoader();

      // Navigate to ChatScreen with dynamic chatId
      Get.offAllNamed(
        chatPageRoute,
        arguments: {'chatId': chatId, 'isAdmin': false},
      );
    } catch (e) {
      hideLoader();
      Get.snackbar(
        'Error',
        'Failed to save answers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(loginPageRoute);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

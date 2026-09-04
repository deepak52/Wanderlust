import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helper/core/base/app_base_controller.dart';
import '../../model/login_model.dart';
import '../../service/auth_service.dart';

class RegisterController extends AppBaseController {
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isEmailValid = true.obs;
  RxBool isPasswordValid = true.obs;
  RxBool isConfirmPasswordValid = true.obs;
  RxBool hidePassword = true.obs;
  RxBool hideConfirmPassword = true.obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Password strength indicators
  RxBool hasMinLength = false.obs;
  RxBool hasUppercase = false.obs;
  RxBool hasLowercase = false.obs;
  RxBool hasDigit = false.obs;
  RxBool hasSpecialChar = false.obs;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(_validatePassword);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _validatePassword() {
    final password = passwordController.text;
    hasMinLength.value = password.length >= 6;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = password.contains(RegExp(r'[a-z]'));
    hasDigit.value = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = password.contains(
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]'),
    );
  }

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  bool _validateForm() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      isEmailValid.value = false;
      Get.snackbar(
        'Email Required',
        'Please enter your email or phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xF506161A),
        colorText: const Color(0xFFF4E5C5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    if (!email.contains('@')) {
      isEmailValid.value = false;
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xF506161A),
        colorText: const Color(0xFFF4E5C5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    isEmailValid.value = true;

    final password = passwordController.text.trim();
    if (password.length < 6) {
      isPasswordValid.value = false;
      Get.snackbar(
        'Password Too Short',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xF506161A),
        colorText: const Color(0xFFF4E5C5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    isPasswordValid.value = true;

    final confirmPassword = confirmPasswordController.text.trim();
    if (confirmPassword != password) {
      isConfirmPasswordValid.value = false;
      Get.snackbar(
        'Passwords Do Not Match',
        'Please make sure both passwords match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xF506161A),
        colorText: const Color(0xFFF4E5C5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    isConfirmPasswordValid.value = true;

    return true;
  }

  Future<bool> register() async {
    hideKeyboard();

    if (!_validateForm()) {
      return false;
    }

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final request = LoginRequest(userCode: email, password: password);
      final response = await _authService.register(request);

      if (response != null) {
        Get.snackbar(
          'Success',
          'Registration successful. Please login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );

        // Navigate back to login
        Get.offAllNamed('/login');
        return true;
      }

      Get.snackbar(
        'Error',
        'Registration failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLogin() {
    Get.back();
  }
}

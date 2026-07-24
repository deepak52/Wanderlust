// lock_screen.dart
// Lock Screen View - Migrated from Wanderlust
// Follows Agro-Prod patterns: extends AppBaseView, uses shared widgets, theme

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/lock_controller.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../helper/sizer.dart';
import '../../model/lock_model.dart';
import '../../helper/widget/common_widget.dart';

class LockScreen extends AppBaseView<LockController> {
  final LockArguments? arguments;

  const LockScreen({super.key, this.arguments});

  @override
  Widget buildView() => _buildScaffold();

  Scaffold _buildScaffold() => appScaffold(
    topSafe: false,
    bottomSafe: false,
    body: Obx(() {
      // If unlocked, navigate away
      if (controller.unlocked.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.navigateAfterUnlock(arguments);
        });
        return _lockView(); // Show lock briefly while navigating
      }
      return _lockView();
    }),
  );

  Widget _lockView() => Obx(
    () => Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(color: AppColorHelper.backgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lock icon with animation
          _buildLockIcon(),

          height(32),

          // Title
          appText(
            'App Locked',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColorHelper.primaryTextColor,
          ),

          height(12),

          // Subtitle
          appText(
            controller.lockEnabled.value
                ? 'Authenticate to continue'
                : 'App lock is disabled',
            fontSize: 16,
            color: AppColorHelper.secondaryTextColor,
            textAlign: TextAlign.center,
          ),

          height(40),

          // Error message
          if (controller.errorMessage.value.isNotEmpty) _buildErrorMessage(),

          height(24),

          // Biometric button
          if (controller.biometricAvailable.value && !controller.unlocked.value)
            _buildBiometricButton(),

          // PIN keypad (shown if biometric not available or failed)
          if (controller.hasPin.value &&
              (!controller.biometricAvailable.value ||
                  controller.errorMessage.value.isNotEmpty))
            _buildPinKeypad(),

          // No auth method message
          if (!controller.biometricAvailable.value && !controller.hasPin.value)
            _buildNoAuthMethod(),
        ],
      ),
    ),
  );

  Widget _buildLockIcon() => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.8, end: 1.0),
    duration: const Duration(milliseconds: 800),
    curve: Curves.elasticOut,
    builder:
        (context, value, child) => Transform.scale(
          scale: value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorHelper.primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColorHelper.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 50,
              color: AppColorHelper.primaryColor,
            ),
          ),
        ),
  );

  Widget _buildErrorMessage() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 40),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColorHelper.errorColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColorHelper.errorColor.withValues(alpha: 0.3),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: AppColorHelper.errorColor,
          size: 20,
        ),
        width(12),
        Expanded(
          child: appText(
            controller.errorMessage.value,
            fontSize: 14,
            color: AppColorHelper.errorColor,
          ),
        ),
      ],
    ),
  );

  Widget _buildBiometricButton() => Obx(
    () =>
        controller.isAuthenticating.value
            ? _buildLoadingIndicator()
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: buttonContainer(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBiometricIcon(),
                    width(12),
                    appText(
                      _getBiometricLabel(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColorHelper.textColor,
                    ),
                  ],
                ),
                radius: 16,
                height: 56,
                color: AppColorHelper.primaryColor,
                onPressed: () => _triggerBiometricAuth(),
              ),
            ),
  );

  Widget _buildBiometricIcon() {
    // Get available biometric type
    final biometrics = <BiometricType>[]; // Would come from service
    if (biometrics.contains(BiometricType.face)) {
      return Icon(
        Icons.face_unlock_rounded,
        color: AppColorHelper.textColor,
        size: 24,
      );
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return Icon(
        Icons.fingerprint_rounded,
        color: AppColorHelper.textColor,
        size: 24,
      );
    } else if (biometrics.contains(BiometricType.iris)) {
      return Icon(
        Icons.remove_red_eye_rounded,
        color: AppColorHelper.textColor,
        size: 24,
      );
    }
    return Icon(
      Icons.verified_user_rounded,
      color: AppColorHelper.textColor,
      size: 24,
    );
  }

  String _getBiometricLabel() {
    // Would check actual biometric type
    return 'Use Biometric';
  }

  void _triggerBiometricAuth() async {
    // Biometric auth is auto-triggered in controller's authenticate()
    // This button is for manual retry
    await controller.authenticate();
  }

  Widget _buildLoadingIndicator() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: buttonContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColorHelper.textColor,
              ),
            ),
          ),
          width(12),
          appText(
            'Authenticating...',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColorHelper.textColor,
          ),
        ],
      ),
      radius: 16,
      height: 56,
      color: AppColorHelper.primaryColor.withValues(alpha: 0.7),
    ),
  );

  Widget _buildPinKeypad() => Column(
    children: [
      // PIN indicator dots
      _buildPinIndicator(),

      height(24),

      // Keypad
      _buildKeypad(),
    ],
  );

  Widget _buildPinIndicator() => Obx(
    () => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index < controller.pinInput.value.length
                    ? AppColorHelper.primaryColor
                    : AppColorHelper.borderColor,
            border: Border.all(
              color:
                  index < controller.pinInput.value.length
                      ? AppColorHelper.primaryColor
                      : AppColorHelper.borderColor,
              width: 2,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildKeypad() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(
      children: [
        // Row 1: 1, 2, 3
        _buildKeypadRow(['1', '2', '3']),
        height(16),
        // Row 2: 4, 5, 6
        _buildKeypadRow(['4', '5', '6']),
        height(16),
        // Row 3: 7, 8, 9
        _buildKeypadRow(['7', '8', '9']),
        height(16),
        // Row 4: backspace, 0, confirm
        _buildKeypadRow(['backspace', '0', 'confirm']),
      ],
    ),
  );

  Widget _buildKeypadRow(List<String> keys) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: keys.map((key) => _buildKeypadButton(key)).toList(),
  );

  Widget _buildKeypadButton(String key) {
    if (key == 'backspace') {
      return GestureDetector(
        onTap: controller.removePinDigit,
        onLongPress: controller.clearPin,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorHelper.cardColor,
            border: Border.all(color: AppColorHelper.borderColor, width: 1),
          ),
          child: Icon(
            Icons.backspace_rounded,
            color: AppColorHelper.primaryTextColor,
            size: 28,
          ),
        ),
      );
    }

    if (key == 'confirm') {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColorHelper.primaryColor.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColorHelper.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.check_rounded,
          color: AppColorHelper.primaryColor,
          size: 28,
        ),
      );
    }

    // Number button
    return GestureDetector(
      onTap: () => controller.addPinDigit(key),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColorHelper.cardColor,
          border: Border.all(color: AppColorHelper.borderColor, width: 1),
        ),
        child: Center(
          child: appText(
            key,
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: AppColorHelper.primaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNoAuthMethod() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(
      children: [
        appText(
          'No authentication method configured',
          fontSize: 16,
          color: AppColorHelper.secondaryTextColor,
          textAlign: TextAlign.center,
        ),
        height(16),
        appText(
          'Enable app lock in Settings to set up PIN or biometric',
          fontSize: 14,
          color: AppColorHelper.secondaryTextColor.withValues(alpha: 0.7),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

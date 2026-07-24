import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/register_controller.dart';
import '../../gen/assets.gen.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../helper/sizer.dart';
import '../../helper/widget/common_widget.dart';
import '../../helper/widget/animatedexpandcontainer/animated_expand_container.dart';
import '../../helper/widget/textformfield/textformfield_widget.dart';

class RegisterScreen extends AppBaseView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget buildView() => _buildScaffold();

  Scaffold _buildScaffold() => appScaffold(
    topSafe: false,
    bottomSafe: false,
    resizeToAvoidBottomInset: true,
    body: _buildBody(),
  );

  Widget _buildBody() {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(Assets.images.splashBg1.path, fit: BoxFit.cover),
          ),

          // Register content
          AnimatedExpandContainer(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 1800),
            initialHeight: 0,
            finalHeight: Get.height,
            initialWidth: Get.width,
            finalWidth: Get.width,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => FocusScope.of(Get.context!).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          height(40),
                          Obx(
                            () => AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: 1.0,
                              child: Column(
                                children: [
                                  appText(
                                    "Create Account",
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: AppColorHelper.primaryTextColor,
                                  ),
                                  height(9),
                                  appText(
                                    "Register to manage and track your business",
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: AppColorHelper.primaryTextColor,
                                  ),
                                  appText(
                                    "journey",
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: AppColorHelper.primaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          height(40),
                          _buildForm(),
                          height(20),
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildEmailField(),
          height(20),
          _buildPasswordField(),
          height(20),
          _buildConfirmPasswordField(),
          height(30),
          _buildPasswordRequirements(),
          height(30),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: appText(
            "Email",
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: AppColorHelper.primaryTextColor,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorHelper.cardColor,
            border: Border.all(
              color: AppColorHelper.primaryTextColor.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormWidget(
            controller: controller.emailController,
            focusNode: FocusNode(),
            height: 40,
            label: "Email",
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: appText(
              "Password",
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppColorHelper.primaryTextColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColorHelper.cardColor,
              border: Border.all(
                color:
                    controller.isPasswordValid.value
                        ? AppColorHelper.primaryTextColor.withValues(alpha: 0.2)
                        : AppColorHelper.errorBorderColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormWidget(
              controller: controller.passwordController,
              focusNode: FocusNode(),
              height: 40,
              label: "Password",
              rxObscureText: controller.hidePassword,
              enableObscureToggle: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: appText(
              "Confirm Password",
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppColorHelper.primaryTextColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColorHelper.cardColor,
              border: Border.all(
                color:
                    controller.isConfirmPasswordValid.value
                        ? AppColorHelper.primaryTextColor.withValues(alpha: 0.2)
                        : AppColorHelper.errorBorderColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormWidget(
              controller: controller.confirmPasswordController,
              focusNode: FocusNode(),
              height: 40,
              label: "Confirm Password",
              rxObscureText: controller.hideConfirmPassword,
              enableObscureToggle: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            "Password Requirements",
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColorHelper.primaryTextColor,
          ),
          height(8),
          _buildRequirementRow(
            "At least 6 characters",
            controller.hasMinLength.value,
          ),
          height(4),
          _buildRequirementRow(
            "One uppercase letter",
            controller.hasUppercase.value,
          ),
          height(4),
          _buildRequirementRow(
            "One lowercase letter",
            controller.hasLowercase.value,
          ),
          height(4),
          _buildRequirementRow("One number", controller.hasDigit.value),
          height(4),
          _buildRequirementRow(
            "One special character",
            controller.hasSpecialChar.value,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color:
              isMet
                  ? Colors.green
                  : AppColorHelper.primaryTextColor.withValues(alpha: 0.5),
        ),
        width(8),
        appText(
          text,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color:
              isMet
                  ? Colors.green
                  : AppColorHelper.primaryTextColor.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => buttonContainer(
        radius: 10,
        height: 56,
        color: AppColorHelper.primaryColor,
        controller.isLoading.value
            ? buttonLoader()
            : appText(
              "Register",
              fontSize: 18,
              color: AppColorHelper.textColor,
              fontWeight: FontWeight.w500,
            ),
        onPressed: () async {
          if (controller.isLoading.value) return;
          await controller.register();
        },
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: controller.navigateToLogin,
      child: appText(
        "Already have an account? Login",
        fontSize: 14,
        color: AppColorHelper.primaryColor,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

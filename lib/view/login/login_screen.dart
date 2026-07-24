import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/login_controller.dart';
import '../../gen/assets.gen.dart';
import '../../helper/app_string.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../helper/navigation.dart';
import '../../helper/route.dart';
import '../../helper/sizer.dart';
import '../../service/auth_service.dart';
import '../../helper/widget/common_widget.dart';
import '../../helper/widget/animatedexpandcontainer/animated_expand_container.dart';
import '../../helper/widget/textformfield/textformfield_widget.dart';

class LoginScreen extends AppBaseView<LoginController> {
  final AuthService _authService = Get.find<AuthService>();
  LoginScreen({super.key});

  final GlobalKey _userFieldKey = GlobalKey();
  final GlobalKey _passFieldKey = GlobalKey();

  //static const double headerInset = 130;
  static final RxBool showHeader = true.obs;

  @override
  Widget buildView() => _buildScaffold();

  Scaffold _buildScaffold() => appScaffold(
    topSafe: false,
    bottomSafe: false,
    resizeToAvoidBottomInset: true,
    body: appFutureBuilder<void>(
      () => controller.fetchInitData(),
      (context, snapshot) => _buildBody(),
    ),
  );

  Widget _buildBody() {
    return SizedBox.expand(
      child: Stack(
        children: [
          // 1️⃣ Static splash background – never moves
          Positioned.fill(
            child: Image.asset(Assets.images.splashBg1.path, fit: BoxFit.cover),
          ),

          // 2️⃣ Login background (behind everything)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 1.0, // >1 stretches vertically downward
                widthFactor: 1.0,
                child: Image.asset(
                  Assets.images.loginBg.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          AnimatedExpandContainer(
            onComplete: () {
              // trigger fade slightly BEFORE completion visually
              Future.microtask(() {
                controller.introAnimDone.value = true;
              });
            },
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 1800),
            initialHeight: 0,
            finalHeight: 400,
            initialWidth: Get.width,
            finalWidth: Get.width,
            alignment: Alignment.topCenter,
            clipChild: true,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OverflowBox(
                  minHeight: 0,
                  maxHeight: double.infinity,
                  alignment: Alignment.bottomCenter,
                  child: Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 1300),
                      opacity: controller.introAnimDone.value ? 0.0 : 1.0,
                      child: SizedBox(
                        height: 100, // real height of your text block
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            appText(
                              "Let's Get Started",
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColorHelper.primaryTextColor,
                            ),
                            height(9),
                            appText(
                              "Login to manage and track your business",
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
                  ),
                ),
              ),
            ),
          ),

          Obx(() {
            return AnimatedOpacity(
              duration: const Duration(
                milliseconds: 2000,
              ), // controls how slow it disappears
              curve: Curves.easeOut,
              opacity: controller.isRibbonDone.value ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: controller.isRibbonDone.value,
                child: AnimatedExpandContainer(
                  onComplete: () => controller.isRibbonDone.value = true,
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 2000),
                  initialHeight: Get.height,
                  finalHeight: 240,
                  initialWidth: Get.width,
                  finalWidth: Get.width * 0.40,
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          Assets.images.splashBg4.path,
                          fit: BoxFit.cover,
                        ),
                        Center(
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 2700),
                            curve: Curves.easeOutCubic,
                            alignment:
                                controller.moveLogo.value
                                    ? const Alignment(
                                      0,
                                      0.535,
                                    ) // final header alignment
                                    : const Alignment(0, 0), // splash center
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOut,
                              scale: controller.moveLogo.value ? 1.5 : 1.0,
                              child: FractionallySizedBox(
                                widthFactor:
                                    0.40, // ✅ splash logo size (LOCKED)
                                child: Image.asset(
                                  Assets.images.muziris.path,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          // 4️⃣ Login content – slides up in sync
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final isKeyboardOpen =
                            MediaQuery.of(context).viewInsets.bottom > 0;

                        final content = Column(
                          children: [
                            Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 800),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child:
                                    controller.isRibbonDone.value
                                        ? SizedBox(
                                          key: const ValueKey('header'),
                                          height: 240,
                                          width: Get.width * 0.40,
                                          child:
                                              LoginScreen.buildHeaderSurface(),
                                        )
                                        : SizedBox(
                                          key: const ValueKey('placeholder'),
                                          height: 240, // 👈 HOLD SPACE
                                          width: Get.width * 0.40,
                                        ),
                              ),
                            ),
                            _mobileView(),
                          ],
                        );

                        return SingleChildScrollView(
                          controller: controller.scrollController,
                          physics:
                              isKeyboardOpen
                                  ? const BouncingScrollPhysics() // keyboard open → allow scroll
                                  : const NeverScrollableScrollPhysics(), // keyboard closed → lock
                          child: content,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _mobileView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Obx(() {
        final rawInset = MediaQuery.of(Get.context!).viewInsets.bottom;
        final isKeyboardOpen = rawInset > 0;
        final keyboardInset =
            isKeyboardOpen ? rawInset.clamp(250, 320).toDouble() : 0.0;

        if (isKeyboardOpen && !controller.didAutoScroll.value) {
          controller.didAutoScroll.value = true;

          // Wait for keyboard + ribbon layout to settle
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.scrollController.hasClients) {
                controller.scrollController.animateTo(
                  95,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          });
        }

        if (!isKeyboardOpen && controller.didAutoScroll.value) {
          controller.didAutoScroll.value = false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.scrollController.hasClients) {
              controller.scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }

        return AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            top: 20,
            bottom: isKeyboardOpen ? keyboardInset : 20,
          ),
          child: Column(
            mainAxisAlignment:
                isKeyboardOpen
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              height(isKeyboardOpen ? 10 : 40),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: controller.introAnimDone.value ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      appText(
                        "Let's Get Started",
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColorHelper.primaryTextColor,
                      ),
                      height(isKeyboardOpen ? 6 : 9),
                      appText(
                        "Login to manage and track your business",
                        textAlign: TextAlign.center,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: AppColorHelper.primaryTextColor,
                      ),
                      appText(
                        "journey",
                        textAlign: TextAlign.center,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: AppColorHelper.primaryTextColor,
                      ),
                    ],
                  ),
                ),
              ),
              height(isKeyboardOpen ? 20 : 91),
              Form(
                key: controller.form,
                child: Column(
                  children: [
                    _buildUsernameField(),
                    height(isKeyboardOpen ? 12 : 22),
                    _buildPasswordField(),
                    height(isKeyboardOpen ? 20 : (Platform.isIOS ? 50 : 45)),
                    buttonContainer(
                      radius: 10,
                      height: 68,
                      color: AppColorHelper.primaryColor,
                      controller.rxIsLoading.value
                          ? buttonLoader()
                          : appText(
                            login.tr,
                            fontSize: 18,
                            color: AppColorHelper.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                      onPressed: () async {
                        if (controller.rxIsLoading.value) return;

                        await controller.signIn();
                      },
                    ),
                    height(isKeyboardOpen ? 8 : 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {},
                          child: appText(
                            forgetPassworddialogue.tr,
                            fontSize: 14,
                            color: AppColorHelper.primaryTextColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(registerPageRoute),
                          child: appText(
                            "Register",
                            fontSize: 14,
                            color: AppColorHelper.primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: appText(
            username,
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
            controller: controller.userController,
            focusNode: controller.userFocusNode,
            nextFocusNode: controller.passwordFocusNode,
            height: 40,
            label: null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: appText(
            password.tr,
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
            focusNode: controller.passwordFocusNode,
            height: 40,
            label: password.tr,
            textColor: AppColorHelper.primaryTextColor,
            //  rxObscureText: controller.rxShowPassword.map((v) => !v).obs,
            rxObscureText: controller.rxhidePassword,
            enableObscureToggle: true,
          ),
        ),
      ],
    );
  }

  static Widget buildHeaderSurface() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background exactly like the ribbon's final frame
          Image.asset(Assets.images.muziris.path, fit: BoxFit.cover),

          // Final-position logo (no animation here)
          Align(
            alignment: const Alignment(0, 0.56), // same as ribbon end
            child: FractionallySizedBox(
              widthFactor: 0.60, // same visual size as ribbon end
              child: Image.asset(
                Assets.images.muziris.path,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

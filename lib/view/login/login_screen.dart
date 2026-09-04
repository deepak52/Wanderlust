import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/login_controller.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/route.dart';
import 'package:wanderlust/widgets/splash/wanderlust_golden_logo.dart';

class LoginScreen extends AppBaseView<LoginController> {
  final bool showTopLogo;
  const LoginScreen({super.key, this.showTopLogo = true});

  @override
  Widget buildView() {
    final context = Get.context!;
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;

    // Dark teal login panel begins at 25% from top, covering 75% of screen height
    final double panelTopY = screenHeight * 0.25;
    const double nameHeight = 72.0;
    // Positioned right in the middle of the available 25% space
    final double headerLogoTop = (mediaQuery.padding.top +
            (panelTopY - mediaQuery.padding.top - nameHeight) / 2)
        .clamp(mediaQuery.padding.top + 2.0, panelTopY - 78.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF041014),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF041014),
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1️⃣ Full-Screen Landscape Background (assets/images/loginbg.png)
            Positioned.fill(
              child: Image.asset(
                'assets/images/loginbg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            // 2️⃣ Top Centered Golden Wanderlust Brand Header (right in the middle of top 25% sky)
            Positioned(
              top: headerLogoTop,
              left: 0,
              right: 0,
              child: const Center(
                child: WanderlustGoldenLogo(
                  nameHeight: nameHeight,
                  emblemOpacity: 0.0, // Top emblem disappears in final login screen
                ),
              ),
            ),

            // 3️⃣ Dark Teal / Forest Glass Login Surface Covering 75% of Height
            Positioned(
              top: panelTopY,
              left: 0,
              right: 0,
              bottom: 0,
              child: const LoginCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF506161A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        border: Border.all(
          color: const Color(0x334E9B92),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF0071C20),
            Color(0xFA041115),
            Color(0xFF020B0E),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Golden Top Glowing Edge Accent Line
          Positioned(
            top: 0,
            left: 50,
            right: 50,
            child: Container(
              height: 1.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFE5C178),
                    Color(0xFFFFF2D6),
                    Color(0xFFE5C178),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFC5A25D),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2D6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF2C265),
                      blurRadius: 8,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: LoginScreenBody(),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreenBody extends StatelessWidget {
  const LoginScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Welcome Back!" in warm golden ivory serif
        Center(
          child: Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF4E5C5),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            'Log in to continue your adventure',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8CAEA8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Golden Leaf / Waterdrop Flourish
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0x66C5A25D)],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.water_drop_rounded,
              size: 11,
              color: Color(0xFFE5C178),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x66C5A25D), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Form Fields
        Form(
          key: controller.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email or Phone Label
              const Text(
                'Email or Phone',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEADFCA),
                ),
              ),
              const SizedBox(height: 8),
              _buildDarkInputField(
                controller: controller.userController,
                focusNode: controller.userFocusNode,
                nextFocusNode: controller.passwordFocusNode,
                hintText: 'Email or Phone',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Label
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEADFCA),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => _buildDarkInputField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: controller.rxhidePassword.value,
                  suffixIcon: controller.rxhidePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: () => controller.rxhidePassword.value =
                      !controller.rxhidePassword.value,
                  onSubmitted: () async {
                    if (!controller.rxIsLoading.value) {
                      await controller.signIn();
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Primary Log In Button with Mountain Peak Icon
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B828C), Color(0xFF106069)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B828C)
                              .withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: controller.rxIsLoading.value
                          ? null
                          : () async {
                              await controller.signIn();
                            },
                      child: controller.rxIsLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.terrain_rounded,
                                  size: 19,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sign Up Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF7E9D98),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(registerPageRoute),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFFF2C265),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDarkInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onSubmitted,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF06171B),
        border: Border.all(
          color: const Color(0x446B968E),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
        style: const TextStyle(
          color: Color(0xFFF0EBE0),
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: const Color(0xFF1B828C),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF5A7974),
            fontSize: 13.5,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF86ADA5),
            size: 20,
          ),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: const Color(0xFF86ADA5),
                    size: 20,
                  ),
                  onPressed: onSuffixTap,
                  splashRadius: 20,
                )
              : null,
        ),
        onSubmitted: (_) {
          if (nextFocusNode != null) {
            nextFocusNode.requestFocus();
          } else if (onSubmitted != null) {
            onSubmitted();
          }
        },
      ),
    );
  }
}

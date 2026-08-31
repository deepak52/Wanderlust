import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/login_controller.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/route.dart';
import '../../widgets/splash/wanderlust_wave_painter.dart';
import '../splash/splash_screen.dart';

class LoginScreen extends AppBaseView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget buildView() {
    final context = Get.context!;
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    final double logoTop = safeAreaTop + 16.0;

    // Single Source of Truth for Final Logo Height (84.0px)
    const double logoHeight = kFinalWanderlustLogoHeight;

    // Calculated Wave & Content Boundaries (Unchanged position/layout)
    final double baseWaveY = logoTop + 64.0 + 40.0; // Wave baseline position
    final double contentTopY = baseWaveY + 36.0; // Content starts strictly BELOW wave boundary

    return Scaffold(
      backgroundColor: const Color(0xFF0F2E1E),
      body: Stack(
        children: [
          // 1️⃣ Full-Screen Landscape Background (splashBg4.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/splashBg4.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2️⃣ Organic Wave Painter (Fills dark forest green from baseWaveY down to bottom)
          Positioned.fill(
            child: CustomPaint(
              painter: WanderlustWavePainter(
                progress: 1.0,
                color: const Color(0xFF0F2E1E),
                baseWaveY: baseWaveY,
              ),
            ),
          ),

          // 3️⃣ FIXED LOCKED HEADER LOGO (Single Source of Truth: safeAreaTop + 16.0, height: 84.0px)
          Positioned(
            top: logoTop,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: logoHeight,
                child: Image.asset(
                  'assets/images/wanderlust.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 4️⃣ LOGIN CONTENT REGION (Starts cleanly BELOW the wave boundary at contentTopY; scrollable on keyboard pop-up)
          Positioned(
            top: contentTopY,
            left: 0,
            right: 0,
            bottom: 0,
            child: const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 4,
                bottom: 24,
              ),
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
        // Header Texts (Positioned cleanly below the wavy curve)
        const Text(
          'Welcome Back!',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Log in to continue your adventure',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFFB0CFBE),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),

        // Form Fields & Controls (Spaced gracefully down the screen)
        Form(
          key: controller.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email or Phone Field
              const Text(
                'Email or Phone',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD1E3D7),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: controller.userController,
                focusNode: controller.userFocusNode,
                nextFocusNode: controller.passwordFocusNode,
                hintText: 'Email or Phone',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              // Password Field
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD1E3D7),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => _buildInputField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
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
              const SizedBox(height: 10),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9BC85A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary Log In Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9BC85A),
                      foregroundColor: const Color(0xFF0F2E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
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
                              color: Color(0xFF0F2E1E),
                            ),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2E1E),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Or Continue With Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialSquareButton(
                    child: const GoogleLogoIcon(size: 20),
                    onTap: () {},
                  ),
                  const SizedBox(width: 14),
                  _buildSocialSquareButton(
                    child: const Icon(
                      Icons.apple,
                      color: Colors.white,
                      size: 22,
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(width: 14),
                  _buildSocialSquareButton(
                    child: const Icon(
                      Icons.smartphone_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Sign Up Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(registerPageRoute),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9BC85A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
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
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF143825),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        cursorColor: const Color(0xFF9BC85A),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 13,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 18,
          ),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  onPressed: onSuffixTap,
                  splashRadius: 18,
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

  Widget _buildSocialSquareButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF143825),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class GoogleLogoIcon extends StatelessWidget {
  final double size;
  const GoogleLogoIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerR = size.width * 0.48;
    final double innerR = size.width * 0.24;
    final Rect rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: (outerR + innerR) / 2,
    );
    final double strokeWidth = outerR - innerR;

    final Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Red (top)
    p.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -0.6, -1.8, false, p);

    // Yellow (left)
    p.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -2.4, -1.2, false, p);

    // Green (bottom)
    p.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.6, 1.8, false, p);

    // Blue (right arc)
    p.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.6, 1.2, false, p);

    // Blue horizontal bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - strokeWidth / 2, cx + outerR, cy + strokeWidth / 2),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

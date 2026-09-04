import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderlust/widgets/splash/wanderlust_golden_logo.dart';
import '../../controller/register_controller.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/route.dart';

class RegisterScreen extends AppBaseView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget buildView() {
    final context = Get.context!;
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;

    // Dark teal register panel begins at 25% from top, covering 75% of screen height
    final double panelTopY = screenHeight * 0.25;
    const double nameHeight = 72.0;
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

            // 2️⃣ Top Centered Golden Wanderlust Brand Header (within top 25% sky)
            Positioned(
              top: headerLogoTop,
              left: 0,
              right: 0,
              child: const Center(
                child: WanderlustName(
                  height: nameHeight,
                  color: Color(0xFFFFF1C2),
                ),
              ),
            ),

            // 3️⃣ Dark Teal / Forest Glass Register Surface Covering 75% of Height
            Positioned(
              top: panelTopY,
              left: 0,
              right: 0,
              bottom: 0,
              child: const RegisterCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterCard extends StatelessWidget {
  const RegisterCard({super.key});

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
          const Positioned.fill(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: RegisterScreenBody(),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterScreenBody extends StatefulWidget {
  const RegisterScreenBody({super.key});

  @override
  State<RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<RegisterScreenBody> {
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.isRegistered<RegisterController>()
        ? Get.find<RegisterController>()
        : Get.put(RegisterController());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // \'Begin Your Adventure\' Title
        Center(
          child: Text(
            'Begin Your Adventure',
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
            'Create your account to start exploring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8CAEA8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Golden Leaf / Droplet Flourish
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
        const SizedBox(height: 18),

        // Form Fields
        Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email Label
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
                controller: controller.emailController,
                focusNode: _emailFocus,
                nextFocusNode: _passwordFocus,
                hintText: 'Email or Phone',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

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
                  focusNode: _passwordFocus,
                  nextFocusNode: _confirmPasswordFocus,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: controller.hidePassword.value,
                  suffixIcon: Icon(
                    controller.hidePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF86ADA5),
                    size: 20,
                  ),
                  onSuffixTap: controller.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 14),

              // Confirm Password Label
              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEADFCA),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => _buildDarkInputField(
                  controller: controller.confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  hintText: 'Confirm Password',
                  prefixIcon: Icons.shield_outlined,
                  obscureText: controller.hideConfirmPassword.value,
                  suffixIcon: Icon(
                    controller.hideConfirmPassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF86ADA5),
                    size: 20,
                  ),
                  onSuffixTap: controller.toggleConfirmPasswordVisibility,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    if (!controller.isLoading.value) {
                      await controller.register();
                    }
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Password Requirements Checklist Chips
              Obx(
                () => Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildRequirementTag('6+ characters', controller.hasMinLength.value),
                    _buildRequirementTag('Uppercase', controller.hasUppercase.value),
                    _buildRequirementTag('Lowercase', controller.hasLowercase.value),
                    _buildRequirementTag('Number', controller.hasDigit.value),
                    _buildRequirementTag('Special char', controller.hasSpecialChar.value),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Primary Register Button
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
                          color: const Color(0xFF1B828C).withValues(alpha: 0.4),
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
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.register();
                            },
                      child: controller.isLoading.value
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
                                  Icons.explore_rounded,
                                  size: 19,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Create Account',
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
              const SizedBox(height: 24),

              // Back to Login Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF7E9D98),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Get.previousRoute.isNotEmpty) {
                        Get.back();
                      } else {
                        Get.offNamed(loginPageRoute);
                      }
                    },
                    child: const Text(
                      'Log In',
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

  Widget _buildRequirementTag(String label, bool isMet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? const Color(0x2E1B828C) : const Color(0x1A06171B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMet ? const Color(0xFF1B828C) : const Color(0x266B968E),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: isMet ? const Color(0xFFF2C265) : const Color(0xFF5A7974),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
              color: isMet ? const Color(0xFFF4E5C5) : const Color(0xFF7E9D98),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    VoidCallback? onSuffixTap,
    ValueChanged<String>? onSubmitted,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF06171B),
        border: Border.all(
          color: const Color(0x336B968E),
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
            nextFocusNode != null ? TextInputAction.next : textInputAction,
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
                  icon: suffixIcon,
                  onPressed: onSuffixTap,
                  splashRadius: 20,
                )
              : null,
        ),
        onSubmitted: (val) {
          if (nextFocusNode != null) {
            nextFocusNode.requestFocus();
          } else if (onSubmitted != null) {
            onSubmitted(val);
          }
        },
      ),
    );
  }
}

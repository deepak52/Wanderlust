import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/welcome_controller.dart';
import '../../gen/assets.gen.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/widget/common_widget.dart';

class WelcomeScreen extends AppBaseView<WelcomeController> {
  const WelcomeScreen({super.key});

  @override
  Widget buildView() => _widgetView();

  Scaffold _widgetView() => appScaffoldImg(
    backgroundImage: AssetImage(Assets.images.wanderlust.path),
    backgroundFit: BoxFit.cover,
    backgroundOverlayColor: Colors.black.withValues(alpha: 0.3),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
    ),
    body: FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userSnapshot.data;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<bool>(
          future: controller.hasSubmittedResponses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            snapshot.data ?? false;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 100),
                    Obx(
                      () => Text(
                        controller.welcomeMessage.value,
                        style: GoogleFonts.cinzel(
                          textStyle: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => controller.onGetStarted(),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D5A80),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

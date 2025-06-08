import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/tour_date_question_screen.dart';
import '../screens/welcome_screen.dart';

class Routes {
  static const String welcomeScreen = '/';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String tourDateQuestionScreen = '/tour';
  static const String clientHome = '/client_home';
  // Removed adminChatScreen and adminHome from here
}

final Map<String, WidgetBuilder> routes = {
  Routes.welcomeScreen: (_) => const WelcomeScreen(),
  Routes.loginScreen: (_) => const LoginScreen(),
  Routes.registerScreen: (_) => const RegisterScreen(),
  Routes.tourDateQuestionScreen: (_) => const TourDateQuestionScreen(),
  
};

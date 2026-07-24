import 'package:get/get.dart';
import 'binding/splash_binding.dart';
import 'binding/login_binding.dart';
import 'binding/register_binding.dart';
import 'binding/welcome_binding.dart';
import 'binding/tour_date_question_binding.dart';
import 'binding/admin_home_binding.dart';
import 'binding/user_list_binding.dart';
import 'binding/responses_binding.dart';
import 'binding/chat_binding.dart';
import 'binding/lock_binding.dart';
import 'view/splash/splash_screen.dart';
import 'view/login/login_screen.dart';
import 'view/register/register_screen.dart';
import 'view/welcome/welcome_screen.dart';
import 'view/tour_date_question/tour_date_question_screen.dart';
import 'view/admin/admin_home_screen.dart';
import 'view/user_list/user_list_screen.dart';
import 'view/responses/responses_screen.dart';
import 'view/chat/chat_screen.dart';
import 'view/lock/lock_screen.dart';

const splashPageRoute = '/splash';
const loginPageRoute = '/login';
const registerPageRoute = '/register';
const welcomePageRoute = '/welcome';
const adminHomePageRoute = '/admin_home';
const tourDateQuestionPageRoute = '/tour';
const userListPageRoute = '/user-list';
const responsesPageRoute = '/responses';
const chatPageRoute = '/chat';
const lockPageRoute = '/lock';

final routes = [
  GetPage(
    name: splashPageRoute,
    page: () => SplashScreen(),
    binding: SplashBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(
    name: loginPageRoute,
    page: () => LoginScreen(),
    binding: LoginBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: registerPageRoute,
    page: () => RegisterScreen(),
    binding: RegisterBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: welcomePageRoute,
    page: () => WelcomeScreen(),
    binding: WelcomeBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: adminHomePageRoute,
    page: () => AdminHomeScreen(),
    binding: AdminHomeBinding(),
    transition: Transition.cupertino,
    transitionDuration: const Duration(milliseconds: 250),
  ),
  GetPage(
    name: tourDateQuestionPageRoute,
    page: () => TourDateQuestionScreen(),
    binding: TourDateQuestionBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: userListPageRoute,
    page: () => UserListScreen(),
    binding: UserListBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: responsesPageRoute,
    page: () => ResponsesScreen(),
    binding: ResponsesBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: chatPageRoute,
    page: () => ChatScreen(),
    binding: ChatBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: lockPageRoute,
    page: () => LockScreen(),
    binding: LockBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 300),
  ),
];

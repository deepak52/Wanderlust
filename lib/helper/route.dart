import 'package:get/get.dart';
import '../binding/splash_binding.dart';
import '../binding/login_binding.dart';
import '../binding/register_binding.dart';
import '../binding/welcome_binding.dart';
import '../binding/tour_date_question_binding.dart';
import '../binding/chat_binding.dart';
import '../binding/responses_binding.dart';
import '../binding/response_detail_binding.dart';
import '../binding/user_list_binding.dart';
import '../binding/lock_binding.dart';
import '../binding/admin_home_binding.dart';
import '../binding/adventure_binding.dart';
import '../view/splash/splash_screen.dart';
import '../view/login/login_screen.dart';
import '../view/register/register_screen.dart';
import '../view/welcome/welcome_screen.dart';
import '../view/tour_date_question/tour_date_question_screen.dart';
import '../view/admin/admin_home_screen.dart';
import '../view/chat/chat_screen.dart';
import '../view/responses/responses_screen.dart';
import '../view/responses/response_detail_screen.dart';
import '../view/user_list/user_list_screen.dart';
import '../view/lock/lock_screen.dart';
import '../view/adventure/adventure_screen.dart';
import '../model/lock_model.dart';

// Route name constants - used by controllers for navigation
const splashPageRoute = '/splash';
const loginPageRoute = '/login';
const registerPageRoute = '/register';
const welcomePageRoute = '/welcome';
const tourDateQuestionPageRoute = '/tour';
const adminHomePageRoute = '/admin_home';
const chatPageRoute = '/chat';
const responsesPageRoute = '/responses';
const responseDetailPageRoute = '/response-detail';
const userListPageRoute = '/user-list';
const lockPageRoute = '/lock';
const adventurePageRoute = '/adventure';

class AppRoutes {
  static const splash = splashPageRoute;
  static const login = loginPageRoute;
  static const register = registerPageRoute;
  static const welcome = welcomePageRoute;
  static const tourDateQuestion = tourDateQuestionPageRoute;
  static const adminHome = adminHomePageRoute;
  static const chat = chatPageRoute;
  static const responses = responsesPageRoute;
  static const responseDetail = responseDetailPageRoute;
  static const userList = userListPageRoute;
  static const lock = lockPageRoute;
  static const adventure = adventurePageRoute;

  static final pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: adminHome,
      page: () => const AdminHomeScreen(),
      binding: AdminHomeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: tourDateQuestion,
      page: () => const TourDateQuestionScreen(),
      binding: TourDateQuestionBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: userList,
      page: () => const UserListScreen(),
      binding: UserListBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: responses,
      page: () => const ResponsesScreen(),
      binding: ResponsesBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: responseDetail,
      page: () => const ResponseDetailScreen(),
      binding: ResponseDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: chat,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: lock,
      page: () {
        final rawArgs = Get.arguments;
        if (rawArgs is LockArguments) {
          return LockScreen(arguments: rawArgs);
        } else if (rawArgs is Map<String, dynamic>) {
          return LockScreen(
            arguments: LockArguments(
              returnRoute: rawArgs['returnRoute'] as String?,
              returnArgs: rawArgs['returnArgs'] as Map<String, dynamic>?,
            ),
          );
        }
        return const LockScreen();
      },
      binding: LockBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: adventure,
      page: () => const AdventureScreen(),
      binding: AdventureBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}

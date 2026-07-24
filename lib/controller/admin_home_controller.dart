import 'package:get/get.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../service/auth_service.dart';

class AdminHomeController extends AppBaseController {
  final AuthService _authService = Get.find<AuthService>();

  final RxString adminMessage =
      'Welcome to the admin panel. View responses and manage users.'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  void onViewResponses() {
    Get.toNamed(responsesPageRoute);
  }

  void onViewUserList() {
    Get.toNamed(userListPageRoute);
  }

  Future<void> onLogout() async {
    await _authService.logout();
    Get.offAllNamed(loginPageRoute);
  }
}

import 'package:get/get.dart';
import '../../single_app.dart';
import '../../http_service.dart';
import 'app_base_controller.dart';

class AppBaseService {
  late AppBaseController controller;

  final HttpService httpService = Get.find<HttpService>();
  final MyApplication myApplication = Get.find<MyApplication>();

  /* -------------------- AUTH -------------------- */

  String getLoginApiEndpoint() => '/api/v1/login/index';

  /* -------------------- DELAYED PAYMENTS -------------------- */

  String getDelayedPaymentsApiEndpoint({required String token}) =>
      '/api/TropicalMobAPI/v1/DelayedPay/DelayedPayments?token=$token';

  /* -------------------- BILL SUMMARY -------------------- */

  String getDelayedPayBillSummaryApiEndpoint({required String token}) =>
      '/api/TropicalMobAPI/v1/BillSummary/DelayedPayBillDetails?token=$token';

  /*----------------------USER LOGIN -------------------*/

  String getUserLoginApiEndpoint({required String token}) =>
      '/api/TropicalMobAPI/v1/UserLogin/Login?token=$token';

  String getDashBoardApiEndpoint({required String token}) =>
      '/api/TropicalMobAPI/v1/DashBoard/DashBoard?token=$token';

  String getChangePasswordApiEndpoint({required String token}) =>
      '/api/TropicalMobAPI/v1/ChangeUserPassword/ChangePassword?token=$token';

  /* -------------------- HEADERS -------------------- */

  /// Generic headers
  /// Your API only really needs JSON
  Future<Map<String, String>> getHeaders({bool contentType = true}) async {
    final Map<String, String> headers = {};

    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }
}

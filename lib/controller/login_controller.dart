import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helper/app_message.dart';
import '../helper/app_string.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/core/environment/env.dart';
import '../helper/deviceInfo.dart';
import '../helper/enum.dart';
import '../helper/route.dart';
import '../helper/single_app.dart';
import '../model/login_model.dart';
import '../service/auth_service.dart';

class LoginController extends AppBaseController {
  final AuthService _authService = Get.find<AuthService>();

  // Loading state
  @override
  RxBool rxIsLoading = false.obs;

  // fields
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var isUserFieldFocused = false.obs;
  var isPasswordFieldFocused = false.obs;
  RxBool isUsernameValid = true.obs;
  RxBool isPasswordValid = true.obs;
  late GlobalKey<FormState> form;
  final FocusNode userFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  //new pass fields
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  final FocusNode newpasswordFocusNode = FocusNode();
  final FocusNode confirmpasswordFocusNode = FocusNode();
  RxBool isSixChar = false.obs;
  RxBool isCaps = false.obs;
  RxBool isSpecial = false.obs;
  RxBool isdigits = false.obs;

  RxBool newPassVisible = false.obs;
  RxBool confirmNewPassVisible = false.obs;

  //

  // otp
  TextEditingController otpcontroller1 = TextEditingController();
  TextEditingController otpcontroller2 = TextEditingController();
  TextEditingController otpcontroller3 = TextEditingController();
  TextEditingController otpcontroller4 = TextEditingController();
  RxString enteredOtp = ''.obs;
  //

  RxBool rxRememberMe = true.obs;
  RxBool rxhidePassword = false.obs;

  //response
  Rxn<LoginResponse> rxLoginData = Rxn<LoginResponse>();
  Rxn<LoginResponse> rxLoginResponse = Rxn<LoginResponse>();
  Rxn<UserLoginResponse> rxUserLoginResponse = Rxn<UserLoginResponse>();
  // forget
  Rxn<EmailResponse> rxMailResponse = Rxn<EmailResponse>();
  Rxn<OtpResponse> rxOtpResponse = Rxn<OtpResponse>();

  final ScrollController scrollController = ScrollController();
  final RxDouble headerHeight = 211.0.obs; // max height
  final RxDouble headerOffset = 0.0.obs;

  final RxDouble bgOffset = 0.0.obs;
  final RxBool isRibbonDone = false.obs;
  final RxBool introAnimDone = false.obs;
  final RxBool isAnyFieldFocused = false.obs;

  final RxBool didAutoScroll = false.obs;
  final RxBool moveLogo = false.obs;
  final RxDouble ribbonProgress = 0.0.obs;

  @override
  Future<void> onInit() async {
    form = GlobalKey<FormState>();

    void updateFocusState() {
      isUserFieldFocused.value =
          (userFocusNode.hasFocus || userController.text.isNotEmpty);

      isPasswordFieldFocused.value =
          (passwordFocusNode.hasFocus || passwordController.text.isNotEmpty);

      // 🔑 Single source of truth for layout compression
      isAnyFieldFocused.value =
          userFocusNode.hasFocus || passwordFocusNode.hasFocus;
    }

    userFocusNode.addListener(updateFocusState);
    passwordFocusNode.addListener(updateFocusState);

    scrollController.addListener(() {
      bgOffset.value = scrollController.offset;
    });

    // 🔑 start logo movement slightly AFTER splash shrink begins
    Future.delayed(const Duration(milliseconds: 950), () {
      moveLogo.value = true;
    });

    super.onInit();
  }

  void _devEnvSetup() {
    if (AppEnvironment.isDevMode()) {
      // userController.text = 'sidharthshibu@muziris.co.in';
      // passwordController.text = '123';
    }
  }

  Future<void> _loadStartup() async {
    var preference = myApplication.preferenceHelper;

    String? deviceId = await DeviceUtil.getDeviceId();
    if (preference != null) {
      await preference.setString(deviceIdKey, deviceId ?? '');
      if (rxRememberMe.value) {
        userController.text = preference.getString(emailKey) ?? '';
        passwordController.text = preference.getString(loginPasswordKey) ?? '';
      }
    }
  }

  void onShowPassChange() async {
    rxhidePassword.value = !rxhidePassword.value;
  }

  Future<bool> signIn() async {
    hideKeyboard();
    if (isValidCredentials()) {
      try {
        final isAdmin = await _authService.login(
          userController.text.trim(),
          passwordController.text.trim(),
        );

        // Save email and password to SharedPreferences if rememberMe is checked
        if (rxRememberMe.value) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('remembered_email', userController.text.trim());
          await prefs.setString(
            'remembered_password',
            passwordController.text.trim(),
          );
          await prefs.setBool('remember_me', true);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('remembered_email');
          await prefs.remove('remembered_password');
          await prefs.setBool('remember_me', false);
        }

        // Get the current user uid
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          // Save FCM token (already done in authService.login, but we call again to be safe)
          await _authService.saveFcmToken(uid);
        }

        // Navigate based on isAdmin
        if (isAdmin) {
          Get.offAllNamed(adminHomePageRoute);
        } else {
          Get.offAllNamed(welcomePageRoute);
        }

        return true;
      } catch (e) {
        // Show error snackbar
        Get.snackbar('Error', 'Login failed: ${e.toString()}');
        return false;
      }
    }
    return false;
  }

  bool isValidCredentials() {
    String email = userController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      isUsernameValid(false);
      isPasswordValid(false);
      return false;
    } else {
      isUsernameValid(true);
      isPasswordValid(true);
      return true;
    }
  }

  Future<String> gfPwdConvert(String chrText) async {
    final trimmed = chrText.trim();

    List<int> bytes = trimmed.codeUnits.map((c) => (c + 100) % 256).toList();

    return await CharsetConverter.decode(
      "windows-1252",
      Uint8List.fromList(bytes), // ✅ FIX HERE
    );
  }

  Future<bool> _callSignInService() async {
    try {
      showLoader();
      await Future.delayed(const Duration(milliseconds: 150));
      String username = userController.text.trim();
      String password = await gfPwdConvert(passwordController.text.trim());

      bool isAdmin = await _authService.login(username, password);
      // login returns bool (isAdmin), not LoginResponse
      rxLoginResponse.value = LoginResponse(data: 'Login successful');
      myApplication.preferenceHelper!.setString(
        accessTokenKey,
        rxLoginResponse.value!.data ?? '',
      );

      bool setProfile = await _callUserSignIn(username, password);
      //bool setProfile = true;
      return setProfile;
    } catch (e) {
      appLog('$exceptionMsg $e', logging: Logging.error);
    } finally {
      hideLoader();
    }
    return false;
  }

  Future<bool> _callUserSignIn(String name, String pass) async {
    try {
      showLoader();
      // var userLoginRequestList = [
      //   CommonRequest(attribute: "UserCode", value: name),
      //   CommonRequest(attribute: "UserPassword", value: pass),
      // ];
      UserLoginResponse? response = await _authService.userLogin(
        UserLoginRequest(userCode: name, password: pass),
      );
      if (response != null) {
        rxUserLoginResponse.value = response;
        await _saveLoginDataToPref();

        userController.clear();
        passwordController.clear();

        return true;
      }
    } catch (e) {
      appLog('$exceptionMsg $e', logging: Logging.error);
    } finally {
      hideLoader();
    }
    return false;
  }

  Future<void> _saveLoginDataToPref() async {
    if (myApplication.preferenceHelper != null) {
      inspect(rxLoginResponse.value);

      //username & pass
      myApplication.preferenceHelper!.setString(
        loginNameKey,
        userController.text.trim(),
      );
      myApplication.preferenceHelper!.setString(
        loginPasswordKey,
        passwordController.text.trim(),
      );

      //user details
      myApplication.preferenceHelper!.setString(
        userCodeKey,
        rxUserLoginResponse.value!.userCode ?? '',
      );
      myApplication.preferenceHelper!.setString(
        userNameKey,
        rxUserLoginResponse.value!.userName ?? '',
      );
      myApplication.preferenceHelper!.setString(
        userIdKey,
        (rxUserLoginResponse.value!.userId ?? "").toString(),
      );

      myApplication.preferenceHelper!.setString(
        defaultCompCodeKey,
        rxUserLoginResponse.value!.defaultCompCode ?? '',
      );

      myApplication.preferenceHelper!.setString(
        defaultBranchCodeKey,
        rxUserLoginResponse.value!.defaultBranchCode ?? '',
      );

      myApplication.preferenceHelper!.setString(
        defaultLocationIDKey,
        (rxUserLoginResponse.value!.defaultLocationId ?? "").toString(),
      );
      myApplication.preferenceHelper!.setString(
        designationKey,
        rxUserLoginResponse.value!.designation ?? '',
      );

      // token
      myApplication.preferenceHelper!.setString(
        accessTokenKey,
        rxLoginResponse.value!.data ?? '',
      );

      //remember me
      myApplication.preferenceHelper!.setBool(
        rememberMeKey,
        rxRememberMe.value,
      );
    }
  }

  Future<String> combineOTP() async {
    String value1 = otpcontroller1.text;
    String value2 = otpcontroller2.text;
    String value3 = otpcontroller3.text;
    String value4 = otpcontroller4.text;
    enteredOtp.value = '$value1$value2$value3$value4';
    appLog('ENTEREDOTP:${enteredOtp.value} ');
    otpcontroller1.clear();
    otpcontroller2.clear();
    otpcontroller3.clear();
    otpcontroller4.clear();
    return enteredOtp.value;
  }

  void isValidPass(String value) {
    final pass = value.trim();

    // ✅ Must have at least 6 characters
    isSixChar(pass.length >= 6);

    // ✅ Must have both uppercase and lowercase letters
    final hasUpper = pass.contains(RegExp(r'[A-Z]'));
    final hasLower = pass.contains(RegExp(r'[a-z]'));
    isCaps(hasUpper && hasLower);

    // ✅ Must have at least one digit
    isdigits(pass.contains(RegExp(r'[0-9]')));

    // ✅ Must have at least one special character
    isSpecial(pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')));
  }

  void resetValidation() {
    isSixChar(false);
    isCaps(false);
    isdigits(false);
    isSpecial(false);
  }

  void toggleVisibility() {
    newPassVisible.value = !newPassVisible.value;
  }

  Future<bool> fetchInitData() async {
    await _loadStartup();
    _devEnvSetup();

    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_string.dart';
import 'core/theme/color_helper.dart';
import 'core/environment/env.dart';
import 'enum.dart';
import 'single_app.dart';
import 'widget/common_widget.dart';

void showSuccessSnackbar({
  String? title,
  required String message,
  Duration? duration = const Duration(seconds: 3),
}) {
  title ??= success.tr;
  showCustomSnackbar(
    title: title,
    message: message,
    duration: duration,
    isSuccess: true,
  );
}

void showErrorSnackbar({
  String? title,
  required String message,
  Duration? duration = const Duration(seconds: 3),
}) {
  title ??= failureTitle.tr;
  showCustomSnackbar(
    title: title,
    message: message,
    duration: duration,
    isSuccess: false,
  );
}

void showCustomSnackbar({
  required String title,
  required String message,
  bool isSuccess = true,
  Duration? duration = const Duration(seconds: 3),
  String? imageAsset,
  VoidCallback? closePressed,
}) {
  Get.closeAllSnackbars();
  Get.snackbar(
    '',
    '',
    backgroundColor:
        isSuccess ? AppColorHelper.cardColor : AppColorHelper.cardColor,
    snackPosition: SnackPosition.TOP,
    duration: duration,
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
    borderRadius: 6,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    barBlur: 10,
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    dismissDirection: DismissDirection.vertical,
    overlayColor: Colors.transparent,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    titleText: Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isSuccess
                ? Icon(
                  Icons.warning_amber_rounded,
                  color: AppColorHelper.unreadNotification,
                )
                : Icon(
                  Icons.warning,
                  color: AppColorHelper.unreadNotification,
                  size: 18,
                ),
            const SizedBox(width: 10),
            Expanded(
              child: appText(
                title,
                fontWeight: FontWeight.w600,
                color: AppColorHelper.primaryTextColor,
                fontSize: 17,
              ),
            ),
          ],
        ),
        Positioned(
          right: 5,
          top: 2,
          child: InkWell(
            onTap: () {
              Get.closeCurrentSnackbar();
              if (closePressed != null) closePressed();
            },
            child: Icon(
              Icons.close,
              size: 20,
              color: AppColorHelper.primaryTextColor.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    ),
    messageText: Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: appText(
        message,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColorHelper.primaryTextColor,
      ),
    ),
  );
}

void showPopupDialog({
  required String title,
  required String content,
  String? positiveButtonText,
  String? negativeButtonText,
  bool showNegativeButton = true,
  VoidCallback? onPositivePressed,
  VoidCallback? onNegativePressed,
}) {
  positiveButtonText ??= ok.tr;
  negativeButtonText ??= cancel.tr;
  Get.defaultDialog(
    title: title,
    barrierDismissible: false,
    content: Text(content),
    textConfirm: positiveButtonText,
    textCancel: showNegativeButton ? negativeButtonText : null,
    onConfirm: onPositivePressed ?? () {},
    onCancel: showNegativeButton ? onNegativePressed : null,
  );
}

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  String? positiveButtonText,
  String? negativeButtonText,
  bool showNegative = false,
  Function()? onPositiveButtonPressed,
  Function()? onNegativeButtonPressed,
}) {
  positiveButtonText ??= ok.tr;
  negativeButtonText ??= cancel.tr;
  showDialog(
    context: context,
    builder:
        (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            Visibility(
              visible: showNegative,
              child: ElevatedButton(
                onPressed:
                    onNegativeButtonPressed ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: Text(negativeButtonText!),
              ),
            ),
            ElevatedButton(
              onPressed:
                  onPositiveButtonPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
              child: Text(positiveButtonText!),
            ),
          ],
        ),
  );
}

void appLog(dynamic value, {Logging logging = Logging.debug}) {
  if (AppEnvironment.config.enableLogs) {
    switch (logging) {
      case Logging.debug:
        misDebugMessage(value);
        break;
      case Logging.info:
        misInfoMessage(value);
        break;
      case Logging.warning:
        misWarningMessage(value);
        break;
      case Logging.error:
        misErrorMessage(value);
        break;
    }
  }
}

void toastMessage(String message) {
  // Fluttertoast.showToast(msg: message);
}

void misDebugMessage(dynamic value) {
  Get.find<MyApplication>().logger.d('Logger Debug: $value');
}

void misInfoMessage(dynamic value) {
  Get.find<MyApplication>().logger.i('Logger Info: $value');
}

void misErrorMessage(dynamic value) {
  Get.find<MyApplication>().logger.e('Logger Error: $value');
}

void misWarningMessage(dynamic value) {
  Get.find<MyApplication>().logger.w('Logger Warning: $value');
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../helper/app_string.dart';
import '../../../../helper/core/theme/color_helper.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helper/core/base/app_base_response.dart';
import '../../../../helper/sizer.dart';
import '../../../../helper/widget/common_widget.dart';

class HttpErrorListDialog extends StatelessWidget {
  final List<ResponseError> errors;
  const HttpErrorListDialog({super.key, required this.errors});

  @override
  Widget build(BuildContext context) => _buildDialog(context);

  AlertDialog _buildDialog(BuildContext context) => AlertDialog(
    backgroundColor: AppColorHelper.dialogBackgroundColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    elevation: 1,
    contentPadding: const EdgeInsets.all(18),
    content: SizedBox(
      width: Get.width,
      height: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Image.asset(Assets.icons.warning.path, scale: 4),
          height(50),

          // Error message
          if (errors.isNotEmpty)
            appText(
              "${errors[0].message}",
              color: AppColorHelper.primaryTextColor,
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          height(5),
          if (errors.length > 1 && errors[1].isBlank == false)
            appText(
              "${errors[1].message}",
              textAlign: TextAlign.center,
              color: AppColorHelper.primaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),

          height(50),

          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: buttonContainer(
              color: AppColorHelper.primaryColor,
              height: 40,
              radius: 4,
              appText(
                errors[0].message!.contains("credentials")
                    ? tryAgain.tr
                    : close.tr,
                color: AppColorHelper.textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    ),
  );
}

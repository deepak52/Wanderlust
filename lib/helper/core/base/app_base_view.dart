import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../../gen/assets.gen.dart';
import '../../core/theme/color_helper.dart';
import '../../core/theme/sizer.dart';
import 'app_base_controller.dart';

abstract class AppBaseView<T extends AppBaseController> extends GetView<T> {
  /// The widget to be shown as a progress indicator. Defaults to [CircularProgressIndicator].
  final Widget? progressDialogWidget;

  /// Constructs a [BaseView] with an optional [progressDialogWidget].
  ///
  /// [progressDialogWidget]: The widget to be shown as a progress indicator.
  const AppBaseView({super.key, this.progressDialogWidget});

  /// Builds the view with the common structure, including error handling and loading indicators.
  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    return controller.rxDefaultBaseViewObx.value
        ? Obx(() {
          if (controller.rxShowError.value.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorPopup(context);
            });
          }
          return _widgetView();
        })
        : _widgetView();
  }

  Stack _widgetView() => Stack(
    children: [
      buildView(),
      if (controller.rxIsLoading.value) // Show loader conditionally
        progressDialogWidget ??
            Positioned.fill(
              child: Container(
                color: AppColorHelper.primaryColor.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.images.wanderlust.path,
                      width: 200,
                      height: 70,
                    ),
                    SizedBox(height: height(10)),
                    SizedBox(
                      width: 30,
                      child: LoadingIndicator(
                        indicatorType: Indicator.lineScalePulseOutRapid,
                        colors: [AppColorHelper.loaderColor],
                        strokeWidth: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    ],
  );

  /// Builds the main view content.
  Widget buildView();

  /// Shows an error popup dialog with the provided error message.
  void _showErrorPopup(BuildContext context) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Error',
      middleText: controller.rxShowError.value,
      confirm: ElevatedButton(
        onPressed: () {
          controller.rxShowError(''); // Hide the error
          Get.back(); // Close the dialog
        },
        child: const Text('OK'),
      ),
    );
  }
}

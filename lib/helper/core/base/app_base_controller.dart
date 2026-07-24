import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:getx_base_classes/getx_base_classes.dart';

abstract class AppBaseController extends BaseController {
  var debouncer = Debouncer(delay: const Duration(milliseconds: 200));

  final rxDataChange = true.obs;
  var rxDefaultBaseViewObx = false.obs;
  RxBool isDarkTheme = false.obs;

  dynamic handleBaseResponse(dynamic response) {
    if (response != null) {
      if (response is Map && response['success'] == true) {
        return response['data'];
      }
    }
    return null;
  }

  bool isListNullOrEmpty(List<dynamic>? list) => list == null || list.isEmpty;

  bool isStringNullOrEmpty(String? value) => value == null || value.isEmpty;

  void hideKeyboard() => FocusScope.of(Get.context!).requestFocus(FocusNode());

  void showErrorListDialog(List<String> errors) => showDialog(
    context: Get.context!,
    builder:
        (context) => AlertDialog(
          title: const Text('Errors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: errors.map((e) => Text(e)).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
  );

  Future<void> delay({int milliseconds = 200}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  bool isPortraitMode() => Get.context!.orientation == Orientation.portrait;
}

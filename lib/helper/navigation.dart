// navigation.dart
// Wanderlust Navigation Helper - Following Agro-Prod patterns

import 'package:get/get.dart';

import 'enum.dart';
import 'app_message.dart';

/// Navigate to a screen with optional arguments
void navigateTo(
  String routeName, {
  dynamic arguments,
  Transition transition = Transition.fadeIn,
}) {
  appLog('Screen: $routeName arguments: $arguments', logging: Logging.info);
  Get.toNamed(routeName, arguments: arguments);
}

/// Navigate back to the previous screen
void goBack() {
  Get.back();
}

/// Navigate to a screen and remove all previous screens from the stack
void navigateToAndRemoveAll(
  String routeName, {
  dynamic arguments,
  Transition transition = Transition.fadeIn,
}) {
  appLog('Screen: $routeName arguments: $arguments', logging: Logging.info);
  Get.offAllNamed(routeName, arguments: arguments);
}

/// Navigate to a screen and remove the previous screen from the stack
void navigateToAndRemove(
  String routeName, {
  dynamic arguments,
  Transition transition = Transition.fadeIn,
}) {
  appLog('Screen: $routeName arguments: $arguments', logging: Logging.info);
  Get.offNamed(routeName, arguments: arguments);
}

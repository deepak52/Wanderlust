// splash_binding.dart
// Splash Binding - Dependency injection for Splash Screen
// Follows Agro-Prod patterns: extends BaseBinding, uses injectDependencies with fenix

import 'package:get/get.dart';
import 'package:getx_base_classes/getx_base_classes.dart';

import '../controller/splash_controller.dart';
import '../service/auth_service.dart';
import '../service/active_chat_tracker.dart';
import '../service/chat_sound_player.dart';
import '../service/missed_message_service.dart';
import '../helper/firebase_messaging_service.dart';

class SplashBinding extends BaseBinding {
  const SplashBinding();

  @override
  void injectDependencies() {
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<ActiveChatTracker>(() => ActiveChatTracker(), fenix: true);
    Get.lazyPut<ChatSoundPlayer>(() => ChatSoundPlayer(), fenix: true);
    Get.lazyPut<MissedMessageService>(
      () => MissedMessageService(),
      fenix: true,
    );
    Get.lazyPut<FirebaseMessagingService>(
      () => FirebaseMessagingService(),
      fenix: true,
    );
  }
}

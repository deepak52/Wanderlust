// chat_sound_player.dart
// Chat Sound Player - Migrated from Wanderlust
// Follows Agro-Prod patterns: GetX service for sound playback

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

import '../helper/app_message.dart';

/// Service to play chat send/receive sounds
/// Uses separate AudioPlayer instances for concurrent playback
class ChatSoundPlayer extends GetxService {
  static ChatSoundPlayer get instance => Get.find<ChatSoundPlayer>();

  final AudioPlayer _sendPlayer = AudioPlayer();
  final AudioPlayer _receivePlayer = AudioPlayer();

  /// Play the send sound
  Future<void> playSendSound() async {
    try {
      await _sendPlayer.play(AssetSource('sounds/send.wav'));
      misInfoMessage('≡ƒöè ChatSoundPlayer: Send sound played');
    } catch (e) {
      misErrorMessage('≡ƒöè ChatSoundPlayer: Send sound error: $e');
    }
  }

  /// Play the receive sound
  Future<void> playReceiveSound() async {
    try {
      await _receivePlayer.play(AssetSource('sounds/recive.mp3'));
      misInfoMessage('ChatSoundPlayer: Receive sound played');
    } catch (e) {
      misErrorMessage('≡ƒöè ChatSoundPlayer: Receive sound error: $e');
    }
  }

  /// Dispose audio players
  @override
  void onClose() {
    _sendPlayer.dispose();
    _receivePlayer.dispose();
    misInfoMessage('≡ƒöè ChatSoundPlayer: Disposed audio players');
    super.onClose();
  }
}
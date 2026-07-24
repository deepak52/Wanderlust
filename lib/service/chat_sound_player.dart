// chat_sound_player.dart
// Chat Sound Player - Following Agro-Prod patterns

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Chat Sound Player - Handles playing send/receive sounds
class ChatSoundPlayer {
  static ChatSoundPlayer? _instance;
  final AudioPlayer _sendPlayer = AudioPlayer();
  final AudioPlayer _receivePlayer = AudioPlayer();
  bool _initialized = false;

  /// Get singleton instance
  static ChatSoundPlayer get instance {
    _instance ??= ChatSoundPlayer._internal();
    return _instance!;
  }

  ChatSoundPlayer._internal();

  /// Initialize sound players
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load sound assets - replace with actual asset paths
      await _sendPlayer.setSource(AssetSource('sounds/send.mp3'));
      await _receivePlayer.setSource(AssetSource('sounds/receive.mp3'));
      _initialized = true;
    } catch (e) {
      // Sounds not available, continue without sounds
      debugPrint('ChatSoundPlayer: Could not load sounds: $e');
    }
  }

  /// Play send sound
  Future<void> playSendSound() async {
    if (!_initialized) return;
    try {
      await _sendPlayer.seek(Duration.zero);
      await _sendPlayer.resume();
    } catch (e) {
      debugPrint('ChatSoundPlayer: Error playing send sound: $e');
    }
  }

  /// Play receive sound
  Future<void> playReceiveSound() async {
    if (!_initialized) return;
    try {
      await _receivePlayer.seek(Duration.zero);
      await _receivePlayer.resume();
    } catch (e) {
      debugPrint('ChatSoundPlayer: Error playing receive sound: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _sendPlayer.dispose();
    _receivePlayer.dispose();
  }
}

import 'package:audioplayers/audioplayers.dart';

class ChatSoundPlayer {
  static final AudioPlayer _sendPlayer = AudioPlayer();
  static final AudioPlayer _receivePlayer = AudioPlayer();

  static Future<void> playSendSound() async {
    try {
      await _sendPlayer.play(AssetSource('sounds/send.wav'));
    } catch (e) {
      print('Send sound error: $e');
    }
  }

  static Future<void> playReceiveSound() async {
    try {
      await _receivePlayer.play(AssetSource('sounds/recive.mp3'));
    } catch (e) {
      print('Receive sound error: $e');
    }
  }
}

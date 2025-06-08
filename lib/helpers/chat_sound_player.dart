import 'package:audioplayers/audioplayers.dart';

class ChatSoundPlayer {
  static Future<void> playSendSound() async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sounds/send.wav'));
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
    } catch (e) {
      print('Send sound error: $e');
      player.dispose();
    }
  }

  static Future<void> playReceiveSound() async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sounds/recive.mp3'));
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
    } catch (e) {
      print('Receive sound error: $e');
      player.dispose();
    }
  }
}

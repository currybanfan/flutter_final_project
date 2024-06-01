import 'package:flutter_tts/flutter_tts.dart';

class TtsModel {
  late FlutterTts flutterTts;
  String? language;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;

  TtsModel() {
    initTts();
  }

  void initTts() {
    flutterTts = FlutterTts();

    // 設置等待語音合成完成選項
    flutterTts.awaitSpeakCompletion(true);

    // 設置默認語言
    language = "en-US";
    flutterTts.setLanguage(language!);
  }

  Future<void> speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;
}

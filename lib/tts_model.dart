import 'package:flutter_tts/flutter_tts.dart';

// 定義 TtsModel 類，用來封裝 TTS（文本轉語音）的功能
class TtsModel {
  // 宣告 FlutterTts 物件
  late FlutterTts flutterTts;
  // 宣告語言變數
  String? language;
  // 設置音量、音調和速度的默認值
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;

  // 構造函數，初始化 TTS 設置
  TtsModel() {
    initTts();
  }

  // 初始化 TTS 設置的方法
  void initTts() {
    // 創建 FlutterTts 物件
    flutterTts = FlutterTts();

    // 設置等待語音合成完成選項
    flutterTts.awaitSpeakCompletion(true);

    // 設置默認語言
    language = "en-US";
    flutterTts.setLanguage(language!);
  }

  // 說話方法，將傳入的文字轉換為語音
  Future<void> speak(String text) async {
    // 設置音量
    await flutterTts.setVolume(volume);
    // 設置語速
    await flutterTts.setSpeechRate(rate);
    // 設置音調
    await flutterTts.setPitch(pitch);

    // 如果文本不為空，則合成語音
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  // 獲取可用語言列表的方法
  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;
}

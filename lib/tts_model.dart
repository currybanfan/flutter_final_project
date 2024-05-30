import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

enum TtsState { playing, stopped, paused, continued }

class TtsModel extends ChangeNotifier {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  String? voice;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 1.0;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? inputLength;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  TtsModel() {
    initTts();
  }

  void initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _initializeAndroidTts();
    } else {
      _setDefaultLanguage();
    }

    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setCancelHandler(() {
      ttsState = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setPauseHandler(() {
      ttsState = TtsState.paused;
      notifyListeners();
    });

    flutterTts.setContinueHandler(() {
      ttsState = TtsState.continued;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
      notifyListeners();
    });
  }

  Future<void> _initializeAndroidTts() async {
    await _getDefaultEngine();
    await _setDefaultLanguage();
    await _setDefaultVoice();
  }

  Future<void> _setDefaultLanguage() async {
    language = "en-US";
    await flutterTts.setLanguage(language!);
    if (isAndroid) {
      isCurrentLanguageInstalled =
          await flutterTts.isLanguageInstalled(language!);
      notifyListeners();
    }
  }

  Future<void> _setDefaultVoice() async {
    await flutterTts.setVoice({"name": "en-us-x-tpf-local", "locale": "en-US"});
    // var voices = await flutterTts.getVoices;
    // print(voices);
    // if (voices != null && voices.isNotEmpty) {
    //   voice = voices.first['name'];
    //   await flutterTts.setVoice(voice!);
    //   notifyListeners();
    // }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _getDefaultEngine() async {
    engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      await flutterTts.setEngine(engine!);
      notifyListeners();
    }
  }

  Future<void> speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null && _newVoiceText!.isNotEmpty) {
      await flutterTts.speak(_newVoiceText!);
    }
  }

  Future<void> stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    var result = await flutterTts.pause();
    if (result == 1) {
      ttsState = TtsState.paused;
      notifyListeners();
    }
  }

  Future<void> setVoiceText(String text) async {
    _newVoiceText = text;
    notifyListeners();
  }

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> getEngines() async => await flutterTts.getEngines;

  Future<void> changedLanguage(String? selectedType) async {
    language = selectedType;
    await flutterTts.setLanguage(language!);
    if (isAndroid) {
      isCurrentLanguageInstalled =
          await flutterTts.isLanguageInstalled(language!);
      notifyListeners();
    }
  }

  Future<void> changedEngine(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    engine = selectedEngine;
    await _setDefaultLanguage(); // 設置默認語言
    await _setDefaultVoice(); // 設置默認聲音
    notifyListeners();
  }
}

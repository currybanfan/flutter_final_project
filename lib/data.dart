import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VocabularyEntry {
  final int letterCount;
  final String word;
  final List<Definition> definitions;

  VocabularyEntry(
      {required this.letterCount,
      required this.word,
      required this.definitions});

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) {
    var list = json['definitions'] as List;
    List<Definition> definitionsList =
        list.map((i) => Definition.fromJson(i)).toList();
    return VocabularyEntry(
      letterCount: json['letterCount'],
      word: json['word'],
      definitions: definitionsList,
    );
  }
}

class Definition {
  final String text;
  final String partOfSpeech;

  Definition({required this.text, required this.partOfSpeech});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      text: json['text'],
      partOfSpeech: json['partOfSpeech'],
    );
  }
}

class VocabularyProvider extends ChangeNotifier {
  final Map<String, List<VocabularyEntry>> _vocabularyMap = {};
  final List<String> levels = [
    '國一',
    '國二',
    '國三',
    '1級',
    '2級',
    '3級',
    '4級',
    '5級',
    '6級'
  ];

  List<String> getLevels() {
    return levels;
  }

  List<VocabularyEntry>? getVocabulary(String level) {
    return _vocabularyMap[level];
  }

  Future<void> fetchVocabulary(String level) async {
    if (!_vocabularyMap.containsKey(level)) {
      var url = Uri.parse(
          'https://raw.githubusercontent.com/AppPeterPan/TaiwanSchoolEnglishVocabulary/main/$level.json');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<VocabularyEntry> vocabularyList =
            jsonResponse.map((data) => VocabularyEntry.fromJson(data)).toList();
        _vocabularyMap[level] = vocabularyList;
        notifyListeners();
      } else {
        throw Exception('Failed to load vocabulary for $level');
      }
    }
  }
}

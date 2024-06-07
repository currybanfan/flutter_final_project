import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../vocabulary.dart';
import 'supabase_provider.dart';

class VocabularyProvider extends ChangeNotifier {
  final SupabaseProvider _supabaseProvider;
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
    '6級',
    '筆記'
  ];

  VocabularyProvider(this._supabaseProvider);

  List<String> getLevels() {
    return levels;
  }

  Future<List<VocabularyEntry>?> getVocabulary(String level) async {
    print('level: $level');
    try {
      // if (level == '全部') {
      //   if (_vocabularyMap.length < levels.length - 1) {
      //     await Future.wait(levels
      //         .where((level) => level != '全部')
      //         .map((level) => fetchVocabulary(level)));
      //   }
      //   return _vocabularyMap.values.expand((list) => list).toList();
      // } else
      if (level == '筆記') {
        var notes = await _supabaseProvider.getNotes();

        return notes.map((note) => note.vocabularyEntry).toList();
      } else {
        await fetchVocabulary(level);
        return _vocabularyMap[level];
      }
    } catch (e) {
      rethrow;
      // print(e);
    }
    return null;
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

  Future<VocabularyEntry> loadRandomEntry(List<String> levels) async {
    List<VocabularyEntry> allEntries = [];

    try {
      for (var level in levels) {
        final entries = await getVocabulary(level);
        if (entries != null) {
          allEntries.addAll(entries);
        }
      }
    } catch (e) {
      rethrow;
    }

    if (allEntries.isNotEmpty) {
      final random = Random();
      return allEntries[random.nextInt(allEntries.length)];
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
      throw ('找不到單字');
    }
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../vocabulary.dart';
import 'supabase_provider.dart';

// VocabularyProvider 類，用於管理詞彙數據
class VocabularyProvider extends ChangeNotifier {
  // SupabaseProvider 的實例，用於訪問和管理用戶數據
  final SupabaseProvider _supabaseProvider;
  // 詞彙地圖，根據級別存儲詞彙列表
  final Map<String, List<VocabularyEntry>> _vocabularyMap = {};
  // 可用的級別列表
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

  // 構造函數，初始化 SupabaseProvider
  VocabularyProvider(this._supabaseProvider);

  // 獲取級別列表的方法
  List<String> getLevels() {
    return levels;
  }

  // 獲取指定級別的詞彙列表
  Future<List<VocabularyEntry>?> getVocabulary(String level) async {
    try {
      if (level == '筆記') {
        // 如果級別為 '筆記'，從 SupabaseProvider 獲取筆記
        var notes = await _supabaseProvider.getNotes();
        return notes.map((note) => note.vocabularyEntry).toList();
      } else {
        // 否則從遠端服務器獲取詞彙數據
        await fetchVocabulary(level);
        return _vocabularyMap[level];
      }
    } catch (e) {
      rethrow;
    }
  }

  // 從遠端服務器獲取指定級別的詞彙數據
  Future<void> fetchVocabulary(String level) async {
    if (!_vocabularyMap.containsKey(level)) {
      // 構建請求 URL
      var url = Uri.parse(
          'https://raw.githubusercontent.com/AppPeterPan/TaiwanSchoolEnglishVocabulary/main/$level.json');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // 解析響應 JSON 並轉換為 VocabularyEntry 列表
        List<dynamic> jsonResponse = json.decode(response.body);
        List<VocabularyEntry> vocabularyList =
            jsonResponse.map((data) => VocabularyEntry.fromJson(data)).toList();
        // 將詞彙列表存儲到 _vocabularyMap 中
        _vocabularyMap[level] = vocabularyList;
        notifyListeners();
      } else {
        throw Exception('Failed to load vocabulary for $level');
      }
    }
  }

  // 加載隨機詞彙的方法
  Future<VocabularyEntry> loadRandomEntry(List<String> levels) async {
    // 存儲所有詞彙的列表
    List<VocabularyEntry> allEntries = [];

    try {
      for (var level in levels) {
        // 獲取每個級別的詞彙列表並合併到 allEntries 中
        final entries = await getVocabulary(level);
        if (entries != null) {
          allEntries.addAll(entries);
        }
      }
    } catch (e) {
      rethrow;
    }

    if (allEntries.isNotEmpty) {
      // 如果詞彙列表不為空，隨機返回一個詞彙
      final random = Random();
      return allEntries[random.nextInt(allEntries.length)];
    } else {
      // 如果詞彙列表為空，拋出異常
      await Future.delayed(const Duration(milliseconds: 100));
      throw ('找不到單字');
    }
  }
}

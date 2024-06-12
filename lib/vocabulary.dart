import 'dart:convert';

// 定義詞彙條目類
class VocabularyEntry {
  // 詞彙的字母數量
  final int letterCount;
  // 詞彙
  final String word;
  // 詞彙的定義列表
  final List<Definition> definitions;

  // 構造函數，使用必須參數初始化詞彙條目
  VocabularyEntry({
    required this.letterCount,
    required this.word,
    required this.definitions,
  });

  // 從 JSON 創建 VocabularyEntry 的工廠構造函數
  factory VocabularyEntry.fromJson(Map<String, dynamic> json) {
    // 將 JSON 中的定義列表轉換為 Definition 類型的列表
    final list = json['definitions'] as List;
    List<Definition> definitionsList =
        list.map((i) => Definition.fromJson(i)).toList();

    return VocabularyEntry(
      letterCount: json['letterCount'],
      word: json['word'],
      definitions: definitionsList,
    );
  }

  // 從資料庫的 JSON 創建 VocabularyEntry 的工廠構造函數
  factory VocabularyEntry.fromDB(Map<String, dynamic> json) {
    // 解碼定義的 JSON 字串
    final list = jsonDecode(json['definitions']) as List;
    List<Definition> definitionsList =
        list.map((i) => Definition.fromJson(i)).toList();

    return VocabularyEntry(
      letterCount: json['letter_count'],
      word: json['word'],
      definitions: definitionsList,
    );
  }
}

// 定義詞彙的定義類
class Definition {
  // 定義文本
  final String text;
  // 詞性
  final String partOfSpeech;

  // 構造函數，使用必須參數初始化定義
  Definition({required this.text, required this.partOfSpeech});

  // 從 JSON 創建 Definition 的工廠構造函數
  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      text: json['text'],
      partOfSpeech: json['partOfSpeech'],
    );
  }

  // 將 Definition 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'partOfSpeech': partOfSpeech,
    };
  }
}

// 定義筆記類
class Note {
  // 詞彙條目
  final VocabularyEntry vocabularyEntry;
  // 可選的筆記文本
  final String? note;

  // 構造函數，使用必須參數初始化筆記
  Note({required this.vocabularyEntry, required this.note});

  // 從資料庫的 JSON 創建 Note 的工廠構造函數
  factory Note.fromDB(Map<String, dynamic> json) {
    return Note(
      vocabularyEntry: VocabularyEntry.fromDB(json),
      note: json['note'],
    );
  }
}

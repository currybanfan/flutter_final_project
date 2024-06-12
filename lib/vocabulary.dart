import 'dart:convert';

class VocabularyEntry {
  final int letterCount;
  final String word;
  final List<Definition> definitions;

  VocabularyEntry(
      {required this.letterCount,
      required this.word,
      required this.definitions});

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) {
    final list = json['definitions'] as List;

    List<Definition> definitionsList =
        list.map((i) => Definition.fromJson(i)).toList();

    return VocabularyEntry(
      letterCount: json['letterCount'],
      word: json['word'],
      definitions: definitionsList,
    );
  }

  factory VocabularyEntry.fromDB(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'partOfSpeech': partOfSpeech,
    };
  }
}

class Note {
  final VocabularyEntry vocabularyEntry;
  final String? note;

  Note({required this.vocabularyEntry, required this.note});

  factory Note.fromDB(Map<String, dynamic> json) {
    return Note(
      vocabularyEntry: VocabularyEntry.fromDB(json),
      note: json['note'],
    );
  }
}

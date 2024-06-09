import 'dart:convert';
import 'providers/vocabulary_provider.dart';
import 'package:flutter/material.dart';
import 'snack_bar.dart';
import 'package:provider/provider.dart';
import 'providers/supabase_provider.dart';
import 'tts_model.dart';

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

class VocabularyDialog extends StatelessWidget {
  final VocabularyEntry? entry;

  const VocabularyDialog({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final supabaseProvider =
        Provider.of<SupabaseProvider>(context, listen: false);
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);

    final theme = Theme.of(context);

    return AlertDialog(
      title: Center(
        child: Text(
          entry?.word ?? "",
          style: theme.textTheme.bodyLarge,
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.5, // 設置高度上限為屏幕高度的60%
        ),
        child: SingleChildScrollView(
          child: Column(
            children: entry?.definitions.map((definition) {
                  return Column(
                    children: [
                      Center(
                        child: Text(
                          definition.partOfSpeech,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Center(
                        child: Text(
                          definition.text,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 10.0), // 定義之間的間隔
                    ],
                  );
                }).toList() ??
                [],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          color: theme.colorScheme.primaryContainer,
          onPressed: () {
            var ttsModel = TtsModel();
            ttsModel.speak(entry?.word ?? "");
          },
        ),
        FutureBuilder<List<VocabularyEntry>?>(
          future: vocabularyProvider.getVocabulary('筆記'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final isSaved =
                  snapshot.data?.any((note) => note.word == entry?.word) ??
                      false;
              return IconButton(
                icon: Icon(isSaved ? Icons.delete_rounded : Icons.save_rounded),
                color: theme.colorScheme.primaryContainer,
                disabledColor: Colors.grey,
                onPressed: supabaseProvider.isLoggedIn
                    ? () async {
                        try {
                          if (isSaved) {
                            await supabaseProvider.deleteNote(entry);
                            if (context.mounted) {
                              showTopSnackBar(
                                  context, '刪除成功', SnackBarType.success);
                              Navigator.of(context).pop(true);
                            }
                          } else {
                            await supabaseProvider.saveNote(entry);
                            if (context.mounted) {
                              showTopSnackBar(
                                  context, '儲存成功', SnackBarType.success);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showTopSnackBar(
                                context, e.toString(), SnackBarType.failure);
                          }
                        }
                      }
                    : null,
              );
            }
          },
        ),
      ],
    );
  }
}

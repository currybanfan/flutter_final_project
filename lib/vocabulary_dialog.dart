import 'providers/vocabulary_provider.dart';
import 'package:flutter/material.dart';
import 'snack_bar.dart';
import 'package:provider/provider.dart';
import 'providers/supabase_provider.dart';
import 'tts_model.dart';
import 'vocabulary.dart';

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
          maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                              Navigator.of(context).pop(true);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supabase_provider.dart';
import '../vocabulary.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseProvider = Provider.of<SupabaseProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: FutureBuilder<List<Note>>(
        future: supabaseProvider.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('test error');
            return Center(
                child: Text(
              '${snapshot.error}',
              style: theme.textTheme.bodyLarge,
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child:
                    Text('No notes found', style: theme.textTheme.bodyLarge));
          } else {
            final notes = snapshot.data!;
            return ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(
                    note.vocabularyEntry.word,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    note.vocabularyEntry.definitions
                        .map((e) => e.text)
                        .join(', '),
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          VocabularyDialog(entry: note.vocabularyEntry),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

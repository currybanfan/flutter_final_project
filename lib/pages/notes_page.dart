import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supabase_provider.dart';
import '../vocabulary.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  late Future<List<Note>> _notesFuture;
  String searchQuery = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _notesFuture =
        Provider.of<SupabaseProvider>(context, listen: false).getNotes();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabaseProvider = Provider.of<SupabaseProvider>(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Notes',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  focusNode: _focusNode,
                  showCursor: _focusNode.hasFocus,
                  cursorColor: theme.colorScheme.onPrimary,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.colorScheme.onPrimary),
                  decoration: InputDecoration(
                    hintText: '搜尋單字',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 11.0),
                    hintStyle: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.colorScheme.onPrimary),
                    prefixIcon:
                        Icon(Icons.search, color: theme.colorScheme.onPrimary),
                  ),
                  onChanged: updateSearchQuery,
                  onEditingComplete: () {
                    _focusNode.unfocus(); // 當鍵盤消失時取消焦點
                  },
                ),
              )
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: FutureBuilder<List<Note>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
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
              var notes = snapshot.data!;

              if (searchQuery.isNotEmpty) {
                notes = notes
                    .where((note) =>
                        note.vocabularyEntry.word.contains(searchQuery) ||
                        note.vocabularyEntry.definitions.any((definition) =>
                            definition.text.contains(searchQuery)))
                    .toList();
              }

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
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) =>
                            VocabularyDialog(entry: note.vocabularyEntry),
                      );
                      if (result == true) {
                        setState(() {
                          _notesFuture = supabaseProvider.getNotes();
                        });
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

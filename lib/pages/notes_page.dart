import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supabase_provider.dart';
import '../vocabulary.dart';
import '../vocabulary_dialog.dart';

// NotesPage 類，用於顯示筆記頁面
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  NotesPageState createState() => NotesPageState();
}

// NotesPageState 類，用於管理筆記頁面的狀態
class NotesPageState extends State<NotesPage> {
  // 用來存儲筆記的 Future
  late Future<List<Note>> _notesFuture;
  // 搜尋的查詢字串
  String searchQuery = '';
  // 焦點控制器，用來管理搜尋框的焦點
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 初始化時獲取筆記
    _notesFuture =
        Provider.of<SupabaseProvider>(context, listen: false).getNotes();

    // 添加焦點變化監聽器
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

  // 更新搜尋查詢的方法
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
              // 搜尋框
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
        // 顯示筆記列表
        body: FutureBuilder<List<Note>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 如果數據仍在加載，顯示進度指示器
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // 如果出現錯誤，顯示錯誤信息
              return Center(
                  child: Text(
                '${snapshot.error}',
                style: theme.textTheme.bodyLarge,
              ));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // 如果沒有筆記，顯示提示信息
              return Center(
                  child:
                      Text('No notes found', style: theme.textTheme.bodyLarge));
            } else {
              var notes = snapshot.data!;

              // 如果有搜尋查詢，過濾筆記
              if (searchQuery.isNotEmpty) {
                notes = notes
                    .where((note) =>
                        note.vocabularyEntry.word.contains(searchQuery) ||
                        note.vocabularyEntry.definitions.any((definition) =>
                            definition.text.contains(searchQuery)))
                    .toList();
              }

              // 顯示筆記列表
              return ListView.separated(
                itemCount: notes.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(
                      note.vocabularyEntry.word,
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      note.vocabularyEntry.definitions
                          .map((e) => e.text)
                          .join(', '),
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () async {
                      // 顯示詞彙詳情對話框
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) =>
                            VocabularyDialog(entry: note.vocabularyEntry),
                      );
                      if (result == true) {
                        // 如果筆記有變化，重新獲取筆記列表
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

import 'providers/vocabulary_provider.dart';
import 'package:flutter/material.dart';
import 'snack_bar.dart';
import 'package:provider/provider.dart';
import 'providers/supabase_provider.dart';
import 'tts_model.dart';
import 'vocabulary.dart';

// 定義 VocabularyDialog 類，繼承 StatelessWidget
class VocabularyDialog extends StatelessWidget {
  // 詞彙條目，從外部傳入，用於顯示在對話框中
  final VocabularyEntry? entry;

  // 構造函數，使用必須參數初始化詞彙條目
  const VocabularyDialog({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // 獲取 SupabaseProvider，不需要監聽變化
    final supabaseProvider =
        Provider.of<SupabaseProvider>(context, listen: false);
    // 獲取 VocabularyProvider，監聽變化以更新 UI
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);

    // 獲取當前主題，用於設置文本和圖標樣式
    final theme = Theme.of(context);

    return AlertDialog(
      // 設置對話框標題，顯示詞彙的單字
      title: Center(
        child: Text(
          entry?.word ?? "",
          style: theme.textTheme.bodyLarge,
        ),
      ),
      // 設置對話框內容，顯示詞彙的定義
      content: ConstrainedBox(
        constraints: BoxConstraints(
          // 限制對話框內容的最大高度
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          // 使用 SingleChildScrollView 讓內容可滾動
          child: Column(
            // 將定義列表轉換為 Widget 列表
            children: entry?.definitions.map((definition) {
                  return Column(
                    children: [
                      // 顯示詞性
                      Center(
                        child: Text(
                          definition.partOfSpeech,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      // 顯示定義文本
                      Center(
                        child: Text(
                          definition.text,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      // 定義之間的間隔
                      const SizedBox(height: 10.0),
                    ],
                  );
                }).toList() ??
                [], // 如果沒有定義，返回空列表
          ),
        ),
      ),
      // 設置對話框的動作按鈕
      actions: [
        // 語音播放按鈕，按下後會讀出單字
        IconButton(
          icon: const Icon(Icons.volume_up),
          color: theme.colorScheme.primaryContainer,
          onPressed: () {
            var ttsModel = TtsModel();
            ttsModel.speak(entry?.word ?? "");
          },
        ),
        // 保存或刪除按鈕，根據詞彙是否已保存決定顯示的圖標和動作
        FutureBuilder<List<VocabularyEntry>?>(
          // 獲取 "筆記" 類型的詞彙列表
          future: vocabularyProvider.getVocabulary('筆記'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 如果數據仍在加載，顯示進度指示器
              return const Center(child: CircularProgressIndicator());
            } else {
              // 判斷當前詞彙是否已保存
              final isSaved =
                  snapshot.data?.any((note) => note.word == entry?.word) ??
                      false;
              return IconButton(
                // 根據是否已保存設置圖標
                icon: Icon(isSaved ? Icons.delete_rounded : Icons.save_rounded),
                color: theme.colorScheme.primaryContainer,
                disabledColor: Colors.grey,
                // 如果用戶已登入，設置按鈕動作；否則禁用按鈕
                onPressed: supabaseProvider.isLoggedIn
                    ? () async {
                        try {
                          if (isSaved) {
                            // 如果詞彙已保存，按下按鈕則刪除該詞彙
                            await supabaseProvider.deleteNote(entry);
                            if (context.mounted) {
                              // 顯示刪除成功的提示並關閉對話框
                              showTopSnackBar(
                                  context, '刪除成功', SnackBarType.success);
                              Navigator.of(context).pop(true);
                            }
                          } else {
                            // 如果詞彙未保存，按下按鈕則保存該詞彙
                            await supabaseProvider.saveNote(entry);
                            if (context.mounted) {
                              // 顯示保存成功的提示並關閉對話框
                              showTopSnackBar(
                                  context, '儲存成功', SnackBarType.success);
                              Navigator.of(context).pop(true);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // 如果出現錯誤，顯示錯誤提示
                            showTopSnackBar(
                                context, e.toString(), SnackBarType.failure);
                          }
                        }
                      }
                    : null, // 用戶未登入時禁用按鈕
              );
            }
          },
        ),
      ],
    );
  }
}

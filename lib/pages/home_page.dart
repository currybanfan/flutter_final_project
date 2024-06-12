import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import 'fill_in_page.dart';
import 'multiple_choice_page.dart';

// HomePage 類，主頁面
class HomePage extends StatelessWidget {
  // 預設推薦單字列表
  final List<String> recommendedWords = ['Flutter', 'Dart', 'TTS'];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 獲取當前主題，用於設置文本和顏色樣式
    final theme = Theme.of(context);

    return Scaffold(
      // 設置應用欄
      appBar: AppBar(
        title: Text(
          '主頁',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      // 主體部分
      body: Container(
        color: theme.colorScheme.surfaceDim,
        child: Column(
          children: [
            // 隨機佳句 Widget
            const QuotesWidget(),
            const SizedBox(height: 16.0),
            // 中間功能圖標區域
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    // 填充測驗按鈕
                    _buildFeatureIcon(
                      context,
                      icon: Icons.quiz,
                      label: '填充測驗',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const FillIn()));
                      },
                    ),
                    // 選擇測驗按鈕
                    _buildFeatureIcon(
                      context,
                      icon: Icons.check_box,
                      label: '選擇測驗',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MultipleChoice(),
                            ));
                      },
                    ),
                    // 重新登入按鈕
                    _buildFeatureIcon(
                      context,
                      icon: Icons.logout_rounded,
                      label: '重新登入',
                      onTap: () {
                        // 登出並重新登入
                        Provider.of<SupabaseProvider>(context, listen: false)
                            .signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 建立功能圖標的 Widget 方法
  Widget _buildFeatureIcon(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      // 設置點擊事件
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 顯示圖標
          Icon(icon, size: 50.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8.0),
          // 顯示標籤
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// QuotesWidget 顯示隨機佳句的 Widget
class QuotesWidget extends StatefulWidget {
  const QuotesWidget({super.key});

  @override
  QuotesWidgetState createState() => QuotesWidgetState();
}

class QuotesWidgetState extends State<QuotesWidget> {
  // 獲取隨機佳句的方法
  Future<String> fetchRandomQuote() async {
    final response = await http.get(Uri.parse('https://type.fit/api/quotes'));

    if (response.statusCode == 200) {
      // 解析響應 JSON 並隨機選擇一條佳句
      List<dynamic> quotes = json.decode(response.body);
      final randomIndex = Random().nextInt(quotes.length);
      return quotes[randomIndex]['text'] ?? 'No quote available';
    } else {
      // 如果請求失敗，拋出異常
      throw ('載入佳句失敗');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      // 獲取隨機佳句
      future: fetchRandomQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 如果數據仍在加載，顯示進度指示器
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 如果出現錯誤，顯示錯誤信息
          return Center(
              child: Text(
            '出現未知錯誤',
            style: theme.textTheme.bodyLarge,
          ));
        } else if (!snapshot.hasData) {
          // 如果未獲取到數據，顯示提示信息
          return Center(
              child: Text(
            '找不到佳句',
            style: theme.textTheme.bodyLarge,
          ));
        } else {
          // 如果成功獲取到數據，顯示隨機佳句
          return Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.surfaceDim),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontFamily: 'Arial', // 字體
                    color: theme.colorScheme.primaryContainer,
                    fontWeight: FontWeight.bold, // 粗體
                    fontSize: 18, // 字體大小
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

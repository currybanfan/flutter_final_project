import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import 'fill_in_page.dart';
import 'multiple_choice_page.dart';

class HomePage extends StatelessWidget {
  final List<String> recommendedWords = ['Flutter', 'Dart', 'TTS'];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '主頁',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        color: theme.colorScheme.surfaceDim,
        child: Column(
          children: [
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
                    _buildFeatureIcon(
                      context,
                      icon: Icons.quiz,
                      label: '填充測驗',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const FillIn()));
                      },
                    ),
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
                    _buildFeatureIcon(
                      context,
                      icon: Icons.logout_rounded,
                      label: '重新登入',
                      onTap: () {
                        final provider = Provider.of<SupabaseProvider>(context,
                            listen: false);
                        if (provider.isLoggedIn) {
                          provider.signOut();
                        }
                        Navigator.pushReplacementNamed(context, '/');
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

  Widget _buildFeatureIcon(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8.0),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class QuotesWidget extends StatefulWidget {
  const QuotesWidget({super.key});

  @override
  QuotesWidgetState createState() => QuotesWidgetState();
}

class QuotesWidgetState extends State<QuotesWidget> {
  Future<String> fetchRandomQuote() async {
    final response = await http.get(Uri.parse('https://type.fit/api/quotes'));

    if (response.statusCode == 200) {
      List<dynamic> quotes = json.decode(response.body);
      final randomIndex = Random().nextInt(quotes.length);
      return quotes[randomIndex]['text'] ?? 'No quote available';
    } else {
      throw ('載入佳句失敗');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: fetchRandomQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
            '${snapshot.error}',
            style: theme.textTheme.bodyLarge,
          ));
        } else if (!snapshot.hasData) {
          return Center(
              child: Text(
            '找不到佳句',
            style: theme.textTheme.bodyLarge,
          ));
        } else {
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

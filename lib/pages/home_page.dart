import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<String> recommendedWords = ['Flutter', 'Dart', 'TTS'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('主頁'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            // 上方推薦詞彙區域
            Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: recommendedWords.map((word) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        word,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
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
                      label: '測試 1',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TestPage(testName: '測試 1')));
                      },
                    ),
                    _buildFeatureIcon(
                      context,
                      icon: Icons.school,
                      label: '測試 2',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TestPage(testName: '測試 2')));
                      },
                    ),
                    _buildFeatureIcon(
                      context,
                      icon: Icons.star,
                      label: '測試 3',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TestPage(testName: '測試 3')));
                      },
                    ),
                    // 你可以繼續添加更多功能圖標
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

class TestPage extends StatelessWidget {
  final String testName;

  const TestPage({Key? key, required this.testName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(testName),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Text('這是 $testName 頁面'),
      ),
    );
  }
}

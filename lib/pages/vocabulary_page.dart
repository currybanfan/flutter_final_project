import 'package:flutter/material.dart';
import '../vocabulary.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});

  @override
  VocabularyPageState createState() => VocabularyPageState();
}

class VocabularyPageState extends State<VocabularyPage> {
  int _currentIndex = 0;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    provider.fetchVocabulary(provider.getLevels()[_currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VocabularyProvider>(context);
    final levels = provider.getLevels();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: levels.length,
      child: Column(
        children: [
          const SizedBox(height: 30),
          ButtonsTabBar(
            height: 50.0,
            backgroundColor: theme.colorScheme.primary,
            unselectedBackgroundColor: Colors.grey.shade300,
            labelStyle: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
            unselectedLabelStyle: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            borderWidth: 2,
            borderColor: theme.colorScheme.primaryContainer,
            unselectedBorderColor: theme.colorScheme.onSurface,
            radius: 100,
            tabs: levels
                .map(
                  (level) => Tab(
                    text: "    $level     ",
                  ),
                )
                .toList(),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                provider.fetchVocabulary(levels[_currentIndex]);
              });
            },
          ),
          const SizedBox(height: 5),
          Expanded(
            child: TabBarView(
              children: levels.map((level) {
                var vocabularyList = provider.getVocabulary(level);
                return vocabularyList == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: vocabularyList.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          var entry = vocabularyList[index];
                          return ListTile(
                            title: Text(
                              entry.word,
                              style: theme.textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              entry.definitions.map((e) => e.text).join(', '),
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () => _showVocabularyDialog(context, entry),
                          );
                        },
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showVocabularyDialog(BuildContext context, VocabularyEntry? entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VocabularyDialog(entry: entry);
      },
    );
  }
}

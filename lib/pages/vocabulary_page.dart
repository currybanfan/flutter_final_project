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
  int currentIndex = 0;
  List<String> levels = [];
  late final VocabularyProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<VocabularyProvider>(context, listen: false);
    levels = provider.getLevels().where((level) => level != '筆記').toList();
    provider.fetchVocabulary(levels[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '單字',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: DefaultTabController(
          length: levels.length,
          child: Column(
            children: [
              const SizedBox(height: 10),
              ButtonsTabBar(
                height: 50.0,
                backgroundColor: theme.colorScheme.primary,
                unselectedBackgroundColor: theme.colorScheme.surface,
                labelStyle: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
                unselectedLabelStyle: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                borderWidth: 1,
                borderColor: theme.colorScheme.primaryContainer,
                unselectedBorderColor: theme.colorScheme.primaryContainer,
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
                    currentIndex = index;
                  });
                },
              ),
              const SizedBox(height: 5),
              Expanded(
                child: TabBarView(
                  children: levels.map((level) {
                    return VocabularyListView(
                      level: level,
                      isVisible: levels[currentIndex] == level,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VocabularyListView extends StatelessWidget {
  const VocabularyListView({
    required this.level,
    required this.isVisible,
    super.key,
  });

  final String level;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Visibility(
      visible: isVisible,
      child: FutureBuilder<List<VocabularyEntry>?>(
        future: provider.getVocabulary(level),
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
                child: Text(
              '找不到單字',
              style: theme.textTheme.bodyLarge,
            ));
          } else {
            var vocabularyList = snapshot.data ?? [];
            return ListView.separated(
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
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return VocabularyDialog(entry: entry);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

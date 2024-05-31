import 'supabase_provider.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_model.dart';
import 'package:provider/provider.dart';

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

    return DefaultTabController(
      length: levels.length,
      child: Column(
        children: [
          const SizedBox(height: 40),
          ButtonsTabBar(
            height: 50.0,
            backgroundColor: Colors.grey.shade200,
            unselectedBackgroundColor: Colors.grey.shade500,
            labelStyle: TextStyle(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.bold,
            ),
            borderWidth: 2,
            borderColor: Colors.grey.shade500,
            unselectedBorderColor: Colors.grey.shade200,
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
          Expanded(
            child: TabBarView(
              children: levels.map((level) {
                var vocabularyList = provider.getVocabulary(level);
                return vocabularyList == null
                    ? Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: vocabularyList.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          var entry = vocabularyList[index];
                          return ListTile(
                            title: Text(
                              entry.word,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              entry.definitions.map((e) => e.text).join(', '),
                              style: Theme.of(context).textTheme.bodySmall,
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

class VocabularyDialog extends StatelessWidget {
  final VocabularyEntry? entry;

  const VocabularyDialog({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          entry?.word ?? "",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Center(
              child: Text(
                entry?.definitions.map((e) => e.partOfSpeech).join(', ') ?? "",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 5.0),
            Center(
              child: Text(
                entry?.definitions.map((e) => e.text).join(', ') ?? "",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          color: Theme.of(context).colorScheme.primaryContainer,
          onPressed: () {
            var ttsModel = Provider.of<TtsModel>(context, listen: false);
            ttsModel.setVoiceText(entry?.word ?? "");
            ttsModel.speak();
          },
        ),
        IconButton(
          icon: const Icon(Icons.note),
          color: Theme.of(context).colorScheme.primaryContainer,
          onPressed: () {
            var supabase =
                Provider.of<SupabaseProvider>(context, listen: false);
            supabase.saveNote(entry);
          },
        ),
      ],
    );
  }
}

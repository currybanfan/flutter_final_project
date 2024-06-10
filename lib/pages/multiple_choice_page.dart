import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import '../vocabulary.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  MultipleChoiceState createState() => MultipleChoiceState();
}

class MultipleChoiceState extends State<MultipleChoice> {
  List<String> _selectedLevels = [];
  late final List<String> levels;

  @override
  void initState() {
    super.initState();
    final vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    levels = vocabularyProvider.getLevels().toList();
  }

  void _startTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuizPage(
          selectedLevels: _selectedLevels,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '選擇題',
          style: theme.textTheme.titleLarge,
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Consumer<SupabaseProvider>(
        builder: (context, supabaseProvider, child) {
          final disabledLevels = supabaseProvider.isLoggedIn ? [] : ['筆記'];
          return Column(
            children: [
              SizedBox(
                height: 200,
                child: CustomCheckBoxGroup(
                  buttonLables: levels,
                  buttonValuesList: levels,
                  defaultSelected: const [],
                  disabledValues: disabledLevels,
                  disabledColor: theme.colorScheme.surfaceDim,
                  checkBoxButtonValues: (values) {
                    setState(() {
                      _selectedLevels = values.cast<String>();
                    });
                  },
                  buttonTextStyle: ButtonTextStyle(
                    selectedColor: theme.colorScheme.onPrimary,
                    unSelectedColor: theme.colorScheme.onSurface,
                    textStyle: theme.textTheme.bodyMedium!,
                  ),
                  selectedColor: theme.colorScheme.primary,
                  unSelectedColor: theme.colorScheme.surface,
                  selectedBorderColor: theme.colorScheme.primaryContainer,
                  unSelectedBorderColor: theme.colorScheme.primaryContainer,
                  enableButtonWrap: true,
                  wrapAlignment: WrapAlignment.center,
                  width: 100,
                  height: 30,
                  padding: 5,
                  enableShape: true,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectedLevels.isEmpty ? null : _startTest,
                child: const Text('開始測驗'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuizPage extends StatefulWidget {
  final List<String> selectedLevels;

  const _QuizPage({required this.selectedLevels});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<_QuizPage> with TickerProviderStateMixin {
  VocabularyEntry? _randomEntry;
  late final List<String> levels;
  String? _selectedAnswer;
  bool _isLoadingNextEntry = false;
  List<String> _choices = [];
  late Future<void> _initialLoad;

  late final VocabularyProvider vocabularyProvider;

  @override
  void initState() {
    super.initState();
    vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    levels = widget.selectedLevels;
    _initialLoad = _nextQuestion();
  }

  void _checkAnswer() {
    if (_selectedAnswer == null || _isLoadingNextEntry) return;
    setState(() {
      _isLoadingNextEntry = true;
      Future.delayed(const Duration(seconds: 1), () {
        _nextQuestion();
        _isLoadingNextEntry = false;
      });
    });
  }

  Future<void> _nextQuestion() async {
    final entries = await _loadRandomEntries();
    final randomIndex = Random().nextInt(entries.length);
    final entry = entries[randomIndex];
    final choices = entries.map((e) => e.word).toList();

    setState(() {
      _randomEntry = entry;
      _selectedAnswer = null;
      _choices = choices;
    });
  }

  Future<List<VocabularyEntry>> _loadRandomEntries() async {
    final entries = <VocabularyEntry>[];

    while (entries.length < 4) {
      final randomEntry = await vocabularyProvider.loadRandomEntry(levels);
      if (!entries.contains(randomEntry)) {
        entries.add(randomEntry);
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '選擇題',
          style: theme.textTheme.titleLarge,
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('發生錯誤: ${snapshot.error}'),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: _randomEntry?.definitions.map((definition) {
                            return Column(
                              children: [
                                Center(
                                  child: Text(
                                    definition.text,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Center(
                                  child: Text(
                                    definition.partOfSpeech,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                              ],
                            );
                          }).toList() ??
                          [],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._choices.map((choice) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAnswer = choice;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isLoadingNextEntry
                                  ? (choice == _randomEntry?.word
                                      ? Colors.green
                                      : (_selectedAnswer == choice
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.onSurface))
                                  : (_selectedAnswer == choice
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                            color: _isLoadingNextEntry
                                ? (choice == _randomEntry?.word
                                    ? Colors.green.withOpacity(0.3)
                                    : (_selectedAnswer == choice
                                        ? theme.colorScheme.error
                                            .withOpacity(0.3)
                                        : theme.colorScheme.surface))
                                : (_selectedAnswer == choice
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : theme.colorScheme.surface),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: choice,
                                groupValue: _selectedAnswer,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAnswer = value;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  choice,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAnswer = _randomEntry!.word;
                          });
                        },
                        child: const Text('顯示答案'),
                      ),
                      ElevatedButton(
                        onPressed:
                            _selectedAnswer == null ? null : _checkAnswer,
                        child: const Text('確認'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: _nextQuestion,
                  //   child: const Text('下一題'),
                  // ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

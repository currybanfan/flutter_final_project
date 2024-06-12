import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import '../vocabulary.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

// MultipleChoice 類，用於顯示選擇題頁面
class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  MultipleChoiceState createState() => MultipleChoiceState();
}

// MultipleChoiceState 類，用於管理選擇題頁面的狀態
class MultipleChoiceState extends State<MultipleChoice> {
  // 用來存儲選擇的級別
  List<String> _selectedLevels = [];
  // 存儲所有級別
  late final List<String> levels;

  @override
  void initState() {
    super.initState();
    // 獲取 VocabularyProvider 的實例並初始化級別列表
    final vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    levels = vocabularyProvider.getLevels().toList();
  }

  // 開始測驗，將選擇的級別傳遞到測驗頁面
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
          // 根據登錄狀態禁用相應的級別
          final disabledLevels = supabaseProvider.isLoggedIn ? [] : ['筆記'];
          return Column(
            children: [
              // 顯示級別選擇的自定義單選按鈕組
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
              // 開始測驗按鈕
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

// 測驗頁面類
class _QuizPage extends StatefulWidget {
  final List<String> selectedLevels;

  const _QuizPage({required this.selectedLevels});

  @override
  _QuizPageState createState() => _QuizPageState();
}

// 測驗頁面狀態類
class _QuizPageState extends State<_QuizPage> with TickerProviderStateMixin {
  // 隨機詞彙條目
  VocabularyEntry? _randomEntry;
  // 所有級別
  late final List<String> levels;
  // 用戶選擇的答案
  String? _selectedAnswer;
  // 控制是否加載下一個條目
  bool _isLoadingNextEntry = false;
  // 選項列表
  List<String> _choices = [];
  // 初始化加載
  late Future<void> _initialLoad;

  // VocabularyProvider 的實例
  late final VocabularyProvider vocabularyProvider;

  @override
  void initState() {
    super.initState();
    // 獲取 VocabularyProvider 的實例
    vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    // 初始化選擇的級別
    levels = widget.selectedLevels;
    // 初始化加載第一個問題
    _initialLoad = _nextQuestion();
  }

  // 檢查用戶選擇的答案是否正確
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

  // 加載下一個問題
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

  // 從指定級別中加載隨機詞彙條目
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
            // 如果數據仍在加載，顯示進度指示器
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // 如果出現錯誤，顯示錯誤信息
            return Center(
              child: Text('發生錯誤: ${snapshot.error}'),
            );
          } else {
            // 顯示選擇題頁面
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
                                // 顯示詞彙的定義
                                Center(
                                  child: Text(
                                    definition.text,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                // 顯示詞性
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
                  // 顯示選項
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
                              // 選項單選按鈕
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
                  // 顯示答案和確認按鈕
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 顯示答案按鈕
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAnswer = _randomEntry!.word;
                          });
                        },
                        child: const Text('顯示答案'),
                      ),
                      // 確認按鈕
                      ElevatedButton(
                        onPressed:
                            _selectedAnswer == null ? null : _checkAnswer,
                        child: const Text('確認'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

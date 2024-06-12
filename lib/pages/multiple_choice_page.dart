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
// 使用 _choices 列表生成選項的 Widget
                  ..._choices.map((choice) => GestureDetector(
                        // GestureDetector 用於偵測點擊事件
                        onTap: () {
                          // 當選項被點擊時，更新 _selectedAnswer 的值並觸發重建
                          setState(() {
                            _selectedAnswer = choice;
                          });
                        },
                        // AnimatedContainer 用於創建帶有動畫效果的容器
                        child: AnimatedContainer(
                          // 動畫持續時間為 300 毫秒
                          duration: const Duration(milliseconds: 300),
                          // 設置容器的裝飾
                          decoration: BoxDecoration(
                            // 設置邊框顏色
                            border: Border.all(
                              // 如果正在加載下一個問題，根據答案是否正確設置顏色
                              color: _isLoadingNextEntry
                                  ? (choice == _randomEntry?.word
                                      ? Colors.green // 答對了顯示綠色
                                      : (_selectedAnswer == choice
                                          ? theme
                                              .colorScheme.error // 選擇錯誤答案顯示紅色
                                          : theme.colorScheme
                                              .onSurface)) // 其他選項顯示默認顏色
                                  : (_selectedAnswer == choice
                                      ? theme.colorScheme.primary // 當前選擇顯示主要顏色
                                      : theme
                                          .colorScheme.onSurface), // 其他選項顯示默認顏色
                            ),
                            // 設置圓角
                            borderRadius: BorderRadius.circular(8.0),
                            // 設置背景顏色
                            color: _isLoadingNextEntry
                                ? (choice == _randomEntry?.word
                                    ? Colors.green
                                        .withOpacity(0.3) // 答對了顯示半透明綠色
                                    : (_selectedAnswer == choice
                                        ? theme.colorScheme.error
                                            .withOpacity(0.3) // 錯誤選擇顯示半透明紅色
                                        : theme
                                            .colorScheme.surface)) // 其他選項顯示默認顏色
                                : (_selectedAnswer == choice
                                    ? theme.colorScheme.primary
                                        .withOpacity(0.1) // 當前選擇顯示半透明主要顏色
                                    : theme.colorScheme.surface), // 其他選項顯示默認顏色
                          ),
                          // 設置內邊距
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          // 設置外邊距
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
                          // 使用 Row 佈局內部內容
                          child: Row(
                            children: [
                              // 選項單選按鈕
                              Radio<String>(
                                value: choice,
                                groupValue: _selectedAnswer,
                                onChanged: (value) {
                                  // 當單選按鈕狀態改變時，更新 _selectedAnswer 的值並觸發重建
                                  setState(() {
                                    _selectedAnswer = value;
                                  });
                                },
                              ),
                              // Expanded 用於佔據剩餘空間顯示選項文本
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

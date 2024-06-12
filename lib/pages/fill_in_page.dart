import 'package:flutter/material.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import '../vocabulary.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

// 填空題頁面
class FillIn extends StatefulWidget {
  const FillIn({super.key});

  @override
  FillInState createState() => FillInState();
}

class FillInState extends State<FillIn> {
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
          '填充題',
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

// 測驗頁面
class _QuizPage extends StatefulWidget {
  final List<String> selectedLevels;

  const _QuizPage({required this.selectedLevels});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<_QuizPage> with TickerProviderStateMixin {
  // 隨機詞彙條目
  VocabularyEntry? _randomEntry;
  // 所有級別
  late final List<String> levels;
  // 文本輸入控制器
  final TextEditingController _controller = TextEditingController();
  // 控制動畫顯示的標誌
  bool _showAnimation = false;
  // 判斷是否輸入錯誤
  bool _isError = false;
  // 顯示的文本
  String _displayedText = '';
  // 控制是否加載下一個條目
  bool _isLoadingNextEntry = false;
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
    // 添加文本變化監聽器
    _controller.addListener(_onTextChanged);
    // 初始化加載第一個問題
    _initialLoad = _nextQuestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 監聽文本變化的方法
  void _onTextChanged() {
    if (_isLoadingNextEntry) return;
    setState(() {
      _updateDisplayedText(_controller.text);
      if (_controller.text.length == _randomEntry?.letterCount) {
        // 判斷輸入是否正確
        var isCorrect = _controller.text == _randomEntry?.word;
        _showAnimation = isCorrect;
        _isError = !isCorrect;
      } else {
        _isError = false;
        _showAnimation = false;
      }
      if (_showAnimation) {
        // 如果正確，延遲一秒鐘加載下一個問題
        _isLoadingNextEntry = true;
        Future.delayed(const Duration(seconds: 1), () {
          _nextQuestion();
          _isLoadingNextEntry = false;
        });
      }
    });
  }

  // 更新顯示的文本
  void _updateDisplayedText(String text) {
    // 用已輸入的文字加上 _ 表示剩餘字數
    int inputLetterCount = text.length;
    int remainingBottomLine =
        (_randomEntry?.letterCount ?? 0) - inputLetterCount;
    String blankField = '';

    for (int i = 0; i < remainingBottomLine; i++) {
      blankField += '_ ';
    }

    _displayedText = text + blankField;
  }

  // 加載下一個問題
  Future<void> _nextQuestion() async {
    final entry = await _loadRandomEntry();
    setState(() {
      _randomEntry = entry;
      _showAnimation = _isError = false;
      _controller.clear();
      _onTextChanged(); // 手動調用 _onTextChanged 更新顯示
    });
  }

  // 從指定級別中加載隨機詞彙條目
  Future<VocabularyEntry?> _loadRandomEntry() async {
    return await vocabularyProvider.loadRandomEntry(levels);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '填充題',
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
            // 顯示填充題頁面
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
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
                  // 顯示填空的區域
                  SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // 動畫文本顯示
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 100),
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: _isError
                                ? theme.colorScheme.error
                                : _showAnimation
                                    ? Colors.green
                                    : theme.colorScheme.onSurface,
                          ),
                          child: Align(
                            child: Text(
                              _displayedText,
                            ),
                          ),
                        ),
                        // 隱形的輸入框
                        Align(
                          child: Opacity(
                            opacity: 0.0,
                            child: TextField(
                              controller: _controller,
                              autofocus: false,
                              maxLength: _randomEntry?.letterCount ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 顯示答案和下一題按鈕
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // 顯示答案
                            _controller.text = _randomEntry!.word;
                          });
                        },
                        child: const Text('顯示答案'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: const Text('下一題'),
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

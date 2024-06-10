import 'package:flutter/material.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import '../vocabulary.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

class FillIn extends StatefulWidget {
  const FillIn({super.key});

  @override
  FillInState createState() => FillInState();
}

class FillInState extends State<FillIn> {
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
          '填充題',
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
  final TextEditingController _controller = TextEditingController();
  bool _showAnimation = false;
  bool _isError = false; // 用來控制動畫顯示
  String _displayedText = '';
  bool _isLoadingNextEntry = false;
  late Future<void> _initialLoad;

  late final VocabularyProvider vocabularyProvider;

  @override
  void initState() {
    super.initState();
    vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    levels = widget.selectedLevels;
    _controller.addListener(_onTextChanged);
    _initialLoad = _nextQuestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isLoadingNextEntry) return;
    setState(() {
      _updateDisplayedText(_controller.text);
      if (_controller.text.length == _randomEntry?.letterCount) {
        var isCorrect = _controller.text == _randomEntry?.word;
        _showAnimation = isCorrect;
        _isError = !isCorrect;
      } else {
        _isError = false;
        _showAnimation = false;
      }
      if (_showAnimation) {
        _isLoadingNextEntry = true;
        Future.delayed(const Duration(seconds: 1), () {
          _nextQuestion();
          _isLoadingNextEntry = false;
        });
      }
    });
  }

  void _updateDisplayedText(String text) {
    int inputLetterCount = text.length;
    int remainingBottomLine =
        (_randomEntry?.letterCount ?? 0) - inputLetterCount;
    String blankField = '';

    for (int i = 0; i < remainingBottomLine; i++) {
      blankField += '_ ';
    }

    _displayedText = text + blankField;
  }

  Future<void> _nextQuestion() async {
    final entry = await _loadRandomEntry();
    setState(() {
      _randomEntry = entry;
      _showAnimation = _isError = false;
      _controller.clear();
      _onTextChanged(); // 手動調用 _onTextChanged
    });
  }

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
                    height: 100,
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
                  SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
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

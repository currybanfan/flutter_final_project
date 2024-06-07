import 'package:flutter/material.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/supabase_provider.dart';
import 'package:provider/provider.dart';
import '../vocabulary.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> with TickerProviderStateMixin {
  List<String> _selectedLevels = [];
  VocabularyEntry? _randomEntry;
  late final List<String> levels;
  final TextEditingController _controller = TextEditingController();
  bool _showAnimation = false;
  bool _isError = false; // 用來控制動畫顯示
  String _displayedText = '';

  late final VocabularyProvider vocabularyProvider;

  @override
  void initState() {
    super.initState();
    vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    levels = vocabularyProvider.getLevels().toList();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
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
        Future.delayed(const Duration(seconds: 1), () {
          _loadNextEntry();
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

  void _loadNextEntry() async {
    final entry = await _loadRandomEntry();
    setState(() {
      _randomEntry = entry;
      _controller.clear();
    });
  }

  Future<VocabularyEntry?> _loadRandomEntry() async {
    return await vocabularyProvider.loadRandomEntry(_selectedLevels);
  }

  Widget _buildLevelSelection() {
    final theme = Theme.of(context);

    return Consumer<SupabaseProvider>(
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
            onPressed: _selectedLevels.isEmpty ? null : _loadNextEntry,
            child: const Text('開始測驗'),
          ),
        ],
      );
    });
  }

  Widget _buildTestContent() {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            _randomEntry!.definitions.map((e) => e.text).join('\n'),
            style: theme.textTheme.bodyLarge,
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
              onPressed: _loadNextEntry,
              child: const Text('下一題'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _randomEntry = null;
            });
          },
          child: const Text('返回選擇'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '單字測驗',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_randomEntry == null)
              _buildLevelSelection()
            else
              _buildTestContent(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

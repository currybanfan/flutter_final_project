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
  bool _showResult = false;
  late final List<String> levels;
  TextEditingController _controller = TextEditingController();
  bool _isCorrect = true;
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

  void _onTextChanged() {
    setState(() {
      _updateDisplayedText(_controller.text);
      if (_controller.text.length == _randomEntry?.letterCount) {
        _isCorrect = _controller.text == _randomEntry?.word;
      } else {
        _isCorrect = true;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: Consumer<SupabaseProvider>(
        builder: (context, supabaseProvider, child) {
          final disabledLevels = supabaseProvider.isLoggedIn ? [] : ['筆記'];

          return Column(
            children: [
              DefaultTabController(
                length: levels.length,
                child: Column(
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
                        unSelectedBorderColor:
                            theme.colorScheme.primaryContainer,
                        enableButtonWrap: true,
                        wrapAlignment: WrapAlignment.center,
                        width: 100,
                        height: 30,
                        padding: 5,
                        enableShape: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_randomEntry == null)
                      ElevatedButton(
                        onPressed: _selectedLevels.isEmpty
                            ? null
                            : () async {
                                final entry = await vocabularyProvider
                                    .loadRandomEntry(_selectedLevels);
                                setState(() {
                                  _randomEntry = entry;
                                  _showResult = false;
                                  _isCorrect = true;
                                  _controller.clear();
                                });
                              },
                        child: const Text('開始測驗'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_randomEntry != null) ...[
                Text(
                  _randomEntry!.definitions.map((e) => e.text).join(', '),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Align(
                        child: Text(
                          _displayedText,
                          style: theme.textTheme.bodyLarge!.copyWith(
                              color: _isCorrect
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.error),
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
                      onPressed: () async {
                        final entry = await vocabularyProvider
                            .loadRandomEntry(_selectedLevels);
                        setState(() {
                          _randomEntry = entry;
                          _showResult = false;
                          _isCorrect = true;
                          _controller.clear();
                          _updateDisplayedText('');
                        });
                      },
                      child: const Text('下一題'),
                    ),
                  ],
                )
              ],
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'vocabulary_page.dart';
import 'data.dart';
import 'tts_model.dart';
import 'package:provider/provider.dart';
import 'supabase_provider.dart';
import 'auth_page.dart';

ThemeData lightTheme() {
  return ThemeData(
      colorScheme: ColorScheme(
        primary: Colors.deepPurple, // Primary
        primaryContainer: Colors.deepPurple.shade900, // Primary Variant
        secondary: Colors.purple, // Secondary
        secondaryContainer: Colors.purple.shade700, // Secondary Variant
        surface: Colors.white, // Surface
        error: Colors.red, // Error
        onPrimary: Colors.white, // On Primary
        onSecondary: Colors.black, // On Secondary
        onSurface: Colors.black, // On Surface
        onError: Colors.white, // On Error
        brightness: Brightness.light,
      ),
      // 文字主題設定
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Arial', // 字體
          color: Colors.black,
          fontWeight: FontWeight.bold, // 粗體
          fontSize: 24, // 字體大小
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Arial', // 字體
          color: Colors.black,
          fontWeight: FontWeight.bold, // 粗體
          fontSize: 20, // 字體大小
        ),
        bodySmall: TextStyle(
          fontFamily: 'Arial', // 字體
          color: Colors.black,
          fontSize: 14, // 字體大小
        ),
        titleLarge: TextStyle(
          // 標題文本的風格
          fontFamily: 'Arial',
          fontSize: 24,
          fontWeight: FontWeight.bold, // 粗體
          color: Colors.white,
        ),
      ),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //   // 提升按鈕的主題設定
      //   style: ButtonStyle(
      //     // 按鈕風格設定
      //     foregroundColor: WidgetStateProperty.resolveWith<Color?>(
      //       // 文字顏色
      //       (Set<WidgetState> states) {
      //         if (states.contains(WidgetState.disabled)) {
      //           return Colors.grey[700]; // 禁用時的文字顏色，深灰色
      //         }
      //         return const Color.fromARGB(255, 2, 100, 175); // 啟用時的文字顏色，深藍色
      //       },
      //     ),
      //     textStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      //       // 文字風格
      //       return const TextStyle(
      //         fontFamily: 'Arial',
      //         fontSize: 18,
      //         fontWeight: FontWeight.bold, // 粗體
      //       );
      //     }),
      //     backgroundColor:
      //         WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      //       // 按鈕背景色
      //       if (states.contains(WidgetState.disabled)) {
      //         return Colors.grey; // 禁用時背景色為灰色
      //       }
      //       return Colors.white; // 可用時背景色為白色
      //     }),
      //     fixedSize:
      //         WidgetStateProperty.all(const Size.fromHeight(45)), // 按鈕大小固定
      //     shadowColor: WidgetStateProperty.all(Colors.black), // 陰影顏色
      //     elevation: WidgetStateProperty.all(10), // 陰影高度
      //   ),
      // ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF) // Surface
      );
}

void main() {
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0dHJoc3hnbnJsdGVrZmdiZnJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTY5NTEyNjUsImV4cCI6MjAzMjUyNzI2NX0.bCLktGjILcCH2CQHzPqxJ5YwDdTpTBLEoF3bqD6f9Cw';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TtsModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => VocabularyProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SupabaseProvider(
              'https://tttrhsxgnrltekfgbfrx.supabase.co', supabaseKey),
        ),
      ],
      child: const VocabularyAPP(),
    ),
  );
}

class VocabularyAPP extends StatelessWidget {
  const VocabularyAPP({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseProvider = Provider.of<SupabaseProvider>(context);

    return MaterialApp(
      theme: lightTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => supabaseProvider.isLoggedIn ? MainPage() : AuthPage(),
        '/home': (context) => MainPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = [
    VocabularyPage(),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    MyApp()
    // Text(
    //   'Index 2: School',
    //   style: optionStyle,
    // ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Vocabulary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter TTS'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _InputSection(),
              _BtnSection(),
              _EngineSection(),
              _LanguageSection(),
              // _BuildSliders(),
              // if (context.read<TtsModel>().isAndroid)
              //   _GetMaxSpeechInputLengthSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        maxLines: 11,
        minLines: 6,
        onChanged: (String value) {
          context.read<TtsModel>().setVoiceText(value);
        },
      ),
    );
  }
}

class _BtnSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var ttsModel = context.watch<TtsModel>();
    return Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(Colors.green, Colors.greenAccent, Icons.play_arrow,
              'PLAY', ttsModel.speak),
          _buildButtonColumn(
              Colors.red, Colors.redAccent, Icons.stop, 'STOP', ttsModel.stop),
          _buildButtonColumn(Colors.blue, Colors.blueAccent, Icons.pause,
              'PAUSE', ttsModel.pause),
        ],
      ),
    );
  }

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon),
          color: color,
          splashColor: splashColor,
          onPressed: () => func(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12.0, fontWeight: FontWeight.w400, color: color),
          ),
        ),
      ],
    );
  }
}

class _EngineSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var ttsModel = context.watch<TtsModel>();
    if (ttsModel.isAndroid) {
      return FutureBuilder<dynamic>(
        future: ttsModel.getEngines(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return _EnginesDropDownSection(snapshot.data as List<dynamic>);
          } else if (snapshot.hasError) {
            return Text('Error loading engines...');
          } else {
            return Text('Loading engines...');
          }
        },
      );
    } else {
      return Container(width: 0, height: 0);
    }
  }
}

class _EnginesDropDownSection extends StatelessWidget {
  final List<dynamic> engines;
  _EnginesDropDownSection(this.engines);

  @override
  Widget build(BuildContext context) {
    var ttsModel = context.read<TtsModel>();
    return Container(
      padding: EdgeInsets.only(top: 50.0),
      child: DropdownButton(
        value: ttsModel.engine,
        items: getEnginesDropDownMenuItems(engines),
        onChanged: (String? value) => ttsModel.changedEngine(value),
      ),
    );
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
        value: type as String?,
        child: Text((type as String)),
      ));
    }
    return items;
  }
}

class _LanguageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var ttsModel = context.watch<TtsModel>();
    return FutureBuilder<dynamic>(
      future: ttsModel.getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _LanguageDropDownSection(snapshot.data as List<dynamic>);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else {
          return Text('Loading Languages...');
        }
      },
    );
  }
}

class _LanguageDropDownSection extends StatelessWidget {
  final List<dynamic> languages;
  _LanguageDropDownSection(this.languages);

  @override
  Widget build(BuildContext context) {
    var ttsModel = context.read<TtsModel>();
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton(
            value: ttsModel.language,
            items: getLanguageDropDownMenuItems(languages),
            onChanged: (String? value) => ttsModel.changedLanguage(value),
          ),
          Visibility(
            visible: ttsModel.isAndroid,
            child: Text("Is installed: ${ttsModel.isCurrentLanguageInstalled}"),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
        value: type as String?,
        child: Text((type as String)),
      ));
    }
    return items;
  }
}

// class _BuildSliders extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _VolumeSlider(),
//         _PitchSlider(),
//         _RateSlider(),
//       ],
//     );
//   }
// }

// class _VolumeSlider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var ttsModel = context.watch<TtsModel>();
//     return Slider(
//       value: ttsModel.volume,
//       onChanged: (newVolume) {
//         ttsModel.volume = newVolume;
//         ttsModel.notifyListeners();
//       },
//       min: 0.0,
//       max: 1.0,
//       divisions: 10,
//       label: "Volume: ${ttsModel.volume}",
//     );
//   }
// }

// class _PitchSlider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var ttsModel = context.watch<TtsModel>();
//     return Slider(
//       value: ttsModel.pitch,
//       onChanged: (newPitch) {
//         ttsModel.pitch = newPitch;
//         ttsModel.notifyListeners();
//       },
//       min: 0.5,
//       max: 2.0,
//       divisions: 15,
//       label: "Pitch: ${ttsModel.pitch}",
//       activeColor: Colors.red,
//     );
//   }
// }

// class _RateSlider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var ttsModel = context.watch<TtsModel>();
//     return Slider(
//       value: ttsModel.rate,
//       onChanged: (newRate) {
//         ttsModel.rate = newRate;
//         ttsModel.notifyListeners();
//       },
//       min: 0.0,
//       max: 1.0,
//       divisions: 10,
//       label: "Rate: ${ttsModel.rate}",
//       activeColor: Colors.green,
//     );
//   }
// }

// class _GetMaxSpeechInputLengthSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var ttsModel = context.watch<TtsModel>();
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ElevatedButton(
//           child: Text('Get max speech input length'),
//           onPressed: () async {
//             ttsModel.inputLength =
//                 await ttsModel.flutterTts.getMaxSpeechInputLength;
//             ttsModel.notifyListeners();
//           },
//         ),
//         Text("${ttsModel.inputLength} characters"),
//       ],
//     );
//   }
// }

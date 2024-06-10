import 'package:flutter/material.dart';
import 'pages/vocabulary_page.dart';
import 'providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'providers/supabase_provider.dart';
import 'pages/auth_page.dart';
import 'pages/notes_page.dart';
import 'pages/home_page.dart';

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
        surfaceDim: Colors.grey.shade300,
      ),
      // 文字主題設定
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Arial', // 字體
          color: Colors.black,
          fontWeight: FontWeight.bold, // 粗體
          fontSize: 22, // 字體大小
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Arial', // 字體
          color: Colors.black,
          fontSize: 16, // 字體大小
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
      scaffoldBackgroundColor: const Color(0xFFFFFFFF) // Surface
      );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0dHJoc3hnbnJsdGVrZmdiZnJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTY5NTEyNjUsImV4cCI6MjAzMjUyNzI2NX0.bCLktGjILcCH2CQHzPqxJ5YwDdTpTBLEoF3bqD6f9Cw';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SupabaseProvider(
              'https://tttrhsxgnrltekfgbfrx.supabase.co', supabaseKey),
        ),
        ChangeNotifierProvider(
            create: (context) =>
                VocabularyProvider(context.read<SupabaseProvider>())),
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
        '/': (context) =>
            supabaseProvider.isLoggedIn ? const MainPage() : const AuthPage(),
        '/home': (context) => const MainPage(),
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
    HomePage(),
    VocabularyPage(),
    NotesPage(),
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Vocabulary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_rounded),
            label: 'Notes',
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

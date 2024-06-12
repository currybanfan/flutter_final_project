import 'package:flutter/material.dart';
import 'pages/vocabulary_page.dart';
import 'providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'providers/supabase_provider.dart';
import 'pages/auth_page.dart';
import 'pages/notes_page.dart';
import 'pages/home_page.dart';
import '../snack_bar.dart';

// 定義 lightTheme 方法，設置應用的主題樣式
ThemeData lightTheme() {
  return ThemeData(
    // 設置顏色方案
    colorScheme: ColorScheme(
      primary: Colors.deepPurple, // 主要顏色
      primaryContainer: Colors.deepPurple.shade900, // 主要變異顏色
      secondary: Colors.purple, // 次要顏色
      secondaryContainer: Colors.purple.shade700, // 次要變異顏色
      surface: Colors.white, // 表面顏色
      error: Colors.red, // 錯誤顏色
      onPrimary: Colors.white, // 主要顏色上的文本顏色
      onSecondary: Colors.black, // 次要顏色上的文本顏色
      onSurface: Colors.black, // 表面顏色上的文本顏色
      onError: Colors.white, // 錯誤顏色上的文本顏色
      brightness: Brightness.light, // 亮度
      surfaceDim: Colors.grey.shade300, // 表面淡色
    ),
    // 設置文本主題
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
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 頁面背景顏色
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 金鑰
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0dHJoc3hnbnJsdGVrZmdiZnJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTY5NTEyNjUsImV4cCI6MjAzMjUyNzI2NX0.bCLktGjILcCH2CQHzPqxJ5YwDdTpTBLEoF3bqD6f9Cw';

  runApp(
    MultiProvider(
      providers: [
        // 註冊 SupabaseProvider
        ChangeNotifierProvider(
          create: (context) => SupabaseProvider(
              'https://tttrhsxgnrltekfgbfrx.supabase.co', supabaseKey),
        ),
        // 註冊 VocabularyProvider
        ChangeNotifierProvider(
            create: (context) =>
                VocabularyProvider(context.read<SupabaseProvider>())),
      ],
      child: const VocabularyAPP(),
    ),
  );
}

// 主應用程序
class VocabularyAPP extends StatelessWidget {
  const VocabularyAPP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme(), // 設置應用主題
      home: Consumer<SupabaseProvider>(
        builder: (context, supabaseProvider, child) {
          if (supabaseProvider.isLoggedIn) {
            // 如果用戶已登入，顯示主頁面
            return const MainPage(signInMessage: '登入成功');
          } else if (supabaseProvider.isGuest) {
            // 如果用戶以訪客身份登入，顯示主頁面
            return const MainPage(signInMessage: '成功以訪客身份登入');
          } else {
            // 如果用戶未登入，顯示身份驗證頁面
            return const AuthPage();
          }
        },
      ),
    );
  }
}

// 主頁面，包含底部導航欄
class MainPage extends StatefulWidget {
  final String? signInMessage;

  const MainPage({super.key, this.signInMessage});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 當前選中的頁面索引
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // 主頁面選項的列表
  final List<Widget> _widgetOptions = [
    HomePage(),
    const VocabularyPage(),
    const NotesPage(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.signInMessage != null) {
      // 如果有登入信息，顯示頂部 Snackbar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTopSnackBar(context, widget.signInMessage!, SnackBarType.success);
      });
    }
  }

  // 點擊底部導航欄時調用的方法
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 顯示當前選中的頁面
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 底部導航欄
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

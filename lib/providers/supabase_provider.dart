import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../vocabulary.dart';

// SupabaseProvider 類，管理用戶身份驗證和數據庫操作
class SupabaseProvider extends ChangeNotifier {
  // Supabase 客戶端
  final SupabaseClient _supabaseClient;
  // 當前用戶
  User? _currentUser;
  // session 過期時間
  DateTime? _expiryDate;
  // 計時器，用於自動登出
  Timer? _authTimer;
  // 是否為訪客
  bool _isGuest = false; // 新增的變數

  // 構造函數，初始化 Supabase 客戶端並自動登入
  SupabaseProvider(String url, String key)
      : _supabaseClient = SupabaseClient(
          url,
          key,
          authOptions: AuthClientOptions(
            pkceAsyncStorage: SecureStorage(),
          ),
        ) {
    _autoSignIn();
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      // 監聽身份驗證狀態變化
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  // 獲取 Supabase 客戶端
  SupabaseClient get client => _supabaseClient;

  // 判斷用戶是否已登入
  bool get isLoggedIn => _currentUser != null;
  // 判斷是否為訪客
  bool get isGuest => _isGuest;

  // 訪客登入方法
  void guestSignIn() {
    _isGuest = true;
    notifyListeners();
  }

  // 自動登入方法，從本地存儲恢復 session
  Future<void> _autoSignIn() async {
    // 從本地存儲中讀取之前保存的 session JSON 字符串
    final prefs = await SharedPreferences.getInstance();
    // 使用 Supabase 提供的 recoverSession 方法恢復用戶的會話
    final sessionJson = prefs.getString('session');

    if (sessionJson != null) {
      try {
        // 使用 session JSON 恢復用戶
        final response = await _supabaseClient.auth.recoverSession(sessionJson);
        // 如果恢復會話成功，將恢復的用戶設置為當前用戶
        _currentUser = response.user;
        // 設置會話的過期時間
        _expiryDate =
            DateTime.now().add(Duration(seconds: response.session!.expiresIn!));
        // 確保會話過期時自動登出
        _autoLogout();
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  // 用戶註冊方法
  Future<void> signUp(String email, String password) async {
    try {
      await _supabaseClient.auth.signUp(email: email, password: password);
    } catch (error) {
      print('error: ${error.toString()}');
      rethrow;
    }
  }

  // 用戶登入方法
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (response.user == null) {
        throw ('找不到使用者');
      }

      _currentUser = response.user;
      _expiryDate =
          DateTime.now().add(Duration(seconds: response.session!.expiresIn!));

      _autoLogout();
      notifyListeners();

      // 將 session 保存到本地存儲
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session', jsonEncode(response.session!.toJson()));
    } catch (error) {
      rethrow;
    }
  }

  // 用戶登出方法
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    _currentUser = null;
    _expiryDate = null;
    _isGuest = false;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    // 清除本地存儲的 session
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('session');
    notifyListeners();
  }

  // 自動登出方法
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    if (_expiryDate != null) {
      final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
    }
  }

  // 保存筆記方法
  Future<void> saveNote(VocabularyEntry? entry) async {
    final userId = _currentUser?.id;

    if (userId != null && entry != null) {
      try {
        // 將定義列表轉換為 JSON 字符串
        final definitionsJson =
            jsonEncode(entry.definitions.map((e) => e.toJson()).toList());

        await _supabaseClient.from('notes').insert({
          'user_id': userId,
          'word': entry.word,
          'definitions': definitionsJson,
          'letter_count': entry.letterCount,
        });
      } catch (error) {
        print(error);

        if (error is PostgrestException) {
          switch (error.code) {
            case '23505':
              throw ('單字已存在');
            default:
              throw ('儲存失敗');
          }
        }
        throw ('儲存失敗');
      }
    } else {
      throw ('無效的用戶或單字');
    }
  }

  // 刪除筆記方法
  Future<void> deleteNote(VocabularyEntry? entry) async {
    final userId = _currentUser?.id;

    if (userId != null && entry != null) {
      try {
        await _supabaseClient
            .from('notes')
            .delete()
            .eq('user_id', userId)
            .eq('word', entry.word);
      } catch (error) {
        if (error is PostgrestException) {
          throw ('刪除失敗');
        }
        throw ('刪除失敗');
      }
    } else {
      throw ('無效的用戶或單字');
    }
  }

  // 獲取筆記列表方法
  Future<List<Note>> getNotes() async {
    final userId = _currentUser?.id;

    if (userId == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      throw ('使用者未登入');
    }

    try {
      // 從數據庫中查詢用戶的筆記
      final response =
          await _supabaseClient.from('notes').select().eq('user_id', userId);

      List<Note> notes = response.map((note) => Note.fromDB(note)).toList();

      return notes;
    } catch (error) {
      print(error);

      if (error is PostgrestException) {
        throw ('搜尋失敗');
      }
      throw ('搜尋失敗');
    }
  }
}

// 定義 SecureStorage 類，用於安全存儲數據
class SecureStorage implements GotrueAsyncStorage {
  // 使用 FlutterSecureStorage 來安全存儲數據
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> removeItem({required String key}) async {
    // 刪除指定 key 的數據
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    // 存儲 key-value 數據
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> getItem({required String key}) async {
    // 獲取指定 key 的數據
    return await _secureStorage.read(key: key);
  }
}

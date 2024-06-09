import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../vocabulary.dart';

class SupabaseProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient;
  User? _currentUser;
  DateTime? _expiryDate;
  Timer? _authTimer;

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
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  SupabaseClient get client => _supabaseClient;

  bool get isLoggedIn => _currentUser != null;

  Future<void> _autoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('session');

    print('Stored session: $sessionJson');

    if (sessionJson != null) {
      try {
        final response = await _supabaseClient.auth.recoverSession(sessionJson);
        _currentUser = response.user;
        _expiryDate =
            DateTime.now().add(Duration(seconds: response.session!.expiresIn!));
        _autoLogout();
        notifyListeners();
        print('自動登入成功');
      } catch (error) {
        print('自動登入失敗: $error');
      }
    }
  }

  Future<void> signUp(String email, String password) async {
    final response =
        await _supabaseClient.auth.signUp(email: email, password: password);

    if (response.session == null) {
      throw ('註冊失敗');
    }

    _currentUser = response.user;
    _expiryDate =
        DateTime.now().add(Duration(seconds: response.session!.expiresIn!));

    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session', jsonEncode(response.session!.toJson()));
  }

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session', jsonEncode(response.session!.toJson()));
    } catch (error) {
      throw error;
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    _currentUser = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('session');
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    if (_expiryDate != null) {
      final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw ('無法重置密碼');
    }
  }

  Future<void> saveNote(VocabularyEntry? entry) async {
    final userId = _currentUser?.id;

    if (userId != null && entry != null) {
      try {
        final definitionsJson =
            jsonEncode(entry.definitions.map((e) => e.toJson()).toList());

        final response = await _supabaseClient.from('notes').insert({
          'user_id': userId,
          'word': entry.word,
          'definitions': definitionsJson,
          'letter_count': entry.letterCount,
        });

        print(response);
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

  Future<void> deleteNote(VocabularyEntry? entry) async {
    final userId = _currentUser?.id;

    if (userId != null && entry != null) {
      try {
        final response = await _supabaseClient
            .from('notes')
            .delete()
            .eq('user_id', userId)
            .eq('word', entry.word);

        print(response);
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

  Future<List<Note>> getNotes() async {
    final userId = _currentUser?.id;

    if (userId == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      throw ('使用者未登入');
    }

    try {
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

class SecureStorage implements GotrueAsyncStorage {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Future<void> removeItem({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> getItem({required String key}) async {
    return await _secureStorage.read(key: key);
  }
}

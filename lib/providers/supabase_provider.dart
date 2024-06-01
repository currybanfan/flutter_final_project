import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../vocabulary.dart';

class SupabaseProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient;
  User? _currentUser;

  SupabaseProvider(String url, String key)
      : _supabaseClient = SupabaseClient(
          url,
          key,
          authOptions: AuthClientOptions(
            pkceAsyncStorage: SecureStorage(),
          ),
        ) {
    _currentUser = _supabaseClient.auth.currentUser;

    _supabaseClient.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  SupabaseClient get client => _supabaseClient;

  bool get isLoggedIn => _currentUser != null;

  Future<String> signUp(String email, String password) async {
    final response =
        await _supabaseClient.auth.signUp(email: email, password: password);

    if (response.session == null) {
      throw ('註冊失敗');
    }

    notifyListeners();
    return '註冊成功';
  }

  Future<String> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (response.user == null) {
        throw ('找不到使用者');
      }
      _currentUser = response.user;
    } catch (error) {
      if (error is AuthException) {
        switch (error.statusCode) {
          case '400':
            throw ('帳號或密碼錯誤');
          default:
            throw ('登入失敗');
        }
      }
      throw ('登入失敗');
    }

    notifyListeners();
    return '登入成功';
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    _currentUser = null;
    notifyListeners();
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
    }

    throw ('無效的用戶或單字');
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
    }
    throw ('無效的用戶或單字');
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

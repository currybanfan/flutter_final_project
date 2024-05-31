import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'secure_storage.dart';
import 'data.dart';

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

  Future<void> signUp(String email, String password) async {
    final response =
        await _supabaseClient.auth.signUp(email: email, password: password);
    if (response.session == null) {
      throw Exception('註冊失敗');
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final response = await _supabaseClient.auth
        .signInWithPassword(email: email, password: password);
    if (response.user == null) {
      throw Exception('登入失敗');
    } else {
      _currentUser = response.user;
      print(response.user);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> saveNote(VocabularyEntry? entry) async {
    final userId = _currentUser?.id;

    if (userId != null && entry != null) {
      final response = await _supabaseClient.from('notes').insert({
        'user_id': userId,
        'word': entry.word,
        'definitions': entry.definitions.map((e) => e.text).join(', '),
      });

      if (response.error != null) {
        print('Error saving word: ${response.error!.message}');
      } else {
        print('Word saved successfully');
      }
    }
  }
}

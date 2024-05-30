import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase/supabase.dart';

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

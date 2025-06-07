import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  // Simpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Hapus token saat logout
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Cek apakah user sudah login (ada token)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

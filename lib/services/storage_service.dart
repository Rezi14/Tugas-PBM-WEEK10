import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'dart:convert';

/// Service untuk menyimpan dan mengambil data dari secure storage
class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Key constants untuk storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // ===================== Token Methods =====================

  /// Menyimpan Bearer Token ke secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Mengambil Bearer Token dari secure storage
  /// Mengembalikan null jika token tidak ditemukan
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Menghapus Bearer Token dari secure storage (untuk logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ===================== User Methods =====================

  /// Menyimpan data user sebagai JSON string
  static Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Mengambil data user dari storage
  /// Mengembalikan null jika tidak ditemukan
  static Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  // ===================== Session Methods =====================

  /// Cek apakah user sudah login (token tersedia)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Hapus semua data dari storage (untuk logout penuh)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

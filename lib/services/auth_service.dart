import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Service untuk autentikasi: login dan logout
class AuthService {
  static const String _loginEndpoint = '/api/auth/login';

  /// Melakukan login ke API dengan username dan password (NIM)
  /// Menyimpan token dan data user ke secure storage jika berhasil
  /// Melempar ApiException jika login gagal
  static Future<User> login(String username, String password) async {
    final response = await ApiService.postPublic(_loginEndpoint, {
      'username': username,
      'password': password,
    });

    if (response['success'] == true) {
      final data = response['data'];
      final token = data['token'] as String;
      final user = User.fromJson(data['user']);

      // Simpan token dan data user ke secure storage
      await StorageService.saveToken(token);
      await StorageService.saveUser(user);

      return user;
    } else {
      throw ApiException(response['message'] ?? 'Login gagal.');
    }
  }

  /// Melakukan logout: hapus semua data sesi dari storage
  static Future<void> logout() async {
    await StorageService.clearAll();
  }
}

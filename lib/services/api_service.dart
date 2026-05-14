import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Exception custom untuk error dari API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Base service untuk semua HTTP request ke API backend
class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const Duration _timeout = Duration(seconds: 30);

  // ===================== Header Builder =====================

  /// Header dasar tanpa token (untuk login)
  static Map<String, String> _baseHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Header dengan Bearer Token (untuk semua request setelah login)
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ===================== Response Handler =====================

  /// Memproses response HTTP dan melempar exception jika error
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Ambil pesan error dari response API jika ada
    final message = body['message'] ?? 'Terjadi kesalahan pada server.';
    throw ApiException(message, statusCode: response.statusCode);
  }

  // ===================== HTTP Methods =====================

  /// GET request dengan Bearer Token
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// POST request dengan body JSON (tanpa token, untuk login)
  static Future<Map<String, dynamic>> postPublic(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(uri, headers: _baseHeaders(), body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// POST request dengan Bearer Token
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// DELETE request dengan Bearer Token
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: headers)
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

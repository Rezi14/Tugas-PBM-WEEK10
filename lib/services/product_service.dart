import '../models/product_model.dart';
import 'api_service.dart';

/// Service untuk manajemen produk draft
class ProductService {
  static const String _productsEndpoint = '/api/products';
  static const String _submitEndpoint = '/api/products/submit';

  /// Mengambil daftar produk draft milik user yang login
  /// GET /api/products — memerlukan Bearer Token
  static Future<List<Product>> getProducts() async {
    final response = await ApiService.get(_productsEndpoint);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final productsList = data['products'] as List<dynamic>;
      return productsList.map((item) => Product.fromJson(item)).toList();
    } else {
      throw ApiException(response['message'] ?? 'Gagal mengambil data produk.');
    }
  }

  /// Menyimpan produk draft baru
  /// POST /api/products — memerlukan Bearer Token
  static Future<Product> createProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final response = await ApiService.post(_productsEndpoint, {
      'name': name,
      'price': price,
      'description': description,
    });

    if (response['success'] == true) {
      // Response data bisa langsung object produk atau nested di 'product'
      final raw = response['data'];
      final Map<String, dynamic> data = raw is Map<String, dynamic>
          ? raw
          : <String, dynamic>{};

      // Cek apakah data berisi 'product' nested atau langsung field produk
      final Map<String, dynamic> productData =
          (data['product'] is Map<String, dynamic>)
          ? data['product'] as Map<String, dynamic>
          : data;

      return Product.fromJson(productData);
    } else {
      throw ApiException(
        response['message'] as String? ?? 'Gagal menyimpan produk.',
      );
    }
  }

  /// Soft delete produk berdasarkan ID
  /// DELETE /api/products/{id} — memerlukan Bearer Token
  static Future<void> deleteProduct(int id) async {
    final response = await ApiService.delete('$_productsEndpoint/$id');

    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Gagal menghapus produk.');
    }
  }

  /// Submit tugas dengan data produk dan GitHub URL
  /// POST /api/products/submit — memerlukan Bearer Token
  static Future<SubmitResult> submitTask({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final response = await ApiService.post(_submitEndpoint, {
      'name': name,
      'price': price,
      'description': description,
      'github_url': githubUrl,
    });

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return SubmitResult.fromJson(data);
    } else {
      throw ApiException(response['message'] ?? 'Gagal submit tugas.');
    }
  }
}

// Model untuk produk draft
class Product {
  final int id;
  final String name;
  final int price;
  final String description;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Membuat objek Product dari JSON response API
  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse harga secara defensif — bisa int, double, String, atau String desimal "3000.00"
    int parsePrice(dynamic val) {
      if (val == null) {
        return 0;
      }
      if (val is int) {
        return val;
      }
      if (val is double) {
        return val.toInt();
      }
      if (val is String) {
        return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
      }
      return (val as num).toInt();
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return (val as num).toInt();
    }

    return Product(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: parsePrice(json['price']),
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// Konversi ke JSON untuk request body (tambah produk)
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'description': description,
  };
}

// Model untuk submit tugas (dengan tambahan github_url)
class SubmitProduct {
  final String name;
  final int price;
  final String description;
  final String githubUrl;

  SubmitProduct({
    required this.name,
    required this.price,
    required this.description,
    required this.githubUrl,
  });

  /// Konversi ke JSON untuk request body submit tugas
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'description': description,
    'github_url': githubUrl,
  };
}

// Model untuk hasil submit tugas dari response API
class SubmitResult {
  final int id;
  final String name;
  final int price;
  final String description;
  final String githubUrl;
  final String submittedAt;
  final String createdAt;

  SubmitResult({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.githubUrl,
    required this.submittedAt,
    required this.createdAt,
  });

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    int parsePrice(dynamic val) {
      if (val == null) {
        return 0;
      }
      if (val is int) {
        return val;
      }
      if (val is double) {
        return val.toInt();
      }
      if (val is String) {
        return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
      }
      return (val as num).toInt();
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return (val as num).toInt();
    }

    return SubmitResult(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: parsePrice(json['price']),
      description: json['description'] as String? ?? '',
      githubUrl: json['github_url'] as String? ?? '',
      submittedAt: json['submitted_at'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

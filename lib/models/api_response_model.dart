// Generic wrapper untuk semua response dari API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  /// Membuat ApiResponse dari JSON, dengan fungsi konversi data opsional
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) =>
      ApiResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : null,
      );
}

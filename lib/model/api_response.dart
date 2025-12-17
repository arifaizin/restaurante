/// Generic API response wrapper class for consistent API response handling
class ApiResponse<T> {
  final bool error;
  final String message;
  final int? count;
  final T data;

  ApiResponse({
    required this.error,
    required this.message,
    this.count,
    required this.data,
  });

  /// Creates an ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      count: json['count'],
      data: fromJsonT(json),
    );
  }

  /// Creates a successful ApiResponse
  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      error: false,
      message: message,
      data: data,
    );
  }

  /// Creates an error ApiResponse
  factory ApiResponse.failure(String message, {T? data}) {
    return ApiResponse<T>(
      error: true,
      message: message,
      data: data ?? (null as T),
    );
  }

  /// Returns true if the response is successful (no error)
  bool get isSuccess => !error;

  /// Returns true if the response has an error
  bool get hasError => error;
}

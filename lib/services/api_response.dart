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

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      error: false,
      message: message ?? 'Success',
      data: data,
    );
  }

  factory ApiResponse.failure(String message, {T? data}) {
    return ApiResponse<T>(
      error: true,
      message: message,
      data: data ?? _getDefaultValue<T>(),
    );
  }

  static T _getDefaultValue<T>() {
    final typeString = T.toString();
    if (typeString.startsWith('List')) {
      return <dynamic>[] as T;
    }
    return null as T;
  }

  bool get isSuccess => !error;
  bool get isFailure => error;
}

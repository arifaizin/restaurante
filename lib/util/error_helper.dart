/// Error types for categorizing different kinds of errors
enum ErrorType {
  network,
  timeout,
  server,
  validation,
  authentication,
  notFound,
  format,
  security,
  unknown
}

/// Error information with type and user-friendly message
class ErrorInfo {
  final ErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final bool isRetryable;
  final String? actionGuidance;

  const ErrorInfo({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    this.isRetryable = true,
    this.actionGuidance,
  });
}

class ErrorHelper {
  /// Converts technical error messages to user-friendly messages
  static String getUserFriendlyMessage(String? errorMessage) {
    final errorInfo = getErrorInfo(errorMessage);
    return errorInfo.userMessage;
  }

  /// Gets comprehensive error information including type and guidance
  static ErrorInfo getErrorInfo(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return const ErrorInfo(
        type: ErrorType.unknown,
        userMessage: 'Terjadi kesalahan yang tidak diketahui',
        isRetryable: true,
        actionGuidance:
            'Silakan coba lagi atau hubungi dukungan jika masalah berlanjut.',
      );
    }

    final lowerError = errorMessage.toLowerCase();

    // Timeout errors (check first to avoid being caught by other patterns)
    if (lowerError.contains('timeoutexception') ||
        lowerError.contains('timeout') ||
        lowerError.contains('timed out') ||
        lowerError.contains('time out') ||
        lowerError.contains('deadline exceeded')) {
      return ErrorInfo(
        type: ErrorType.timeout,
        userMessage: 'Koneksi terlalu lambat',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Coba lagi dalam beberapa saat atau periksa kecepatan internet Anda.',
      );
    }

    // Certificate/SSL errors (check before network to avoid conflicts)
    if (lowerError.contains('certificate') ||
        lowerError.contains('ssl') ||
        lowerError.contains('handshake') ||
        lowerError.contains('tls')) {
      return ErrorInfo(
        type: ErrorType.security,
        userMessage: 'Masalah keamanan koneksi',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance: 'Periksa koneksi internet Anda atau coba lagi nanti.',
      );
    }

    // Network related errors
    if (lowerError.contains('socketexception') ||
        lowerError.contains('network') ||
        lowerError.contains('internet') ||
        lowerError.contains('connection') ||
        lowerError.contains('host lookup failed') ||
        lowerError.contains('no address associated with hostname')) {
      return ErrorInfo(
        type: ErrorType.network,
        userMessage: 'Tidak ada koneksi internet',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance: 'Periksa koneksi internet Anda dan coba lagi.',
      );
    }

    // Server errors
    if (lowerError.contains('500') ||
        lowerError.contains('internal server error') ||
        lowerError.contains('server error') ||
        lowerError.contains('502') ||
        lowerError.contains('503') ||
        lowerError.contains('bad gateway') ||
        lowerError.contains('service unavailable')) {
      return ErrorInfo(
        type: ErrorType.server,
        userMessage: 'Server sedang bermasalah',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Coba lagi dalam beberapa menit. Jika masalah berlanjut, hubungi dukungan.',
      );
    }

    // Not found errors
    if (lowerError.contains('404') || lowerError.contains('not found')) {
      return ErrorInfo(
        type: ErrorType.notFound,
        userMessage: 'Data yang dicari tidak ditemukan',
        technicalMessage: errorMessage,
        isRetryable: false,
        actionGuidance: 'Pastikan data yang Anda cari masih tersedia.',
      );
    }

    // Unauthorized errors
    if (lowerError.contains('401') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('403') ||
        lowerError.contains('forbidden')) {
      return ErrorInfo(
        type: ErrorType.authentication,
        userMessage: 'Akses ditolak',
        technicalMessage: errorMessage,
        isRetryable: false,
        actionGuidance: 'Periksa izin akses Anda atau hubungi administrator.',
      );
    }

    // Format/parsing errors (check before validation to avoid conflicts)
    if (lowerError.contains('formatexception') ||
        lowerError.contains('json') ||
        lowerError.contains('parse') ||
        lowerError.contains('format')) {
      return ErrorInfo(
        type: ErrorType.format,
        userMessage: 'Data yang diterima tidak valid',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Coba lagi nanti. Jika masalah berlanjut, hubungi dukungan.',
      );
    }

    // Validation errors (specific to review submission)
    if (lowerError.contains('validation') ||
        lowerError.contains('invalid') ||
        lowerError.contains('required') ||
        lowerError.contains('empty') ||
        lowerError.contains('nama') ||
        lowerError.contains('ulasan')) {
      return ErrorInfo(
        type: ErrorType.validation,
        userMessage: 'Data yang dimasukkan tidak valid',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Periksa kembali data yang Anda masukkan dan pastikan semua field terisi dengan benar.',
      );
    }

    // Generic fallback for other technical errors
    if (lowerError.contains('exception') ||
        lowerError.contains('error') ||
        lowerError.contains('failed')) {
      return ErrorInfo(
        type: ErrorType.unknown,
        userMessage: 'Terjadi kesalahan saat memproses permintaan',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Silakan coba lagi. Jika masalah berlanjut, hubungi dukungan.',
      );
    }

    // If no pattern matches, return a generic message
    return ErrorInfo(
      type: ErrorType.unknown,
      userMessage: 'Terjadi kesalahan',
      technicalMessage: errorMessage,
      isRetryable: true,
      actionGuidance:
          'Silakan coba lagi atau hubungi dukungan jika masalah berlanjut.',
    );
  }

  /// Determines if the error is network-related
  static bool isNetworkError(String? errorMessage) {
    if (errorMessage == null) return false;
    return getErrorInfo(errorMessage).type == ErrorType.network;
  }

  /// Determines if the error is retryable
  static bool isRetryableError(String? errorMessage) {
    if (errorMessage == null) return true;
    return getErrorInfo(errorMessage).isRetryable;
  }

  /// Gets specific error message for review submission failures
  static String getReviewSubmissionErrorMessage(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return 'Gagal mengirim ulasan. Silakan coba lagi.';
    }

    final errorInfo = getErrorInfo(errorMessage);

    switch (errorInfo.type) {
      case ErrorType.network:
        return 'Tidak dapat mengirim ulasan karena tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
      case ErrorType.timeout:
        return 'Pengiriman ulasan gagal karena koneksi terlalu lambat. Coba lagi dalam beberapa saat.';
      case ErrorType.server:
        return 'Server sedang bermasalah. Ulasan Anda belum terkirim, silakan coba lagi nanti.';
      case ErrorType.validation:
        return 'Data ulasan tidak valid. Periksa kembali nama dan isi ulasan Anda.';
      case ErrorType.authentication:
        return 'Akses ditolak untuk mengirim ulasan. Silakan coba lagi.';
      case ErrorType.format:
        return 'Terjadi kesalahan dalam memproses ulasan. Coba lagi nanti.';
      case ErrorType.security:
        return 'Masalah keamanan koneksi saat mengirim ulasan. Periksa koneksi internet Anda dan coba lagi.';
      default:
        return 'Gagal mengirim ulasan. ${errorInfo.userMessage}';
    }
  }

  static int _successMessageCounter = 0;

  /// Gets success message variations for review submission
  static String getReviewSubmissionSuccessMessage() {
    final messages = [
      'Ulasan berhasil ditambahkan! Terima kasih atas feedback Anda.',
      'Ulasan Anda telah berhasil dikirim dan akan segera tampil.',
      'Terima kasih! Ulasan Anda berhasil ditambahkan ke restoran ini.',
      'Ulasan berhasil dikirim! Pengalaman Anda akan membantu pengguna lain.',
      'Berhasil! Ulasan Anda telah tersimpan dan dapat dilihat oleh pengguna lain.',
      'Terima kasih telah berbagi pengalaman! Ulasan Anda berhasil ditambahkan.',
      'Ulasan berhasil dikirim! Feedback Anda sangat berharga untuk restoran ini.',
      'Selamat! Ulasan Anda telah berhasil dipublikasikan.',
    ];

    // Use a counter for better test predictability while maintaining variety
    final now = DateTime.now();
    final seed = (_successMessageCounter++ + now.microsecondsSinceEpoch) %
        messages.length;
    return messages[seed];
  }

  /// Gets validation error messages for specific fields
  static String getValidationErrorMessage(String field, String? value) {
    switch (field.toLowerCase()) {
      case 'name':
      case 'nama':
        if (value == null || value.trim().isEmpty) {
          return 'Nama tidak boleh kosong. Masukkan nama Anda untuk melanjutkan.';
        }
        if (value.trim().length < 2) {
          return 'Nama terlalu pendek. Masukkan minimal 2 karakter.';
        }
        if (value.trim().length > 50) {
          return 'Nama terlalu panjang. Maksimal 50 karakter.';
        }
        break;
      case 'review':
      case 'ulasan':
        if (value == null || value.trim().isEmpty) {
          return 'Ulasan tidak boleh kosong. Bagikan pengalaman Anda tentang restoran ini.';
        }
        if (value.trim().length < 10) {
          return 'Ulasan terlalu pendek. Tulis minimal 10 karakter untuk memberikan feedback yang berguna.';
        }
        if (value.trim().length > 500) {
          return 'Ulasan terlalu panjang. Maksimal 500 karakter.';
        }
        break;
    }
    return 'Data tidak valid. Silakan periksa kembali.';
  }
}

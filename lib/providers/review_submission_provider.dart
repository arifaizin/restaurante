import 'package:flutter/foundation.dart';
import '../model/review_submission_request.dart';
import '../services/api_service.dart';
import '../util/error_helper.dart';

/// Provider class for managing review submission state
class ReviewSubmissionProvider extends ChangeNotifier {
  final ApiService _apiService;

  // Private state variables
  bool _isSubmitting = false;
  String? _submissionError;
  String? _successMessage;
  ErrorType? _lastErrorType;
  bool _isRetryable = true;

  // Form state
  String _reviewerName = '';
  String _reviewText = '';

  // Validation errors
  String? _nameError;
  String? _reviewError;

  ReviewSubmissionProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Getters for accessing state properties
  bool get isSubmitting => _isSubmitting;
  String? get submissionError => _submissionError;
  String? get successMessage => _successMessage;
  bool get hasSubmissionError => _submissionError != null;
  bool get hasSuccessMessage => _successMessage != null;
  ErrorType? get lastErrorType => _lastErrorType;
  bool get isRetryable => _isRetryable;
  bool get isNetworkError => _lastErrorType == ErrorType.network;
  bool get isValidationError => _lastErrorType == ErrorType.validation;

  // Form state getters
  String get reviewerName => _reviewerName;
  String get reviewText => _reviewText;
  String? get nameError => _nameError;
  String? get reviewError => _reviewError;
  bool get hasNameError => _nameError != null;
  bool get hasReviewError => _reviewError != null;
  bool get hasValidationErrors => _nameError != null || _reviewError != null;

  // Private helper methods
  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setSubmissionError(String error, [String? originalError]) {
    _submissionError = error;
    _successMessage = null;

    // Determine error type and retry capability using original error if available
    final errorForAnalysis = originalError ?? error;
    final errorInfo = ErrorHelper.getErrorInfo(errorForAnalysis);
    _lastErrorType = errorInfo.type;
    _isRetryable = errorInfo.isRetryable;

    notifyListeners();
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _submissionError = null;
    notifyListeners();
  }

  void _clearMessages() {
    _submissionError = null;
    _successMessage = null;
    _lastErrorType = null;
    _isRetryable = true;
    notifyListeners();
  }

  void _setNameError(String? error) {
    _nameError = error;
    notifyListeners();
  }

  void _setReviewError(String? error) {
    _reviewError = error;
    notifyListeners();
  }

  /// Updates the reviewer name and validates it
  void updateReviewerName(String name) {
    _reviewerName = name;
    _validateName();
    _clearMessages();
  }

  /// Updates the review text and validates it
  void updateReviewText(String text) {
    _reviewText = text;
    _validateReview();
    _clearMessages();
  }

  /// Validates the reviewer name field
  void _validateName() {
    _setNameError(null);
  }

  /// Validates the review text field
  void _validateReview() {
    _setReviewError(null);
  }

  /// Validates the entire form
  bool validateForm() {
    _validateName();
    _validateReview();
    return !hasValidationErrors;
  }

  /// Submits a review for the specified restaurant
  Future<bool> submitReview(String restaurantId) async {
    // Store restaurant ID for retry functionality
    _lastRestaurantId = restaurantId;

    // Validate form before submission
    if (!validateForm()) {
      return false;
    }

    _setSubmitting(true);
    _clearMessages();

    try {
      final request = ReviewSubmissionRequest(
        id: restaurantId,
        name: _reviewerName.trim(),
        review: _reviewText.trim(),
      );

      final response = await _apiService.submitReview(request);

      if (response.isSuccess) {
        // Use enhanced success message
        _setSuccessMessage(ErrorHelper.getReviewSubmissionSuccessMessage());
        clearForm();
        // Clear the stored restaurant ID after successful submission
        _lastRestaurantId = null;
        return true;
      } else {
        // Use enhanced error message for review submission
        final originalError = response.message;
        final errorMessage = ErrorHelper.getReviewSubmissionErrorMessage(
          originalError,
        );
        _setSubmissionError(errorMessage, originalError);
        return false;
      }
    } catch (e) {
      // Use enhanced error message for exceptions
      final originalError = e.toString();
      final errorMessage = ErrorHelper.getReviewSubmissionErrorMessage(
        originalError,
      );
      _setSubmissionError(errorMessage, originalError);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Clears the form fields and validation errors
  void clearForm() {
    _reviewerName = '';
    _reviewText = '';
    _setNameError(null);
    _setReviewError(null);
    notifyListeners();
  }

  /// Resets the entire provider state
  void resetState() {
    clearForm();
    _clearMessages();
    _setSubmitting(false);
  }

  /// Clears only the error messages
  void clearError() {
    _submissionError = null;
    _lastErrorType = null;
    _isRetryable = true;
    notifyListeners();
  }

  /// Clears only the success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // Store the last submission data for retry functionality
  String? _lastRestaurantId;

  /// Retries the last failed submission
  Future<bool> retrySubmission() async {
    if (_lastRestaurantId != null &&
        _reviewerName.trim().isNotEmpty &&
        _reviewText.trim().isNotEmpty) {
      return await submitReview(_lastRestaurantId!);
    }
    return false;
  }

  /// Gets contextual error guidance based on error type
  String? getErrorGuidance() {
    if (_submissionError == null) return null;
    final errorInfo = ErrorHelper.getErrorInfo(_submissionError);
    return errorInfo.actionGuidance;
  }

  /// Gets user-friendly error title based on error type
  String getErrorTitle() {
    switch (_lastErrorType) {
      case ErrorType.network:
        return 'Masalah Koneksi';
      case ErrorType.timeout:
        return 'Koneksi Lambat';
      case ErrorType.server:
        return 'Masalah Server';
      case ErrorType.validation:
        return 'Data Tidak Valid';
      case ErrorType.authentication:
        return 'Akses Ditolak';
      case ErrorType.notFound:
        return 'Data Tidak Ditemukan';
      case ErrorType.format:
        return 'Format Tidak Valid';
      case ErrorType.security:
        return 'Masalah Keamanan';
      default:
        return 'Terjadi Kesalahan';
    }
  }

  /// Checks if the current error should show troubleshooting help
  bool shouldShowTroubleshooting() {
    return _lastErrorType == ErrorType.network ||
        _lastErrorType == ErrorType.timeout ||
        _lastErrorType == ErrorType.security;
  }

  /// Gets specific troubleshooting steps for the current error
  List<String> getTroubleshootingSteps() {
    switch (_lastErrorType) {
      case ErrorType.network:
        return [
          'Periksa koneksi Wi-Fi atau data seluler',
          'Pastikan sinyal internet stabil',
          'Coba tutup dan buka kembali aplikasi',
          'Periksa pengaturan jaringan perangkat',
        ];
      case ErrorType.timeout:
        return [
          'Tunggu beberapa saat dan coba lagi',
          'Periksa kecepatan koneksi internet',
          'Pindah ke lokasi dengan sinyal lebih baik',
          'Tutup aplikasi lain yang menggunakan internet',
        ];
      case ErrorType.security:
        return [
          'Periksa koneksi internet Anda',
          'Pastikan tanggal dan waktu perangkat benar',
          'Coba gunakan jaringan Wi-Fi yang berbeda',
          'Restart aplikasi dan coba lagi',
        ];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}

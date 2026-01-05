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
  unknown,
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
        userMessage: 'An unknown error occurred',
        isRetryable: true,
        actionGuidance:
            'Please try again or contact support if the problem persists.',
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
        userMessage: 'Connection too slow',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance: 'Try again in a moment or check your internet speed.',
      );
    }

    // Certificate/SSL errors (check before network to avoid conflicts)
    if (lowerError.contains('certificate') ||
        lowerError.contains('ssl') ||
        lowerError.contains('handshake') ||
        lowerError.contains('tls')) {
      return ErrorInfo(
        type: ErrorType.security,
        userMessage: 'Connection security problem',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance: 'Check your internet connection or try again later.',
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
        userMessage: 'No internet connection',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance: 'Check your internet connection and try again.',
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
        userMessage: 'Server is having trouble',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Try again in a few minutes. If the problem persists, contact support.',
      );
    }

    // Not found errors
    if (lowerError.contains('404') || lowerError.contains('not found')) {
      return ErrorInfo(
        type: ErrorType.notFound,
        userMessage: 'The requested data was not found',
        technicalMessage: errorMessage,
        isRetryable: false,
        actionGuidance:
            'Make sure the data you are looking for is still available.',
      );
    }

    // Unauthorized errors
    if (lowerError.contains('401') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('403') ||
        lowerError.contains('forbidden')) {
      return ErrorInfo(
        type: ErrorType.authentication,
        userMessage: 'Access denied',
        technicalMessage: errorMessage,
        isRetryable: false,
        actionGuidance: 'Check your permissions or contact the administrator.',
      );
    }

    // Format/parsing errors (check before validation to avoid conflicts)
    if (lowerError.contains('formatexception') ||
        lowerError.contains('json') ||
        lowerError.contains('parse') ||
        lowerError.contains('format')) {
      return ErrorInfo(
        type: ErrorType.format,
        userMessage: 'Invalid data received',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Try again later. If the problem persists, contact support.',
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
        userMessage: 'The entered data is invalid',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Please re-check your input and ensure all fields are filled correctly.',
      );
    }

    // Generic fallback for other technical errors
    if (lowerError.contains('exception') ||
        lowerError.contains('error') ||
        lowerError.contains('failed')) {
      return ErrorInfo(
        type: ErrorType.unknown,
        userMessage: 'An error occurred while processing the request',
        technicalMessage: errorMessage,
        isRetryable: true,
        actionGuidance:
            'Please try again. If the problem persists, contact support.',
      );
    }

    // If no pattern matches, return a generic message
    return ErrorInfo(
      type: ErrorType.unknown,
      userMessage: 'An error occurred',
      technicalMessage: errorMessage,
      isRetryable: true,
      actionGuidance:
          'Please try again or contact support if the problem persists.',
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
      return 'Failed to submit review. Please try again.';
    }

    final errorInfo = getErrorInfo(errorMessage);

    switch (errorInfo.type) {
      case ErrorType.network:
        return 'Unable to submit review because there is no internet connection. Check your connection and try again.';
      case ErrorType.timeout:
        return 'Review submission failed due to a slow connection. Try again in a moment.';
      case ErrorType.server:
        return 'Server is having trouble. Your review has not been sent, please try again later.';
      case ErrorType.validation:
        return 'Invalid review data. Please re-check your name and review content.';
      case ErrorType.authentication:
        return 'Access denied to submit review. Please try again.';
      case ErrorType.format:
        return 'An error occurred while processing the review. Try again later.';
      case ErrorType.security:
        return 'Connection security problem while submitting review. Check your internet connection and try again.';
      default:
        return 'Failed to submit review. ${errorInfo.userMessage}';
    }
  }

  static int _successMessageCounter = 0;

  /// Gets success message variations for review submission
  static String getReviewSubmissionSuccessMessage() {
    final messages = [
      'Review successfully added! Thank you for your feedback.',
      'Your review has been successfully submitted and will appear soon.',
      'Thank you! Your review was successfully added to this restaurant.',
      'Review submitted successfully! Your experience will help other users.',
      'Success! Your review has been saved and can be seen by other users.',
      'Thank you for sharing your experience! Your review was successfully added.',
      'Review submitted successfully! Your feedback is valuable for this restaurant.',
      'Congratulations! Your review has been successfully published.',
    ];

    // Use a counter for better test predictability while maintaining variety
    final now = DateTime.now();
    final seed =
        (_successMessageCounter++ + now.microsecondsSinceEpoch) %
        messages.length;
    return messages[seed];
  }

  /// Gets validation error messages for specific fields
  static String getValidationErrorMessage(String field, String? value) {
    switch (field.toLowerCase()) {
      case 'name':
      case 'nama':
        if (value == null || value.trim().isEmpty) {
          return 'Name cannot be empty. Please enter your name to continue.';
        }
        if (value.trim().length < 2) {
          return 'Name is too short. Enter at least 2 characters.';
        }
        if (value.trim().length > 50) {
          return 'Name is too long. Maximum 50 characters.';
        }
        break;
      case 'review':
      case 'ulasan':
        if (value == null || value.trim().isEmpty) {
          return 'Review cannot be empty. Share your experience about this restaurant.';
        }
        if (value.trim().length < 10) {
          return 'Review is too short. Write at least 10 characters to provide useful feedback.';
        }
        if (value.trim().length > 500) {
          return 'Review is too long. Maximum 500 characters.';
        }
        break;
    }
    return 'Invalid data. Please re-check your input.';
  }
}

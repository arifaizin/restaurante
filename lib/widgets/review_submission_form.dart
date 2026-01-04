import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_submission_provider.dart';
import '../util/error_helper.dart';

/// A form widget for submitting restaurant reviews
class ReviewSubmissionForm extends StatefulWidget {
  final String restaurantId;
  final VoidCallback? onSubmissionSuccess;

  const ReviewSubmissionForm({
    Key? key,
    required this.restaurantId,
    this.onSubmissionSuccess,
  }) : super(key: key);

  @override
  State<ReviewSubmissionForm> createState() => _ReviewSubmissionFormState();
}

class _ReviewSubmissionFormState extends State<ReviewSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _reviewFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Listen to controller changes and update provider
    _nameController.addListener(() {
      final provider =
          Provider.of<ReviewSubmissionProvider>(context, listen: false);
      provider.updateReviewerName(_nameController.text);
    });

    _reviewController.addListener(() {
      final provider =
          Provider.of<ReviewSubmissionProvider>(context, listen: false);
      provider.updateReviewText(_reviewController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    _nameFocusNode.dispose();
    _reviewFocusNode.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20.0,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(16.0),
        elevation: 6.0,
      ),
    );
  }

  void _showErrorSnackBar(
      BuildContext context, String message, ErrorType? errorType) {
    Color backgroundColor;
    IconData icon;

    switch (errorType) {
      case ErrorType.network:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.wifi_off;
        break;
      case ErrorType.timeout:
        backgroundColor = Colors.amber.shade700;
        icon = Icons.access_time;
        break;
      case ErrorType.server:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error_outline;
        break;
      case ErrorType.validation:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_outline;
        break;
      default:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20.0,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        duration: Duration(seconds: 6),
        margin: EdgeInsets.all(16.0),
        elevation: 6.0,
      ),
    );
  }

  void _handleSubmit() async {
    final provider =
        Provider.of<ReviewSubmissionProvider>(context, listen: false);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Submit review
    final success = await provider.submitReview(widget.restaurantId);

    if (success) {
      // Clear form controllers
      _nameController.clear();
      _reviewController.clear();

      // Remove focus from fields
      _nameFocusNode.unfocus();
      _reviewFocusNode.unfocus();

      // Clear any existing error messages from provider
      provider.clearError();

      // Call success callback if provided - this will trigger refresh
      widget.onSubmissionSuccess?.call();

      // Show enhanced success message
      if (mounted) {
        _showSuccessSnackBar(
            context, provider.successMessage ?? 'Ulasan berhasil ditambahkan');
      }
    } else {
      // Show contextual error feedback for critical errors
      if (mounted && provider.hasSubmissionError) {
        final errorType = provider.lastErrorType;

        // Show snackbar for certain error types that need immediate attention
        if (errorType == ErrorType.authentication ||
            errorType == ErrorType.notFound ||
            (!provider.isRetryable && errorType != ErrorType.validation)) {
          _showErrorSnackBar(context, provider.submissionError!, errorType);
        }
      }
    }
  }

  Color _getErrorBackgroundColor(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange.shade50;
      case ErrorType.timeout:
        return Colors.amber.shade50;
      case ErrorType.server:
        return Colors.red.shade50;
      case ErrorType.validation:
        return Colors.blue.shade50;
      default:
        return Colors.red.shade50;
    }
  }

  Color _getErrorBorderColor(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange.shade200;
      case ErrorType.timeout:
        return Colors.amber.shade200;
      case ErrorType.server:
        return Colors.red.shade200;
      case ErrorType.validation:
        return Colors.blue.shade200;
      default:
        return Colors.red.shade200;
    }
  }

  Color _getErrorIconBackgroundColor(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange.shade100;
      case ErrorType.timeout:
        return Colors.amber.shade100;
      case ErrorType.server:
        return Colors.red.shade100;
      case ErrorType.validation:
        return Colors.blue.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  Color _getErrorIconColor(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange.shade600;
      case ErrorType.timeout:
        return Colors.amber.shade700;
      case ErrorType.server:
        return Colors.red.shade600;
      case ErrorType.validation:
        return Colors.blue.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  Color _getErrorTextColor(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange.shade800;
      case ErrorType.timeout:
        return Colors.amber.shade800;
      case ErrorType.server:
        return Colors.red.shade800;
      case ErrorType.validation:
        return Colors.blue.shade800;
      default:
        return Colors.red.shade800;
    }
  }

  IconData _getErrorIcon(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.access_time;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.validation:
        return Icons.info_outline;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Masalah Koneksi';
      case ErrorType.timeout:
        return 'Koneksi Lambat';
      case ErrorType.server:
        return 'Masalah Server';
      case ErrorType.validation:
        return 'Data Tidak Valid';
      default:
        return 'Terjadi Kesalahan';
    }
  }

  String _getErrorGuidance(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.authentication:
        return 'Silakan hubungi administrator untuk mendapatkan akses.';
      case ErrorType.notFound:
        return 'Data restoran mungkin sudah tidak tersedia.';
      default:
        return 'Hubungi dukungan jika masalah berlanjut.';
    }
  }

  void _showTroubleshootingDialog(
      BuildContext context, ReviewSubmissionProvider provider) {
    final steps = provider.getTroubleshootingSteps();
    final title = provider.getErrorTitle();

    IconData dialogIcon;
    Color iconColor;

    switch (provider.lastErrorType) {
      case ErrorType.network:
        dialogIcon = Icons.wifi_off;
        iconColor = Colors.orange.shade600;
        break;
      case ErrorType.timeout:
        dialogIcon = Icons.access_time;
        iconColor = Colors.amber.shade700;
        break;
      case ErrorType.security:
        dialogIcon = Icons.security;
        iconColor = Colors.red.shade600;
        break;
      default:
        dialogIcon = Icons.help_outline;
        iconColor = Colors.blue.shade600;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(dialogIcon, color: iconColor),
              SizedBox(width: 8.0),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coba langkah-langkah berikut untuk mengatasi masalah:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.0),
              ...steps.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final step = entry.value;
                return _buildTroubleshootingStep(index.toString(), step);
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Coba Lagi'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTroubleshootingStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewSubmissionProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form header
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: Colors.orange,
                      size: 20.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Tulis Ulasan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // Name input field
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  enabled: !provider.isSubmitting,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Anda',
                    hintText: 'Masukkan nama Anda',
                    prefixIcon: Icon(Icons.person_outline),
                    errorText:
                        provider.hasNameError ? provider.nameError : null,
                    semanticCounterText: 'Nama reviewer',
                  ),
                  validator: (value) {
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // Move focus to review field
                    FocusScope.of(context).requestFocus(_reviewFocusNode);
                  },
                ),
                SizedBox(height: 16.0),

                // Review text input field
                TextFormField(
                  controller: _reviewController,
                  focusNode: _reviewFocusNode,
                  enabled: !provider.isSubmitting,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Ulasan Anda',
                    hintText: 'Bagikan pengalaman Anda tentang restoran ini...',
                    prefixIcon: Icon(Icons.rate_review_outlined),
                    errorText:
                        provider.hasReviewError ? provider.reviewError : null,
                    semanticCounterText: 'Teks ulasan',
                  ),
                  validator: (value) {
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // Submit form when done is pressed
                    _handleSubmit();
                  },
                ),
                SizedBox(height: 20.0),

                // Enhanced error message display with type-specific handling
                if (provider.hasSubmissionError) ...[
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _getErrorBackgroundColor(provider.lastErrorType),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: _getErrorBorderColor(provider.lastErrorType)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: _getErrorIconBackgroundColor(
                                    provider.lastErrorType),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getErrorIcon(provider.lastErrorType),
                                color:
                                    _getErrorIconColor(provider.lastErrorType),
                                size: 18.0,
                              ),
                            ),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.getErrorTitle(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: _getErrorTextColor(
                                              provider.lastErrorType),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    provider.submissionError!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: _getErrorTextColor(
                                                  provider.lastErrorType)
                                              .withValues(alpha: 0.8),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color:
                                    _getErrorIconColor(provider.lastErrorType),
                                size: 20.0,
                              ),
                              onPressed: () => provider.clearError(),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 32.0,
                                minHeight: 32.0,
                              ),
                            ),
                          ],
                        ),
                        if (provider.isRetryable) ...[
                          SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (provider.shouldShowTroubleshooting()) ...[
                                TextButton.icon(
                                  onPressed: provider.isSubmitting
                                      ? null
                                      : () {
                                          // Show contextual troubleshooting tips
                                          _showTroubleshootingDialog(
                                              context, provider);
                                        },
                                  icon: Icon(
                                    Icons.help_outline,
                                    size: 16.0,
                                  ),
                                  label: Text('Bantuan'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue.shade600,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                              ],
                              ElevatedButton.icon(
                                onPressed: provider.isSubmitting
                                    ? null
                                    : _handleSubmit,
                                icon: Icon(
                                  Icons.refresh,
                                  size: 16.0,
                                ),
                                label: Text(
                                  provider.isNetworkError
                                      ? 'Coba Lagi'
                                      : 'Kirim Ulang',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getErrorIconColor(
                                      provider.lastErrorType),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          SizedBox(height: 8.0),
                          Text(
                            _getErrorGuidance(provider.lastErrorType),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      _getErrorTextColor(provider.lastErrorType)
                                          .withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: provider.isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16.0,
                                height: 16.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Mengirim...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 18.0),
                              SizedBox(width: 8.0),
                              Text(
                                'Kirim Ulasan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

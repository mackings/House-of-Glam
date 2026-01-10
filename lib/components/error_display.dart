import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

/// Reusable widget to display errors in a user-friendly way
class ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract clean error message
    String errorMessage = customMessage ?? _extractErrorMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.orange.shade400),
            const SizedBox(height: 20),
            CustomText(
              errorMessage,
              fontSize: 16,
              textAlign: TextAlign.center,
              color: Colors.black87,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _extractErrorMessage(dynamic error) {
    if (error == null) return "An error occurred. Please try again.";

    String errorString = error.toString();

    // Remove "Exception: " prefix
    errorString = errorString.replaceFirst('Exception: ', '');

    // Remove technical stack trace info if present
    if (errorString.contains('\n')) {
      errorString = errorString.split('\n').first;
    }

    return errorString;
  }
}

/// Compact error display for inline use (e.g., in lists)
class CompactErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const CompactErrorDisplay({Key? key, required this.error, this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    String errorMessage = error.toString().replaceFirst('Exception: ', '');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Error",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: Colors.purple,
              tooltip: "Retry",
            ),
          ],
        ],
      ),
    );
  }
}

/// Error display with custom icon and title
class CustomErrorDisplay extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const CustomErrorDisplay({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.title,
    this.onRetry,
    this.retryButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: iconColor ?? Colors.orange.shade400),
            const SizedBox(height: 20),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
            ],
            CustomText(
              message,
              fontSize: 16,
              textAlign: TextAlign.center,
              color: Colors.black87,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(retryButtonText ?? "Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

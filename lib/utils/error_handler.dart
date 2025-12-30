import 'dart:convert';
import 'dart:io';

/// Utility class for handling API errors and converting them to user-friendly messages
class ErrorHandler {
  /// Extracts user-friendly error message from various error types
  static String getUserFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return "No internet connection. Please check your network and try again.";
    }

    if (error is FormatException) {
      return "Invalid data received. Please try again.";
    }

    if (error is Exception) {
      final errorString = error.toString();

      // Remove "Exception: " prefix
      String cleanError = errorString.replaceFirst('Exception: ', '');

      // Try to extract message from JSON response
      if (cleanError.contains('{') && cleanError.contains('}')) {
        try {
          final jsonStart = cleanError.indexOf('{');
          final jsonString = cleanError.substring(jsonStart);
          final jsonData = json.decode(jsonString);

          if (jsonData is Map && jsonData.containsKey('message')) {
            return _formatMessage(jsonData['message']);
          }
        } catch (e) {
          // If JSON parsing fails, continue with string processing
        }
      }

      // Handle common error patterns
      if (cleanError.toLowerCase().contains('failed to fetch') ||
          cleanError.toLowerCase().contains('not found')) {
        return _extractMeaningfulMessage(cleanError);
      }

      if (cleanError.toLowerCase().contains('timeout')) {
        return "Request timed out. Please try again.";
      }

      if (cleanError.toLowerCase().contains('unauthorized') ||
          cleanError.toLowerCase().contains('401')) {
        return "Your session has expired. Please login again.";
      }

      if (cleanError.toLowerCase().contains('forbidden') ||
          cleanError.toLowerCase().contains('403')) {
        return "You don't have permission to perform this action.";
      }

      if (cleanError.toLowerCase().contains('500') ||
          cleanError.toLowerCase().contains('server error')) {
        return "Server error occurred. Please try again later.";
      }

      return cleanError;
    }

    return error.toString();
  }

  /// Extracts meaningful message from error string
  static String _extractMeaningfulMessage(String error) {
    // Try to extract message from JSON embedded in error
    if (error.contains('{"message":')) {
      try {
        final jsonStart = error.indexOf('{');
        final jsonString = error.substring(jsonStart);
        final jsonData = json.decode(jsonString);
        if (jsonData is Map && jsonData.containsKey('message')) {
          return _formatMessage(jsonData['message']);
        }
      } catch (e) {
        // Continue with other extraction methods
      }
    }

    // Common patterns to extract
    if (error.toLowerCase().contains('materials not found')) {
      return "No materials available at the moment.";
    }

    if (error.toLowerCase().contains('user not found')) {
      return "User account not found.";
    }

    if (error.toLowerCase().contains('invalid credentials')) {
      return "Invalid email or password.";
    }

    // Remove technical prefixes
    error = error
        .replaceAll('Failed to fetch tailor materials: ', '')
        .replaceAll('Failed to fetch assigned materials: ', '')
        .replaceAll('Failed to fetch ', '')
        .replaceAll('Failed to create ', '')
        .replaceAll('Failed to update ', '')
        .replaceAll('Failed to submit ', '');

    return error;
  }

  /// Formats message to be more user-friendly
  static String _formatMessage(String message) {
    // Capitalize first letter
    if (message.isNotEmpty) {
      message = message[0].toUpperCase() + message.substring(1);
    }

    // Add period at the end if not present
    if (!message.endsWith('.') &&
        !message.endsWith('!') &&
        !message.endsWith('?')) {
      message += '.';
    }

    // Handle specific messages
    final Map<String, String> messageMap = {
      'materials not found': 'No materials available at the moment.',
      'user not found': 'User account not found.',
      'invalid token': 'Your session has expired. Please login again.',
      'token expired': 'Your session has expired. Please login again.',
      'validation failed': 'Please check your input and try again.',
      'invalid credentials': 'Invalid email or password.',
      'email already exists': 'This email is already registered.',
      'phone already exists': 'This phone number is already registered.',
    };

    final lowerMessage = message.toLowerCase();
    for (var entry in messageMap.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    return message;
  }

  /// Parses API error response and returns user-friendly message
  static String parseApiError(String responseBody, int statusCode) {
    try {
      final jsonData = json.decode(responseBody);

      if (jsonData is Map) {
        // Check for message field
        if (jsonData.containsKey('message')) {
          return _formatMessage(jsonData['message']);
        }

        // Check for error field
        if (jsonData.containsKey('error')) {
          return _formatMessage(jsonData['error']);
        }

        // Check for errors array
        if (jsonData.containsKey('errors') && jsonData['errors'] is List) {
          final errors = jsonData['errors'] as List;
          if (errors.isNotEmpty) {
            return _formatMessage(errors.first.toString());
          }
        }
      }
    } catch (e) {
      // If JSON parsing fails, return status-based message
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return "Invalid request. Please check your input.";
      case 401:
        return "Your session has expired. Please login again.";
      case 403:
        return "You don't have permission to perform this action.";
      case 404:
        return "The requested resource was not found.";
      case 500:
      case 502:
      case 503:
        return "Server error occurred. Please try again later.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Helper class with useful utility methods
class Helpers {
  /// Format a DateTime object to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  /// Format a DateTime object to include time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - h:mm a').format(date);
  }
  
  /// Calculate time ago (e.g., "2 days ago")
  static String timeAgo(DateTime date) {
    final Duration difference = DateTime.now().difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Get a human-readable file size
  static String getFileSize(File file) {
    final int bytes = file.lengthSync();
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Extract file name from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }
  
  /// Generate a random color
  static Color getRandomColor() {
    return Colors.primaries[DateTime.now().millisecondsSinceEpoch % Colors.primaries.length];
  }
  
  /// Get first letter capitalized
  static String getInitial(String text) {
    if (text.isEmpty) return '';
    return text.substring(0, 1).toUpperCase();
  }
  
  /// Show a snackbar with a message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Check if string is a valid URL
  static bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }
  
  /// Truncate text with ellipsis if longer than maxLength
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
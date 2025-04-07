import 'package:flutter/material.dart';

class FirebaseErrorHandler {
  static String handleFirestoreError(dynamic error) {
    String errorMessage = error.toString();

    // Check for common Firestore errors
    if (errorMessage.contains('failed-precondition')) {
      if (errorMessage.contains('query requires an index')) {
        return 'This query requires a Firestore index. Please check the Firebase console.';
      }
    }

    if (errorMessage.contains('permission-denied')) {
      return 'You do not have permission to access this data.';
    }

    if (errorMessage.contains('not-found')) {
      return 'The requested document was not found.';
    }

    if (errorMessage.contains('network-request-failed')) {
      return 'Network connection error. Please check your internet connection.';
    }

    return 'An error occurred: $errorMessage';
  }

  static Widget buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            if (errorMessage.contains('index'))
              Text(
                'Administrators: Create the required index in the Firebase console.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}

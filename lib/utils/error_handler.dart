import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/error_dialog.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'requires-recent-login':
          return 'Please log in again to complete this action.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'An unknown error occurred.';
  }

  static void showError({
    required BuildContext context,
    required dynamic error,
    String? title,
    VoidCallback? onRetry,
    bool showRetry = false,
  }) {
    final message = getErrorMessage(error);
    showErrorDialog(
      context: context,
      title: title ?? 'Error',
      message: message,
      onRetry: showRetry ? onRetry : null,
      showOkButton: true,
    );
  }

  static void handleError({
    required BuildContext context,
    required dynamic error,
    required String operation,
    VoidCallback? onRetry,
    bool showRetry = false,
  }) {
    final message = getErrorMessage(error);
    showErrorDialog(
      context: context,
      title: 'Error During $operation',
      message: message,
      onRetry: showRetry ? onRetry : null,
      showOkButton: true,
    );
  }
}

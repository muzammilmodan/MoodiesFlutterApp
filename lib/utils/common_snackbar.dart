import 'package:flutter/material.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CommonSnackbar {
  static void showErrorSnackbar({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccessSnackbar({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? 'Success',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showInfoSnackbar({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? 'Info',
        message: message,
        contentType: ContentType.help,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showInfoNoInternetSnackbar({
    required BuildContext context,
  }) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 5),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: const AwesomeSnackbarContent(
        title: '🚫 Connection Lost!',
        message:
        'It looks like your internet connection is down. Please check your connection and try again!',
        contentType: ContentType.warning,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

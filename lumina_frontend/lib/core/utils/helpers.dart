import 'package:flutter/material.dart';

class Helpers {
  const Helpers._();

  static void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

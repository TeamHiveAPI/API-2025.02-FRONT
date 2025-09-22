import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

void showCustomSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final Color backgroundColor = isError ? deleteRed : successGreen;

  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
    backgroundColor: backgroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

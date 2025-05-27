import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void errorNotice(BuildContext context, String message) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  Flushbar(
    messageText: Text(
      message,
      style: isDark
          ? theme.textTheme.bodyMedium?.copyWith(color: Colors.white)
          : theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: isDark ? Colors.redAccent : Color(0xFFB00020),
    icon: Icon(Icons.error_outline,
        color: isDark ? Colors.white : Colors.black),
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);
}

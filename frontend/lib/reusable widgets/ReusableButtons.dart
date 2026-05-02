
import 'package:flutter/material.dart';
import 'package:pos_system/reusable%20widgets/AppColors.dart';

Widget SecondaryButton(
  String text,
  bool isDark,
  VoidCallback onPressed, {
  double? textSize,
}) {
  return Expanded(
    child: OutlinedButton(
      onPressed: () => onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: isDark ? AppColors.darkButtonsPrimary : Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
          fontSize: textSize,
        ),
      ),
    ),
  );
}

Widget GenerelButton(
  String text,
  bool isDark,
  VoidCallback onPressed, {
  double? textSize,
}) {
  return Expanded(
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? AppColors.darkButtonsPrimary
            : AppColors.accentBlue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: textSize,
        ),
      ),
    ),
  );
}

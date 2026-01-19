import 'package:flutter/material.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'AppColors.dart';
// ================= UI WIDGETS =================

Widget buildHeaderIconButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback onPressed,
  required Color color,
  required Color backgroundColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
    ),
  );
}

Widget buildSidebarMenuItem({
  required IconData icon,
  required String label,
  required bool isDark,
  required VoidCallback onTap,
  required bool isExpanded,
  int? iconSize,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
            size: 22,
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

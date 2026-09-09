import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00C48C);
  static const Color primaryDark = Color(0xFF0D5C46);
  static const Color primaryLight = Color(0xFFE6FAF3);
  static const Color accent = Color(0xFFFF7D54);
  static const Color accentYellow = Color(0xFFFFA927);
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFFCBD5E1);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF3E8FF);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);

  static const Color heartRed = Color(0xFFFF4D4F);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C48C), Color(0xFF009B6E)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007A5E), Color(0xFF00C48C)],
  );

  static const LinearGradient ticketGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F5A47), Color(0xFF00A878)],
  );
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const deepBlue = Color(0xFF0A1628);
  static const royalBlue = Color(0xFF1A3A6B);
  static const electricBlue = Color(0xFF2D6CDF);
  static const cyan = Color(0xFF00D4FF);
  static const cyanLight = Color(0xFF7AEAFF);

  // Purple Gradient
  static const purpleDeep = Color(0xFF6C3AED);
  static const purpleMid = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFBB9BFF);

  // Surfaces
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceGray = Color(0xFFF1F5F9);
  static const borderLight = Color(0xFFE2E8F0);

  // Dark Mode
  static const darkBg = Color(0xFF0B1121);
  static const darkSurface = Color(0xFF131B2E);
  static const darkCard = Color(0xFF1A2340);
  static const darkBorder = Color(0xFF2A3555);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textWhite = Color(0xFFFFFFFF);
  static const textDarkPrimary = Color(0xFFF1F5F9);
  static const textDarkSecondary = Color(0xFF94A3B8);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, purpleDeep],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, electricBlue],
  );

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleMid, purpleDeep],
  );

  static const darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xCC0A1628)],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, Color(0xFF1A1040), purpleDeep],
  );
}

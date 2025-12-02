import 'package:flutter/material.dart';

/// App color palette inspired by Messenger
class AppColors {
  AppColors._();
  
  // Primary Gradient (Messenger Blue)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0084FF), Color(0xFF0066CC)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
  );
  
  // Brand Colors
  static const Color primaryBlue = Color(0xFF0084FF);
  static const Color darkBlue = Color(0xFF0066CC);
  static const Color lightBlue = Color(0xFF4B9EFF);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF8E8E93);
  static const Color lightGrey = Color(0xFFF2F2F7);
  static const Color darkGrey = Color(0xFF3A3A3C);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceLight = Color(0xFFF2F2F7);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  
  // Message Bubble Colors
  static const Color senderBubbleLight = Color(0xFF0084FF);
  static const Color receiverBubbleLight = Color(0xFFE9E9EB);
  static const Color senderBubbleDark = Color(0xFF0084FF);
  static const Color receiverBubbleDark = Color(0xFF3A3A3C);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);
  
  // Online Status
  static const Color online = Color(0xFF34C759);
  static const Color offline = Color(0xFF8E8E93);
}

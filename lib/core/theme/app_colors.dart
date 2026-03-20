import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / deadline red
  static const Color deadlineRed = Color(0xFFBE002A);
  static const Color deadlineRedBg = Color(0xFF1A0005);

  // Priority palette
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFFF5722);
  static const Color priorityCritical = Color(0xFFBE002A);

  // Urgency (deadline countdown)
  static const Color urgencyOk = Color(0xFF4CAF50);
  static const Color urgencyWarning = Color(0xFFFF9800);
  static const Color urgencyCritical = Color(0xFFBE002A);
  static const Color urgencyOverdue = Color(0xFF9E9E9E);

  // Semantic helpers
  static Color urgencyColor(int daysRemaining) {
    if (daysRemaining < 0) return urgencyOverdue;
    if (daysRemaining < 3) return urgencyCritical;
    if (daysRemaining < 7) return urgencyWarning;
    return urgencyOk;
  }

  static Color priorityColor(int priority) {
    switch (priority) {
      case 0:
        return priorityLow;
      case 1:
        return priorityMedium;
      case 2:
        return priorityHigh;
      case 3:
        return priorityCritical;
      default:
        return priorityLow;
    }
  }
}

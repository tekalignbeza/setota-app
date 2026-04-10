import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8E8E);
  static const Color primaryDark = Color(0xFFE04545);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7EDDD6);
  static const Color secondaryDark = Color(0xFF36B0A8);
  static const Color accent = Color(0xFF45B7D1);
  static const Color accentLight = Color(0xFF72CDE0);
  static const Color accentDark = Color(0xFF2A9AB5);

  // Customer-specific Colors
  static const Color giftPink = Color(0xFFE91E8B);
  static const Color heartRed = Color(0xFFE74C3C);
  static const Color starGold = Color(0xFFFFD700);
  static const Color cartGreen = Color(0xFF27AE60);

  // Order Status Colors
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusConfirmed = Color(0xFF42A5F5);
  static const Color statusProcessing = Color(0xFFAB47BC);
  static const Color statusReady = Color(0xFF66BB6A);
  static const Color statusPickedUp = Color(0xFF26C6DA);
  static const Color statusOutForDelivery = Color(0xFF5C6BC0);
  static const Color statusDelivered = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFEF5350);

  // Neutral Greys
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF8F9FA);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEEEEEE);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Rating Colors
  static const Color ratingStar = Color(0xFFFFD700);
  static const Color ratingEmpty = Color(0xFFE0E0E0);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  /// Returns the color for a given order status string.
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return statusPending;
      case 'CONFIRMED':
        return statusConfirmed;
      case 'PROCESSING':
        return statusProcessing;
      case 'READY':
        return statusReady;
      case 'PICKED_UP':
        return statusPickedUp;
      case 'OUT_FOR_DELIVERY':
        return statusOutForDelivery;
      case 'DELIVERED':
        return statusDelivered;
      case 'CANCELLED':
        return statusCancelled;
      default:
        return grey500;
    }
  }
}

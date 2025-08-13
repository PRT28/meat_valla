import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  // Calculate discount percentage
  static double calculateDiscountPercentage(double original, double discounted) {
    if (original <= 0) return 0;
    return ((original - discounted) / original) * 100;
  }

  // Generate order tracking ID
  static String generateTrackingId() {
    return 'MV${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Show snackbar
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor ?? AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Validate quantity constraints
  static bool isValidQuantity(double quantity, double min, double max) {
    return quantity >= min && quantity <= max;
  }

  // Format quantity display
  static String formatQuantity(double quantity, String unit) {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '$quantity $unit';
  }

  // Calculate estimated delivery time
  static DateTime calculateEstimatedDelivery(DateTime orderTime, int hours) {
    return orderTime.add(Duration(hours: hours));
  }

  // Get time difference in readable format
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if address is valid for delivery
  static bool isValidDeliveryAddress(String pincode) {
    // Add your delivery area validation logic here
    // For now, accepting all pin codes
    return pincode.length == 6 && RegExp(r'^\d{6}$').hasMatch(pincode);
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
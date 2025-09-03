import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart' as order_model;
import '../supabase_options.dart';

class UpiPaymentService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Your UPI merchant details - UPDATE THESE WITH YOUR ACTUAL DETAILS
  static const String merchantUpiId = 'prithvirajtiwari28-1@okhdfcbank'; // Replace with your UPI ID
  static const String merchantName = 'Meat Valla'; // Your business name

  // Initialize UPI service
  static Future<void> initialize() async {
    // No initialization required for flutter_upi_india
    print('UPI Payment Service initialized');
  }

  // Get available UPI apps
  static Future<List<ApplicationMeta>> getAvailableUpiApps() async {
    try {
      final List<ApplicationMeta> apps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
      return apps;
    } catch (e) {
      print('Error getting UPI apps: $e');
      return [];
    }
  }

  // Process UPI payment
  static Future<PaymentResult> processUpiPayment({
    required String orderId,
    required double amount,
    required String transactionNote,
    ApplicationMeta? preferredApp,
  }) async {
    try {
      // Start UPI payment using the correct API
      final UpiTransactionResponse response = await UpiPay.initiateTransaction(
        amount: amount.toStringAsFixed(2),
        app: preferredApp?.upiApplication ?? UpiApplication.googlePay, // Default to Google Pay
        receiverName: merchantName,
        receiverUpiAddress: merchantUpiId,
        transactionRef: 'MEAT_${orderId.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}',
        transactionNote: transactionNote,
        // merchantCode: 'MEAT_VALLA', // Optional for non-merchant payments
      );

      // Handle response
      return _handleUpiResponse(response, orderId);
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        message: 'UPI payment failed: ${e.toString()}',
      );
    }
  }

  // Handle UPI response
  static PaymentResult _handleUpiResponse(UpiTransactionResponse response, String orderId) {
    // Note: The actual response structure may vary, so we handle it gracefully
    final status = response.status;

    if (status == UpiTransactionStatus.success) {
      return PaymentResult(
        success: true,
        transactionId: 'upi_${DateTime.now().millisecondsSinceEpoch}', // Generate ID since response may not have it
        transactionRef: orderId,
        message: 'Payment successful',
        upiResponse: response,
      );
    } else if (status == UpiTransactionStatus.failure) {
      return PaymentResult(
        success: false,
        error: 'Payment failed',
        message: 'Payment failed. Please try again.',
        upiResponse: response,
      );
    } else {
      // Handle other statuses (cancelled, etc.)
      return PaymentResult(
        success: false,
        error: 'Payment not completed',
        message: 'Payment was not completed',
        upiResponse: response,
      );
    }
  }

  // Update order payment status
  static Future<bool> updateOrderPaymentStatus({
    required String orderId,
    required String status,
    String? transactionId,
    String? transactionRef,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      await _supabase.from('orders').update({
        'payment_status': status,
        'payment_details': {
          'transactionId': transactionId,
          'transactionRef': transactionRef,
          'paymentMethod': 'upi',
          'timestamp': DateTime.now().toIso8601String(),
          ...?paymentDetails,
        },
        'updatedAt': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      return true;
    } catch (e) {
      print('Error updating order payment status: $e');
      return false;
    }
  }

  // Get supported payment methods for India
  static List<order_model.PaymentMethod> getSupportedPaymentMethods() {
    return [
      order_model.PaymentMethod.cashOnDelivery,
      order_model.PaymentMethod.upi,
    ];
  }

  // Get payment method configuration for UI
  static PaymentMethodConfig getPaymentMethodConfig(order_model.PaymentMethod method) {
    switch (method) {
      case order_model.PaymentMethod.cashOnDelivery:
        return PaymentMethodConfig(
          title: 'Cash on Delivery',
          subtitle: 'Pay when your order is delivered',
          icon: Icons.money,
          color: Colors.green,
          isOnline: false,
        );
      case order_model.PaymentMethod.upi:
        return PaymentMethodConfig(
          title: 'UPI Payment',
          subtitle: 'Pay using any UPI app (GPay, PhonePe, Paytm, etc.)',
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
          isOnline: true,
        );
      case order_model.PaymentMethod.card:
        return PaymentMethodConfig(
          title: 'Credit/Debit Card',
          subtitle: 'Coming soon',
          icon: Icons.credit_card,
          color: Colors.grey,
          isOnline: false,
        );
      case order_model.PaymentMethod.netBanking:
        return PaymentMethodConfig(
          title: 'Net Banking',
          subtitle: 'Coming soon',
          icon: Icons.account_balance,
          color: Colors.grey,
          isOnline: false,
        );
      case order_model.PaymentMethod.wallet:
        return PaymentMethodConfig(
          title: 'Wallet',
          subtitle: 'Coming soon',
          icon: Icons.wallet,
          color: Colors.grey,
          isOnline: false,
        );
    }
  }

  // Show UPI app selection dialog
  static Future<ApplicationMeta?> showUpiAppSelection(BuildContext context) async {
    final apps = await getAvailableUpiApps();

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No UPI apps found. Please install a UPI app like Google Pay, PhonePe, or Paytm.'),
          backgroundColor: Colors.orange,
        ),
      );
      return null;
    }

    return await showDialog<ApplicationMeta>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose UPI App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: apps.map((app) => ListTile(
            leading: app.iconImage(32), // Use the iconImage method
            title: Text(app.upiApplication.getAppName()),
            subtitle: Text('UPI Payment App'),
            onTap: () => Navigator.of(context).pop(app),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Create transaction note for order
  static String createTransactionNote(String orderId, List items) {
    final itemCount = items.length;
    return 'Meat Valla Order #${orderId.substring(0, 8)} - $itemCount items';
  }
}

// Payment result model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? transactionRef;
  final String? error;
  final String message;
  final UpiTransactionResponse? upiResponse;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.transactionRef,
    this.error,
    required this.message,
    this.upiResponse,
  });
}

// Payment method configuration for UI
class PaymentMethodConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isOnline;

  PaymentMethodConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isOnline,
  });
}

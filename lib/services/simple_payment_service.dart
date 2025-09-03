import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart' as order_model;
import '../supabase_options.dart';

class SimplePaymentService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Create payment intent (local mock for development)
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    required order_model.PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Local mock payment intent (no function call required)
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      final mockPaymentIntent = {
        'paymentIntent': {
          'id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}_${orderId.substring(0, 8)}',
          'client_secret': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}_secret_dev',
          'status': 'requires_payment_method',
          'amount': (amount * 100).round(),
          'currency': currency.toLowerCase(),
        },
        'mock': true,
        'message': 'Local mock payment intent for development'
      };

      // Store in local payment_intents table for tracking
      try {
        await _supabase.from('payment_intents').insert({
          'id': mockPaymentIntent['paymentIntent']['id'],
          'order_id': orderId,
          'amount': (amount * 100).round(),
          'currency': currency.toLowerCase(),
          'status': mockPaymentIntent['paymentIntent']['status'],
          'client_secret': mockPaymentIntent['paymentIntent']['client_secret'],
          'payment_method_type': paymentMethod.name,
          'metadata': {'mock': true, 'originalMetadata': metadata},
        });
      } catch (dbError) {
        print('Warning: Could not store mock payment intent in DB: $dbError');
        // Continue anyway - this is just for tracking
      }

      return mockPaymentIntent;
    } catch (e) {
      print('Error creating mock payment intent: $e');
      return null;
    }
  }

  // Process payment using web checkout (no native plugin required)
  static Future<PaymentResult> processWebPayment({
    required String orderId,
    required double amount,
    required order_model.PaymentMethod paymentMethod,
    required BuildContext context,
  }) async {
    try {
      // Create payment intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: 'inr',
        orderId: orderId,
        paymentMethod: paymentMethod,
      );

      if (paymentIntentData == null) {
        throw Exception('Failed to create payment intent');
      }

      // Show payment options dialog
      final result = await _showPaymentOptionsDialog(
        context: context,
        amount: amount,
        paymentMethod: paymentMethod,
        orderId: orderId,
      );

      return result;
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        message: 'Payment setup failed',
      );
    }
  }

  // Show payment options dialog
  static Future<PaymentResult> _showPaymentOptionsDialog({
    required BuildContext context,
    required double amount,
    required order_model.PaymentMethod paymentMethod,
    required String orderId,
  }) async {
    final result = await showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentOptionsDialog(
        amount: amount,
        paymentMethod: paymentMethod,
        orderId: orderId,
      ),
    );

    return result ?? PaymentResult(
      success: false,
      error: 'Payment cancelled',
      message: 'Payment was cancelled by user',
    );
  }

  // Verify payment status
  static Future<PaymentStatus> verifyPayment(String paymentIntentId) async {
    try {
      final response = await _supabase.functions.invoke(
        'verify-payment',
        body: {'paymentIntentId': paymentIntentId},
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return PaymentStatus.fromMap(data);
      } else {
        throw Exception('Failed to verify payment: ${response.status}');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      return PaymentStatus(
        status: 'failed',
        amount: 0,
        currency: 'inr',
      );
    }
  }

  // Update order payment status
  static Future<bool> updateOrderPaymentStatus({
    required String orderId,
    required String paymentIntentId,
    required String status,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      await _supabase.from('orders').update({
        'payment_intent_id': paymentIntentId,
        'payment_status': status,
        'payment_details': paymentDetails,
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
      order_model.PaymentMethod.card,
      order_model.PaymentMethod.upi,
      order_model.PaymentMethod.netBanking,
      order_model.PaymentMethod.wallet,
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
      case order_model.PaymentMethod.card:
        return PaymentMethodConfig(
          title: 'Credit/Debit Card',
          subtitle: 'Visa, Mastercard, RuPay',
          icon: Icons.credit_card,
          color: Colors.blue,
          isOnline: true,
        );
      case order_model.PaymentMethod.upi:
        return PaymentMethodConfig(
          title: 'UPI',
          subtitle: 'Pay using any UPI app',
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
          isOnline: true,
        );
      case order_model.PaymentMethod.netBanking:
        return PaymentMethodConfig(
          title: 'Net Banking',
          subtitle: 'All major banks supported',
          icon: Icons.account_balance,
          color: Colors.purple,
          isOnline: true,
        );
      case order_model.PaymentMethod.wallet:
        return PaymentMethodConfig(
          title: 'Wallet',
          subtitle: 'Paytm, PhonePe, Google Pay',
          icon: Icons.wallet,
          color: Colors.teal,
          isOnline: true,
        );
    }
  }
}

// Payment options dialog widget
class PaymentOptionsDialog extends StatefulWidget {
  final double amount;
  final order_model.PaymentMethod paymentMethod;
  final String orderId;

  const PaymentOptionsDialog({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.orderId,
  });

  @override
  State<PaymentOptionsDialog> createState() => _PaymentOptionsDialogState();
}

class _PaymentOptionsDialogState extends State<PaymentOptionsDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final config = SimplePaymentService.getPaymentMethodConfig(widget.paymentMethod);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(config.icon, color: config.color),
          const SizedBox(width: 8),
          Text(config.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Amount: ₹${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(config.subtitle),
          const SizedBox(height: 16),
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                const Text(
                  'Choose how to complete your payment:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  'Pay Now (Simulated)',
                  'Complete payment immediately',
                  Icons.payment,
                  () => _simulatePayment(true),
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  'Payment Failed (Test)',
                  'Simulate payment failure',
                  Icons.error,
                  () => _simulatePayment(false),
                ),
              ],
            ),
        ],
      ),
      actions: [
        if (!_isProcessing)
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              PaymentResult(
                success: false,
                error: 'Payment cancelled',
                message: 'Payment was cancelled by user',
              ),
            ),
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePayment(bool success) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (success) {
      Navigator.of(context).pop(
        PaymentResult(
          success: true,
          paymentIntentId: 'pi_simulated_${DateTime.now().millisecondsSinceEpoch}',
          message: 'Payment completed successfully',
        ),
      );
    } else {
      Navigator.of(context).pop(
        PaymentResult(
          success: false,
          error: 'Payment declined',
          message: 'Payment was declined by the bank',
        ),
      );
    }
  }
}

// Payment result model
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? error;
  final String message;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.error,
    required this.message,
  });
}

// Payment status model
class PaymentStatus {
  final String status;
  final int amount;
  final String currency;
  final Map<String, dynamic>? metadata;

  PaymentStatus({
    required this.status,
    required this.amount,
    required this.currency,
    this.metadata,
  });

  factory PaymentStatus.fromMap(Map<String, dynamic> map) {
    return PaymentStatus(
      status: map['status'] ?? 'unknown',
      amount: map['amount'] ?? 0,
      currency: map['currency'] ?? 'inr',
      metadata: map['metadata'],
    );
  }

  bool get isSuccessful => status == 'succeeded';
  bool get isPending => status == 'processing' || status == 'requires_action';
  bool get isFailed => status == 'failed' || status == 'canceled';
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

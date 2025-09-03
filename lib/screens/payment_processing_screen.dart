import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/simple_payment_service.dart';
import '../utils/app_colors.dart';
import 'OrderSuccess.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final AddressModel deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final PaymentMethod paymentMethod;
  final String? notes;

  const PaymentProcessingScreen({
    super.key,
    required this.cartItems,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.paymentMethod,
    this.notes,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = false;
  String _statusMessage = 'Initializing payment...';
  String? _orderId;

  double get total => widget.subtotal + widget.deliveryFee;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Payment'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent back navigation during processing
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Payment method icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SimplePaymentService.getPaymentMethodConfig(widget.paymentMethod).icon,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Loading indicator
              if (_isProcessing) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 24),
              ],
              
              // Status message
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Payment details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Method:'),
                        Text(
                          SimplePaymentService.getPaymentMethodConfig(widget.paymentMethod).title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Cancel button (only show if not processing critical steps)
              if (!_isProcessing || widget.paymentMethod == PaymentMethod.cashOnDelivery)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Creating order...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      // Create order first
      final orderId = await orderProvider.createOrder(
        userId: authProvider.user!.id,
        items: widget.cartItems,
        deliveryAddress: widget.deliveryAddress,
        subtotal: widget.subtotal,
        deliveryFee: widget.deliveryFee,
        notes: widget.notes,
      );

      if (orderId == null) {
        throw Exception('Failed to create order');
      }

      _orderId = orderId;

      if (widget.paymentMethod == PaymentMethod.cashOnDelivery) {
        // For COD, order is complete
        setState(() {
          _statusMessage = 'Order placed successfully!';
          _isProcessing = false;
        });

        // Clear cart and navigate to success
        cartProvider.clearCart();
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(orderId: orderId),
            ),
          );
        }
      } else {
        // Handle online payment
        await _handleOnlinePayment(orderId);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Payment failed: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleOnlinePayment(String orderId) async {
    setState(() {
      _statusMessage = 'Setting up payment...';
    });

    try {
      // Process payment using simple payment service
      final result = await SimplePaymentService.processWebPayment(
        orderId: orderId,
        amount: total,
        paymentMethod: widget.paymentMethod,
        context: context,
      );

      if (result.success) {
        // Payment successful
        setState(() {
          _statusMessage = 'Payment successful!';
          _isProcessing = false;
        });

        // Update order payment status
        await SimplePaymentService.updateOrderPaymentStatus(
          orderId: orderId,
          paymentIntentId: result.paymentIntentId!,
          status: 'paid',
        );

        // Clear cart
        Provider.of<CartProvider>(context, listen: false).clearCart();

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(orderId: orderId),
            ),
          );
        }
      } else {
        // Payment failed or cancelled
        setState(() {
          _statusMessage = result.message;
          _isProcessing = false;
        });

        if (result.error != 'Payment cancelled') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Payment failed: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

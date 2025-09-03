import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../services/upi_payment_service.dart';
import '../utils/app_colors.dart';
import 'payment_processing_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final AddressModel deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final String? notes;

  const PaymentSelectionScreen({
    super.key,
    required this.cartItems,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    this.notes,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;

  double get total => widget.subtotal + widget.deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('₹${widget.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Fee'),
                    Text('₹${widget.deliveryFee.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment Methods
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: UpiPaymentService.getSupportedPaymentMethods().length,
                      itemBuilder: (context, index) {
                        final paymentMethod = UpiPaymentService.getSupportedPaymentMethods()[index];
                        final config = UpiPaymentService.getPaymentMethodConfig(paymentMethod);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPaymentMethod == paymentMethod
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                              width: _selectedPaymentMethod == paymentMethod ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: RadioListTile<PaymentMethod>(
                            value: paymentMethod,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (PaymentMethod? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: config.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    config.icon,
                                    color: config.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        config.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        config.subtitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            activeColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null && !_isProcessing
                    ? _proceedToPayment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _selectedPaymentMethod == PaymentMethod.cashOnDelivery
                            ? 'Place Order'
                            : 'Proceed to Payment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_selectedPaymentMethod == PaymentMethod.cashOnDelivery) {
        // Handle COD order directly
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(
              cartItems: widget.cartItems,
              deliveryAddress: widget.deliveryAddress,
              subtotal: widget.subtotal,
              deliveryFee: widget.deliveryFee,
              paymentMethod: _selectedPaymentMethod!,
              notes: widget.notes,
            ),
          ),
        );
      } else {
        // Handle online payment
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(
              cartItems: widget.cartItems,
              deliveryAddress: widget.deliveryAddress,
              subtotal: widget.subtotal,
              deliveryFee: widget.deliveryFee,
              paymentMethod: _selectedPaymentMethod!,
              notes: widget.notes,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:meat_delivery/providers/order_provider.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/cart_item_widget.dart';
import 'AddressList.dart';
import 'OrderSuccess.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<AddressProvider>(context, listen: false)
            .loadAddresses(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _proceedToCheckout() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    
    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (addressProvider.selectedAddress == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddressListScreen()),
      );
      return;
    }

    _showOrderConfirmation();
  }

  void _showOrderConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Confirm Order',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Consumer3<CartProvider, AddressProvider, AuthProvider>(
                builder: (context, cartProvider, addressProvider, authProvider, child) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                                  Text('₹${cartProvider.subtotal.toStringAsFixed(0)}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery Fee:', style: TextStyle(fontSize: 16)),
                                  Text('₹${cartProvider.deliveryFee.toStringAsFixed(0)}'),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${cartProvider.total.toStringAsFixed(0)}',
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
                        
                        const SizedBox(height: 16),
                        
                        // Payment Method
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.payments, color: AppColors.primary),
                              SizedBox(width: 12),
                              Text(
                                'Cash on Delivery',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Confirm Button
                        CustomButton(
                          onPressed: () async {
                            final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                            final userProvider = Provider.of<AuthProvider>(context, listen: false);

                            final success = await orderProvider.createOrder(
                                userId: userProvider.user!.id,
                                items: cartProvider.items,
                                deliveryAddress: addressProvider.selectedAddress!,
                                subtotal: cartProvider.subtotal,
                                deliveryFee: cartProvider.deliveryFee
                            );

                            if (success != null) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                              );
                              cartProvider.clearCart();
                            }


                          },
                          child: const Text('Confirm Order'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add some delicious meat to get started!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return CartItemWidget(
                      item: item,
                      onRemove: () {
                        cartProvider.removeFromCart(item.id);
                      },
                      onQuantityChanged: (quantity) {
                        cartProvider.updateQuantity(item.id, quantity);
                      },
                    );
                  },
                ),
              ),
              
              // Bottom Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Price Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₹${cartProvider.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            cartProvider.deliveryFee == 0 
                                ? 'FREE' 
                                : '₹${cartProvider.deliveryFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: cartProvider.deliveryFee == 0 
                                  ? AppColors.success 
                                  : AppColors.textPrimary,
                              fontWeight: cartProvider.deliveryFee == 0 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      
                      if (cartProvider.deliveryFee > 0 && cartProvider.subtotal < 500) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Add ₹${(500 - cartProvider.subtotal).toStringAsFixed(0)} more for free delivery',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      
                      const Divider(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${cartProvider.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CustomButton(
                        onPressed: _proceedToCheckout,
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
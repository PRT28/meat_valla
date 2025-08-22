import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../utils/app_colors.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print(order.items.toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.trackingId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Order Date
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Items Summary
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${order.items.length} items',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  Text(
                    order.total.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order Progress or Actions
              if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(order.status),
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(order.status)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusMessage(order.status),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              
              // Delivery Address
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${order.deliveryAddress.addressLine1}, ${order.deliveryAddress.city}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
      case OrderStatus.packed:
        return AppColors.warning;
      case OrderStatus.outForDelivery:
        return AppColors.secondary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  double _getProgressValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 0.2;
      case OrderStatus.confirmed:
        return 0.4;
      case OrderStatus.preparing:
        return 0.6;
      case OrderStatus.packed:
        return 0.8;
      case OrderStatus.outForDelivery:
        return 0.9;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order placed successfully';
      case OrderStatus.confirmed:
        return 'Order confirmed by restaurant';
      case OrderStatus.preparing:
        return 'Your fresh meat is being prepared';
      case OrderStatus.packed:
        return 'Order packed and ready for pickup';
      case OrderStatus.outForDelivery:
        return 'On the way to your location';
      case OrderStatus.delivered:
        return 'Order delivered successfully';
      case OrderStatus.cancelled:
        return 'Order cancelled';
    }
  }
}
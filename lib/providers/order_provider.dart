import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../supabase_options.dart';

class OrderProvider extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('orders')
          .select()
          .eq('userId', userId)
          .order('orderDate', ascending: false);

      _orders = (response as List)
          .map((data) => OrderModel.fromMap(data))
          .toList();

      _setLoading(false);
    } catch (e) {
      print("error on loading orders ${e.toString()}");
      print(e.toString());
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<String?> createOrder({
    required String userId,
    required List<CartItem> items,
    required AddressModel deliveryAddress,
    required double subtotal,
    required double deliveryFee,
    PaymentMethod paymentMethod = PaymentMethod.cashOnDelivery,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final order = OrderModel(
        id: '', // Will be set by Firestore
        userId: userId,
        items: items,
        deliveryAddress: deliveryAddress,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: subtotal + deliveryFee,
        status: OrderStatus.placed,
        paymentMethod: paymentMethod,
        orderDate: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
        notes: notes,
        trackingId: _generateTrackingId(),
      );

      print(order);

      final response = await _supabase
          .from('orders')
          .insert(order.toCreateMap())
          .select()
          .single();

      final createdOrder = OrderModel.fromMap(response);
      _orders.insert(0, createdOrder);

      _setLoading(false);
      notifyListeners();
      return createdOrder.id;
    } catch (e) {
      print("Error in placing order");
      print(e.toString());
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': status.name,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<OrderModel> get activeOrders {
    return _orders.where((order) => 
        order.status != OrderStatus.delivered && 
        order.status != OrderStatus.cancelled
    ).toList();
  }

  List<OrderModel> get completedOrders {
    return _orders.where((order) => 
        order.status == OrderStatus.delivered
    ).toList();
  }

  String _generateTrackingId() {
    return 'MV${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
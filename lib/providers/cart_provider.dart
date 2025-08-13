import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => subtotal > 500 ? 0 : 50;
  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  void addToCart(ProductModel product, double quantity) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        productName: product.name,
        productImage: product.images.isNotEmpty ? product.images.first : '',
        price: product.price,
        quantity: quantity,
        unit: product.unit,
      );
      _items.add(cartItem);
    }
    
    notifyListeners();
  }

  void updateQuantity(String itemId, double quantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  double getProductQuantity(String productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
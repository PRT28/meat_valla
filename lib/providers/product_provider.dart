import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ProductModel> _products = [];
  List<ProductModel> _favoriteProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductModel> get favoriteProducts => _favoriteProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ProductModel> get featuredProducts => 
      _products.where((product) => product.isFeatured).toList();

  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();

      print("Reached Here");

      _products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      print(_products);

      _extractCategories();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _extractCategories() {
    final categorySet = <String>{};
    for (final product in _products) {
      categorySet.add(product.category);
    }
    _categories = categorySet.toList()..sort();
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.description.toLowerCase().contains(lowercaseQuery) ||
             product.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  void toggleFavorite(String productId) {
    final isFavorite = _favoriteProducts.any((product) => product.id == productId);
    
    if (isFavorite) {
      _favoriteProducts.removeWhere((product) => product.id == productId);
    } else {
      final product = getProductById(productId);
      if (product != null) {
        _favoriteProducts.add(product);
      }
    }
    
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProducts.any((product) => product.id == productId);
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
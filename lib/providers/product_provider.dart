import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _favoriteProducts = [];
  List<String> _favoriteIds = []; // Keep IDs separately
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

  ProductProvider() {
    _loadFavoriteIds();
  }

  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();

      _products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      _extractCategories();

      // Map favorite IDs to actual products
      _favoriteProducts = _products
          .where((product) => _favoriteIds.contains(product.id))
          .toList();

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

  /// Toggle favorite and persist in SharedPreferences

  Future<void> toggleFavorite(String productId) async {
    final isFavorite = _favoriteIds.contains(productId);

    if (isFavorite) {
      _favoriteIds.remove(productId);
      _favoriteProducts.removeWhere((product) => product.id == productId);
    } else {
      _favoriteIds.add(productId);
      final product = getProductById(productId);
      if (product != null) {
        _favoriteProducts.add(product);
      }
    }

    notifyListeners();
    await _saveFavoriteIds();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  // ------------------- SharedPreferences logic -------------------

  Future<void> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('favorite_product_ids') ?? [];
    print("Favorite IDs loaded: $_favoriteIds");
  }

  Future<void> _saveFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_product_ids', _favoriteIds);
    print("Favorite IDs saved: $_favoriteIds");
  }

  // ------------------- Private Helpers -------------------
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

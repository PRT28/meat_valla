import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Initialize sample data (call this once to populate Firebase)
  static Future<void> initializeSampleData() async {
    try {
      // Check if products already exist
      final productsSnapshot = await _firestore.collection('products').limit(1).get();
      if (productsSnapshot.docs.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      // Sample products data
      final sampleProducts = [
        {
          'name': 'Fresh Chicken Breast',
          'description': 'Premium quality boneless chicken breast, perfect for grilling and cooking. Rich in protein and lean meat.',
          'price': 280.0,
          'originalPrice': 320.0,
          'category': 'Chicken',
          'images': [
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
            'https://images.unsplash.com/photo-1587593810167-148b8bd8b2d1?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 5.0,
          'isAvailable': true,
          'isFeatured': true,
          'rating': 4.5,
          'reviewCount': 125,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Goat Mutton Curry Cut',
          'description': 'Fresh goat mutton cut in curry pieces. Perfect for traditional Indian curries and biryanis.',
          'price': 650.0,
          'category': 'Mutton',
          'images': [
            'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 3.0,
          'isAvailable': true,
          'isFeatured': true,
          'rating': 4.8,
          'reviewCount': 89,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Fresh Pomfret Fish',
          'description': 'Fresh pomfret fish, cleaned and cut. Rich in omega-3 fatty acids and perfect for frying.',
          'price': 480.0,
          'originalPrice': 520.0,
          'category': 'Fish',
          'images': [
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 2.0,
          'isAvailable': true,
          'isFeatured': false,
          'rating': 4.3,
          'reviewCount': 67,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Chicken Legs (Drumsticks)',
          'description': 'Fresh chicken drumsticks, perfect for roasting and BBQ. Tender and juicy meat.',
          'price': 200.0,
          'category': 'Chicken',
          'images': [
            'https://images.unsplash.com/photo-1562967914-608f82629710?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 3.0,
          'isAvailable': true,
          'isFeatured': true,
          'rating': 4.2,
          'reviewCount': 156,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Beef Steaks',
          'description': 'Premium beef steaks, perfectly cut for grilling. Tender and flavorful.',
          'price': 750.0,
          'category': 'Beef',
          'images': [
            'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 2.0,
          'isAvailable': true,
          'isFeatured': false,
          'rating': 4.7,
          'reviewCount': 43,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Fresh Prawns (Large)',
          'description': 'Large fresh prawns, cleaned and deveined. Perfect for curries and fries.',
          'price': 420.0,
          'category': 'Seafood',
          'images': [
            'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.25,
          'maxQuantity': 2.0,
          'isAvailable': true,
          'isFeatured': true,
          'rating': 4.4,
          'reviewCount': 92,
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];

      // Add products to Firestore
      final batch = _firestore.batch();
      for (final productData in sampleProducts) {
        final docRef = _firestore.collection('products').doc();
        batch.set(docRef, productData);
      }
      
      await batch.commit();
      print('Sample data initialized successfully');
      
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  // Get product by ID
  static Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Search products
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();

      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return products;
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
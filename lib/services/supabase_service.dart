import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../supabase_options.dart';

class SupabaseService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Initialize sample data (call this once to populate Supabase)
  static Future<void> initializeSampleData() async {
    try {
      // Check if products already exist
      final existingProducts = await _supabase
          .from('products')
          .select('id')
          .limit(1);
      
      if (existingProducts.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      final sampleProducts = [
        {
          'name': 'Fresh Chicken Breast',
          'description': 'Premium quality boneless chicken breast, perfect for grilling and cooking.',
          'price': 280.0,
          'category': 'Chicken',
          'images': [
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 5.0,
          'isAvailable': true,
          'isFeatured': true,
          'rating': 4.5,
          'reviewCount': 128,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Mutton Curry Cut',
          'description': 'Fresh mutton cut into perfect pieces for curry. Tender and flavorful.',
          'price': 650.0,
          'category': 'Mutton',
          'images': [
            'https://images.unsplash.com/photo-1588347818481-c7c1b6b3e3b5?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 3.0,
          'isAvailable': true,
          'isFeatured': true,
          'rating': 4.7,
          'reviewCount': 89,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Fresh Fish (Rohu)',
          'description': 'Fresh Rohu fish, cleaned and cut. Rich in protein and omega-3.',
          'price': 320.0,
          'category': 'Fish',
          'images': [
            'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=500',
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
          'name': 'Chicken Drumsticks',
          'description': 'Juicy chicken drumsticks, perfect for BBQ and roasting.',
          'price': 240.0,
          'category': 'Chicken',
          'images': [
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.5,
          'maxQuantity': 3.0,
          'isAvailable': true,
          'isFeatured': false,
          'rating': 4.4,
          'reviewCount': 95,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Goat Liver',
          'description': 'Fresh goat liver, rich in iron and vitamins. Perfect for traditional recipes.',
          'price': 380.0,
          'category': 'Mutton',
          'images': [
            'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
          ],
          'unit': 'kg',
          'minQuantity': 0.25,
          'maxQuantity': 1.0,
          'isAvailable': true,
          'isFeatured': false,
          'rating': 4.2,
          'reviewCount': 34,
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

      // Add products to Supabase
      await _supabase.from('products').insert(sampleProducts);
      print('Sample data initialized successfully');
      
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  // Get product by ID
  static Future<ProductModel?> getProduct(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .single();
      
      return ProductModel.fromMap(response);
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Search products
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('isAvailable', true)
          .or('name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%');

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Upload image to Supabase Storage
  static Future<String?> uploadImage(Uint8List fileBytes, String fileName) async {
    try {
      await _supabase.storage
          .from('product-images')
          .uploadBinary(fileName, fileBytes);

      final publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get all categories
  static Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('products')
          .select('category')
          .eq('isAvailable', true);

      final categories = (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();
      
      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Get featured products
  static Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('isAvailable', true)
          .eq('isFeatured', true)
          .order('rating', ascending: false)
          .limit(10);

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error getting featured products: $e');
      return [];
    }
  }

  // Get products by category
  static Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('isAvailable', true)
          .eq('category', category)
          .order('name', ascending: true);

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }
}

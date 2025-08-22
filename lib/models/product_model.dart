import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final List<String> images;
  final String unit; // kg, grams, pieces
  final double minQuantity;
  final double maxQuantity;
  final bool isAvailable;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? nutritionInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.images,
    required this.unit,
    this.minQuantity = 0.5,
    this.maxQuantity = 10.0,
    this.isAvailable = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.nutritionInfo,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      unit: map['unit'] ?? 'kg',
      minQuantity: (map['minQuantity'] ?? 0.5).toDouble(),
      maxQuantity: (map['maxQuantity'] ?? 10.0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      nutritionInfo: map['nutritionInfo'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'images': images,
      'unit': unit,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'rating': rating,
      'reviewCount': reviewCount,
      'nutritionInfo': nutritionInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }
}
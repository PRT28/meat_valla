class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double quantity;
  final String unit;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'kg',
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? quantity,
    String? unit,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class CartDetails {
  CartDetails({
    required this.qty,
    required this.name,
    required this.price
  });

  CartDetails.fromJson(Map<String, Object?> json)
      : this(
      qty: json['qty']! as int,
      name: json['name']! as String,
      price: json['price']! as int
  );

  final int qty;
  final String name;
  final int price;

  CollectionReference cartInstance = FirebaseFirestore.instance.collection("cart");



  Map<String, Object?> toJson() {
    return {
      'qty': qty,
      'name': name,
      'price': price
    };
  }
}

class CartModel {
  CartModel({
    required this.details,
    required this.cartTotal
  });

  CartModel.fromJson(Map<String, Object?> json)
      : this(
      details: json['details']! as List<CartDetails>,
      cartTotal: json['cartTotal']! as int
  );

  final List<CartDetails> details;
  final int cartTotal;

  CollectionReference cartInstance = FirebaseFirestore.instance.collection("cart");



  Map<String, Object?> toJson() {
    return {
      'details': details.map((e) => e.toJson()).toList(),
      'cartTotal': cartTotal,
    };
  }

  Future<bool> setObject(phoneNum) {
    return cartInstance.doc(phoneNum).set(toJson()).then((value) =>  true)
        .catchError((error) => false);
  }
}
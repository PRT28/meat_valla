import 'package:cloud_firestore/cloud_firestore.dart';

class CartDetails {
  CartDetails({
    required this.qty,
    required this.name,
    required this.price,
    required this.img
  });

  CartDetails.fromJson(Map<String, Object?> json)
      : this(
      qty: json['qty']! as int,
      name: json['name']! as String,
      price: json['price']! as double,
      img: json['img']! as String
  );

  final int qty;
  final String name;
  final double price;
  final String img;

  CollectionReference cartInstance = FirebaseFirestore.instance.collection("cart");



  Map<String, Object?> toJson() {
    return {
      'qty': qty,
      'name': name,
      'price': price,
      'img': img
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
      cartTotal: json['cartTotal']! as double
  );

  final List<CartDetails> details;
  final double cartTotal;

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
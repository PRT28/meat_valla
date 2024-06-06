import 'dart:ffi';

class CartModel {
  CartModel({
    required this.qty,
    required this.invId,
    required this.totalPrice
  });

  CartModel.fromJson(Map<String, Object?> json)
      : this(
      qty: json['qty']! as Int,
      invId: json['invId']! as String,
      totalPrice: json['totalPrice']! as Float
  );

  final Int qty;
  final String invId;
  final Float totalPrice;



  Map<String, Object?> toJson() {
    return {
      'qty': qty,
      'invId': invId,
      'totalPrice': totalPrice
    };
  }
}
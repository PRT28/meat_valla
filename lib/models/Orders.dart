import 'package:cloud_firestore/cloud_firestore.dart';

enum Status {
  confirmed,
  pickedUp,
  delivered,
  cancelled
}

class Orders {
  final String status;
  final List<dynamic> orderDetails;
  final String address;
  final String user;
  final double total;

  Orders({
    required this.status,
    required this.orderDetails,
    required this.address,
    required this.user,
    required this.total
  });

  Orders.fromJson(Map<String, Object?> json)
      : this(
      status: json['status']! as String,
      orderDetails: json['orderDetails']! as List<dynamic>,
      address: json['address']! as String,
      user: json['user']! as String,
    total: json['total']! as double
  );

  CollectionReference userInstance = FirebaseFirestore.instance.collection("orders");

  Map<String, Object?> toJson() {
    return {
      'status': status,
      'orderDetails': orderDetails,
      'address': address,
      'user': user,
      'total': total
    };
  }

  Future<bool> setObject() {
    return userInstance.add(toJson()).then((value) =>  true)
        .catchError((error) => false);
  }

}
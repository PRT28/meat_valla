import 'package:meat_delivery/models/CartModel.dart';
import 'package:meat_delivery/models/Inventory.dart';

class User {
  User({
    required this.name,
    required this.dob,
    required this.gender,
    required this.cart,
    required this.address,
    required this.favourites
  });

  User.fromJson(Map<String, Object?> json)
      : this(
    name: json['name']! as String,
    dob: json['dob']! as DateTime,
    gender: json['gender']! as String,
    cart: json['cart']! as List<CartModel>,
    address: json['address']! as List<String>,
      favourites: json['favourites']! as List<Inventory>
  );

  final String name;
  final DateTime dob;
  final String gender;
  final List<CartModel> cart;
  final List<String> address;
  final List<Inventory> favourites;


  Map<String, Object?> toJson() {
    return {
      'name': name,
      'dob': dob,
      'gender': gender,
      'cart': cart,
      'address': address,
      'favourites':favourites
    };
  }
}
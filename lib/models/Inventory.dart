import 'dart:ffi';

class Inventory {

  Inventory({
    required this.name,
    required this.desc,
    required this.price
  });

  Inventory.fromJson(Map<String, Object?> json)
      : this(
      name: json['name']! as String,
      desc: json['desc']! as String,
      price: json['price']! as Float
  );

  final String name;
  final String desc;
  final Float price;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'desc': desc,
      'price': price
    };
  }

}

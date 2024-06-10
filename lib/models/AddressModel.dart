import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  CartModel({
    required this.list,
    required this.selected
  });

  CartModel.fromJson(Map<String, Object?> json)
      : this(
      list: json['list']! as List<String>,
      selected: json['selected']! as Int
  );

  final List<String> list;
  final Int selected;

  CollectionReference addressInstance = FirebaseFirestore.instance.collection("address");



  Map<String, Object?> toJson() {
    return {
      'list': list,
      'selected': selected,
    };
  }

  Future<bool> setObject(phoneNum) {
    return addressInstance.doc(phoneNum).set(toJson()).then((value) =>  true)
        .catchError((error) => false);
  }
}
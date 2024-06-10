import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  Users({
    required this.name,
    required this.dob,
    required this.gender,
  });

  Users.fromJson(Map<String, Object?> json)
      : this(
    name: json['name']! as String,
    dob: json['dob']! as DateTime,
    gender: json['gender']! as String,
  );

  CollectionReference userInstance = FirebaseFirestore.instance.collection("users");

  final String name;
  final DateTime dob;
  final String gender;


  Map<String, Object?> toJson() {
    return {
      'name': name,
      'dob': dob,
      'gender': gender,
    };
  }

  Future<bool> setObject(phoneNum) {
    return userInstance.doc(phoneNum).set(toJson(), SetOptions(merge: true)).then((value) =>  true)
        .catchError((error) => false);
  }
}
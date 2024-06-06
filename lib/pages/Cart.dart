import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/pages/AddressList.dart';
import 'package:meat_delivery/pages/OrderSuccess.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // A factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

String jsonString = '''
  [
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
  ]
  ''';

List<dynamic> jsonList = json.decode(jsonString);

class _CartState extends State<Cart> {
  List<User> users = jsonList.map((json) => User.fromJson(json)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: const Text("Cart", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
            onClick: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
            },
            label: "Place Order"
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 2.0,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Order Details",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    // Add a SizedBox with a fixed height or use an Expanded widget
                    SizedBox(
                      height: 300, // Fixed height for the ListView
                      child: ListView.builder(
                        itemCount: users.length,
                        prototypeItem: const ListTile(
                          title: Text("Prototype Item"),
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(users[index].name),
                            subtitle: Text(users[index].email),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              const Text("Address:", style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600
              )),

               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox(
                    width: 220,
                    child: Text("C/o: Prithvi Plywood & Glass, Near T.P. Nagar, Manpur North Rampur Road, Haldwani", style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                    )),
                  ),
                  TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressList(isOrder: true)));
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Change",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12
                        ),
                      )
                  ),
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Total Cost:", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  )),
                  Text("\$450", style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                  ))
                ],
              ),

              const SizedBox(
                height: 30,
              ),

            ],
          ),
        ),
      ),
    );
  }
}


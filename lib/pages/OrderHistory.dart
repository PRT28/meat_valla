import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meat_delivery/components/ReorderCard.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

  Future<List<DocumentSnapshot>> fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('user', isEqualTo: phone!.substring(3))
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no data is found
            return const Center(child: Text('No Data Found'));
          } else {
            List<DocumentSnapshot> orders = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: orders.map((e) {
                    var data = e.data() as Map<String, dynamic>;
                    return ReorderCard(order: data);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/pages/OrderSuccess.dart';

class ReorderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const ReorderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    placeOrder() async {
      await FirebaseFirestore.instance.collection('orders').add(order).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccess()),
        );
      });
    }

    List<dynamic> orderDetails = order['orderDetails'];

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...orderDetails.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e['name']}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qty: ${e['qty']}', textAlign: TextAlign.left),
                        Text('₹${e['price']}', textAlign: TextAlign.left),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Address: ${order['address']}'),
                const SizedBox(height: 10),
                Text('Price: ₹${order['total']}'),
                IconButton(
                  onPressed: placeOrder,
                  icon: const Icon(Icons.replay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

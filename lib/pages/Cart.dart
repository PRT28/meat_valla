import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/models/Orders.dart';
import 'package:meat_delivery/pages/AddressList.dart';
import 'package:meat_delivery/pages/OrderSuccess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String? email = FirebaseAuth.instance.currentUser?.email;

  Future<Map<String, DocumentSnapshot<Map<String, dynamic>>>> fetchData() async {
    var cart = FirebaseFirestore.instance.collection('cart').doc(email).get();
    var address = FirebaseFirestore.instance.collection('address').doc(email).get();
    var results = await Future.wait([cart, address]);
    return {
      'cart': results[0],
      'address': results[1],
    };
  }

  Future<void> placeOrder(DocumentSnapshot cart, DocumentSnapshot address) async {
    if (!(cart.exists && address.exists)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressList(isOrder: true)));
    } else {
      Orders order = Orders(
        status: Status.confirmed.toString(),
        orderDetails: cart['details'] ?? [],
        address: address['list'][address['selected']],
        user: email.toString(),
        total: cart['cartTotal'],
      );
      await order.setObject();
      await FirebaseFirestore.instance.collection('cart').doc(email.toString()).delete();
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: const Text("Cart", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<Map<String, DocumentSnapshot<Map<String, dynamic>>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No Data Found'));
          } else {
            var cart = snapshot.data!['cart']!;
            var address = snapshot.data!['address']!;
            var cartDetailsList = cart.exists ? cart['details'] as List<dynamic> : [];

            if (cartDetailsList.isEmpty) {
              return const Center(
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                        maxWidth: MediaQuery.of(context).size.width,
                        minHeight: 250,
                      ),
                      child: DecoratedBox(
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const Text(
                                "Order Details",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: cartDetailsList.map((e) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${e['name']}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('Qty: ${e['qty']}'),
                                            Text('₹${e['price']}'),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("Address:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 220,
                          child: Text(
                            address.exists ? address['list'][address['selected']] : 'No Address Found',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressList(isOrder: true)));
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text(
                            "Change",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text("Total Cost:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text("₹${cart.exists ? cart['cartTotal'] : '0'}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, DocumentSnapshot<Map<String, dynamic>>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          bool isCartEmpty = true;
          DocumentSnapshot? cartDoc;
          DocumentSnapshot? addressDoc;

          if (snapshot.hasData && snapshot.data != null) {
            cartDoc = snapshot.data!['cart'];
            addressDoc = snapshot.data!['address'];
            var cartDetails = cartDoc?.exists == true ? cartDoc!['details'] as List<dynamic> : [];
            isCartEmpty = cartDetails.isEmpty;
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Button(
              label: "Place Order",
              onClick: () => placeOrder(cartDoc!, addressDoc!),
              disable: isCartEmpty,
            ),
          );
        },
      ),
    );
  }
}

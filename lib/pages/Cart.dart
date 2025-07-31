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

  Future<void> removeFromCart(int index) async {
    if (email == null) return;

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(email);
    final cartSnapshot = await cartRef.get();

    if (!cartSnapshot.exists || cartSnapshot.data() == null) return;

    var data = cartSnapshot.data()!;
    List<dynamic> details = List.from(data['details'] ?? []);
    double cartTotal = (data['cartTotal'] ?? 0).toDouble();

    if (index >= details.length) return;

    var removedItem = details.removeAt(index);
    double removedItemTotal =
        ((removedItem['price'] ?? 0) as num).toDouble() *
            ((removedItem['qty'] ?? 1) as num).toDouble();
    cartTotal -= removedItemTotal;

    await cartRef.set({
      'details': details,
      'cartTotal': cartTotal < 0 ? 0 : cartTotal,
    });

    setState(() {}); // Refresh UI
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [],
        title: const Text("Shopping Cart", style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
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

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemCount: cartDetailsList.length,
                      itemBuilder: (context, index) {
                        var item = cartDetailsList[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF6E1F1F), width: 1), // Customize color & width
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item['img'] ?? '',
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Quantity:', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text(item['qty'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: const Color(0xFF6E1F1F)),
                                            onPressed: () => removeFromCart(index),
                                            padding: EdgeInsets.zero,
                                            splashRadius: 20, // optional: controls ripple size
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("₹${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text("₹${cart.exists ? cart['cartTotal'] : '0'}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
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
              label: "Checkout",
              onClick: () => placeOrder(cartDoc!, addressDoc!),
              disable: isCartEmpty,
            ),
          );
        },
      ),
    );
  }
}

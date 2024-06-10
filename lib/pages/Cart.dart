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

  @override
  Widget build(BuildContext context) {

    String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

    fetchData() async {
      var cart = FirebaseFirestore.instance.collection('cart').doc(phone?.substring(3)).get();
      var address = FirebaseFirestore.instance.collection('address').doc(phone?.substring(3)).get();
      var results = await Future.wait([cart, address]);
      return {
        'cart': results[0],
        'address': results[1],
      };
    }
   placeOrder() async {
       var cart = FirebaseFirestore.instance.collection('cart').doc(phone?.substring(3)).get();
       var address = FirebaseFirestore.instance.collection('address').doc(phone?.substring(3)).get();
       var results = await Future.wait([cart, address]);
      if (results[1]['list'].isEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressList(isOrder: true)));
      } else {
        Orders order = Orders(
            status: Status.confirmed.toString(),
            orderDetails: results[0]['details'],
            address: results[1]['list'][results[1]['selected']],
            user: phone!.substring(3).toString(),
            total: results[0]['cartTotal']
        );
        order.setObject().then((value) async {
          await FirebaseFirestore.instance.collection('cart').doc(phone.substring(3)).delete().then((e) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
          });

        });
      }
   }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: const Text("Cart", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
            onClick: placeOrder,
            label: "Place Order"
        ),
      ),
      body: FutureBuilder<Map<String, DocumentSnapshot<Map<String, dynamic>>>>(
        future: fetchData(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
        // Show a message if no data is found
          return const Center(child: Text('No Data Found'));
        } else {
            // Build the UI with the data
          var cart = snapshot.data!['cart']!;
          var address = snapshot.data!['address']!;
          var cartDetailsList = cart['details'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                        maxWidth: MediaQuery.of(context).size.width,
                        minHeight: 250
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
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${e['name']}', textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      Column(
                                        children: [
                                          Text('Qty: ${e['qty']}', textAlign: TextAlign.left,),
                                          Text('₹${e['price']}', textAlign: TextAlign.left,)
                                        ],
                                      )


                                    ],
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        )
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
                        SizedBox(
                          width: 220,
                          child: Text(address['list'][address['selected']], style: const TextStyle(
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

                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text("Total Cost:", style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                        )),
                        Text("₹${cart['cartTotal']}", style: const TextStyle(
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
            );
          }
        },
      ),
    );
  }
}


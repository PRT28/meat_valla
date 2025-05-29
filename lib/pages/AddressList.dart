import "package:flutter/material.dart";
import "package:meat_delivery/components/Button.dart";
import "package:meat_delivery/pages/Address.dart";
import "package:meat_delivery/pages/OrderSuccess.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meat_delivery/models/Orders.dart';

class AddressTextButton extends StatelessWidget {
  
  final String title;
  final int id;
  final bool selected;
  final void Function(int) setSelected;
  
  const AddressTextButton({
    super.key,
    required this.title,
    required this.id,
    required this.selected,
    required this.setSelected
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setSelected(id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(10),
            border: BorderDirectional(
                top: BorderSide(
                  width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                ),
                bottom: BorderSide(
                    width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                ),
                start: BorderSide(
                    width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                ),
                end: BorderSide(
                    width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                )
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            IconButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Address(title: title)));},
                icon: const Icon(Icons.edit, size: 18,))
          ],
        ),
      ),
    );
  }
}


class AddressList extends StatefulWidget {
  final bool isOrder;


  const AddressList({super.key, required this.isOrder});


  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {


  String? email = FirebaseAuth.instance.currentUser?.email;

  int _selected = 0;

  setSelected(id) async {
    var address = await FirebaseFirestore.instance.collection('address').doc(email).get();
    var data = address.data();
    data?['selected'] = id;
    FirebaseFirestore.instance.collection('address').doc(email).set(data!, SetOptions(merge: true)).then((value) {
      setState(() {
        _selected = id;
      });
    });

  }

  @override
  Widget build(BuildContext context) {


    Future<DocumentSnapshot<Map<String, dynamic>>> fetchData() async {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
                                              .instance
                                              .collection('address')
                                              .doc(email)
                                              .get();
      return querySnapshot;
    }

    placeOrder() async {
      var cart = FirebaseFirestore.instance.collection('cart').doc(email).get();
      var address = FirebaseFirestore.instance.collection('address').doc(email).get();
      var results = await Future.wait([cart, address]);
      if (widget.isOrder) {
        Orders order = Orders(
            status: Status.confirmed.toString(),
            orderDetails: results[0]['details'],
            address: results[1]['list'][results[1]['selected']],
            user: email.toString(),
            total: results[0]['cartTotal']
        );
        order.setObject().then((value) async {
          await FirebaseFirestore.instance.collection('cart').doc(email).delete().then((e) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
          });
        });
      } else {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button (
            onClick:placeOrder,
            label: widget.isOrder ? "Place Order" : "Okay"
        ),
      ),
      body:FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {

        DocumentSnapshot<Map<String, dynamic>> address = snapshot.data!;

        // setState(() {
        //   _selected = address['selected'];
        // });

        List<dynamic> addressList = address.exists ? address['list'] : [];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Hero(
                      tag: "address-icon",
                      child:  Icon(
                        Icons.home_filled,
                        size: 80,
                        color: Color(0xFF850E35),
                      )
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Address",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600
                    ),),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children:  addressList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var e = entry.value;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: AddressTextButton(
                          title: e,
                          id: index,
                          selected: index == _selected,
                          setSelected: setSelected,
                        ),
                      );
                    }).toList()
                  ),

                  const SizedBox(
                    height: 20,
                  ),



                  TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Address(title: null)));
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add new address",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15
                        ),
                      )
                  )
                ],
              ),
            ),
          ),
        );
      }
      }
      )
    );
  }
}


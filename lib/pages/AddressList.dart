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
  final void Function(int) onDelete; // New callback for delete
  final void Function() onEdit;

  const AddressTextButton({
    super.key,
    required this.title,
    required this.id,
    required this.selected,
    required this.setSelected,
    required this.onDelete, // Add to constructor
    required this.onEdit,
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
              color: selected ? const Color(0xFF850E35) : Colors.black,
            ),
            bottom: BorderSide(
              width: 2,
              color: selected ? const Color(0xFF850E35) : Colors.black,
            ),
            start: BorderSide(
              width: 2,
              color: selected ? const Color(0xFF850E35) : Colors.black,
            ),
            end: BorderSide(
              width: 2,
              color: selected ? const Color(0xFF850E35) : Colors.black,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Text(title)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Address(title: title)),
                    ).then((_) {
                      onEdit();
                      // Use context.findAncestorStateOfType if needed to call setState from parent
                    });
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
                IconButton(
                  onPressed: () => onDelete(id), // 🔥 Call the delete callback
                  icon: const Icon(Icons.delete, size: 18),
                ),
              ],
            ),
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
  late Future<DocumentSnapshot<Map<String, dynamic>>> _futureAddress;

  @override
  void initState() {
    super.initState();
    _futureAddress = fetchData();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchData() async {
    return await FirebaseFirestore.instance.collection('address').doc(email).get();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureAddress = fetchData();
    });
  }

  Future<void> setSelected(int id) async {
    var address = await FirebaseFirestore.instance.collection('address').doc(email).get();
    var data = address.data();
    data?['selected'] = id;
    await FirebaseFirestore.instance
        .collection('address')
        .doc(email)
        .set(data!, SetOptions(merge: true));

    setState(() {
      _selected = id;
    });
  }

  Future<void> deleteAddress(int id) async {
    final docRef = FirebaseFirestore.instance.collection('address').doc(email);
    final doc = await docRef.get();

    if (doc.exists) {
      List<dynamic> list = List.from(doc['list']);
      int selectedIndex = doc['selected'] ?? 0;

      list.removeAt(id);

      // Adjust selected index if necessary
      if (selectedIndex == id) {
        selectedIndex = 0;
      } else if (selectedIndex > id) {
        selectedIndex--;
      }

      await docRef.set({
        'list': list,
        'selected': selectedIndex,
      }, SetOptions(merge: true));

      // Trigger UI refresh
      setState(() {
        _selected = selectedIndex;
        _futureAddress = fetchData();
      });
    }
  }

  void placeOrder() async {
    var cart = FirebaseFirestore.instance.collection('cart').doc(email).get();
    var address = FirebaseFirestore.instance.collection('address').doc(email).get();
    var results = await Future.wait([cart, address]);

    if (widget.isOrder) {
      Orders order = Orders(
        status: Status.confirmed.toString(),
        orderDetails: results[0]['details'],
        address: results[1]['list'][results[1]['selected']],
        user: email.toString(),
        total: results[0]['cartTotal'],
      );

      await order.setObject();
      await FirebaseFirestore.instance.collection('cart').doc(email).delete();
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
    } else {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
          onClick: placeOrder,
          label: widget.isOrder ? "Place Order" : "Okay",
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _futureAddress,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            DocumentSnapshot<Map<String, dynamic>> address = snapshot.data!;
            List<dynamic> addressList = address.exists ? address['list'] ?? [] : [];

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12.0),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Hero(
                        tag: "address-icon",
                        child: Icon(
                          Icons.home_filled,
                          size: 80,
                          color: Color(0xFF850E35),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Address",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...addressList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var e = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AddressTextButton(
                            title: e,
                            id: index,
                            selected: index == _selected,
                            setSelected: setSelected,
                            onDelete: deleteAddress,
                            onEdit: () {
                              setState(() {
                                _futureAddress = fetchData();
                              });
                            }
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Address(title: null)),
                          ).then((_) {
                            setState(() {
                              _futureAddress = fetchData();
                            });
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          "Add new address",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}



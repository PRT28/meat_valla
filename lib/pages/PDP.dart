import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/models/CartModel.dart';
import 'package:meat_delivery/pages/Cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PDP extends StatefulWidget {

  final Map<String, dynamic> data;

  const PDP({super.key, required this.data});

  @override
  State<PDP> createState() => _PDPState();
}

class _PDPState extends State<PDP> {
  int _countItem = 0;
  bool isAdded = false;
  String s = '';

  @override
  void initState() {
    super.initState();
    s = widget.data['name'];
    s.replaceAll(' ', '-');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const BackButton(),
                  Expanded(
                    child: Text('${widget.data['name']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                  )
                ],
              ),
              Hero(
                tag: 'plp-title-$s',
                  child: Image(
                      image: NetworkImage(widget.data['img'])
                  )
              ),

              Text("Price: ₹${widget.data['price']}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600
              ),),

               Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: IconButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.white24;
                                  }
                                  return const Color(0xFF850E35);
                                })
                            ),
                            onPressed: _countItem > 0 && !isAdded ? () {
                              setState(() {
                                _countItem = _countItem - 1;
                              });
                            } :
                            null,
                            icon: Icon(Icons.remove, color: _countItem > 0 ? Colors.white : Colors.grey,)
                        ),
                      ),
                      Text("Qty: ${_countItem}"),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: IconButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.white24;
                                }
                                return Color(0xFF850E35);
                              }),
                            ),
                            onPressed: !isAdded ? () {
                              setState(() {
                                _countItem = _countItem + 1;
                              });
                            } : null,
                            icon: const Icon(Icons.add, color: Colors.white)
                        ),
                      ),
                    ],
                  ),
               ),

              Text(widget.data['desc']),

              const SizedBox(
                height: 30,
              ),

              !isAdded ? Button(
                  onClick: () async {
                    String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;
                    if (phone == null) {
                      print('User not logged in');
                      return;
                    }

                    DocumentSnapshot<Map<String, dynamic>> cart = await FirebaseFirestore.instance.collection('cart').doc(phone).get();

                    if (!cart.exists || cart.data() == null || cart.data()!.isEmpty) {
                      CartDetails cartDetails = CartDetails(
                        qty: _countItem,
                        name: widget.data['name'],
                        price: widget.data['price'],
                      );
                      CartModel cartModel = CartModel(
                        details: [cartDetails],
                        cartTotal: (widget.data['price'] * _countItem),
                      );
                      cartModel.setObject(phone.substring(3)).then((value) {
                        setState(() {
                          isAdded = true;
                        });
                      });
                    } else {
                      var data = cart.data()!;
                      var cartDetailsList = data['details'] as List<dynamic>? ?? [];

                      // Create a new CartDetails object
                      CartDetails newVal = CartDetails(
                        qty: _countItem,
                        name: widget.data['name'],
                        price: widget.data['price'],
                      );

                      // Add the new CartDetails object to the list
                      cartDetailsList.add(newVal.toJson());

                      // Update the cart data
                      data['details'] = cartDetailsList;
                      data['cartTotal'] = (data['cartTotal'] ?? 0) + (widget.data['price'] * _countItem);

                      // Update Firestore with the new cart data
                      await FirebaseFirestore.instance.collection('cart').doc(phone.substring(3)).set(data).then((value) {
                        setState(() {
                          isAdded = true;
                        });
                      });
                    }
                  },
                  disable: _countItem == 0,
                  label: "Add to cart"
              ) : const SizedBox.shrink(),

              isAdded ? Button(
                  onClick: () async {
                    String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;
                    if (phone == null) {
                      print('User not logged in');
                      return;
                    }
                    DocumentSnapshot<Map<String, dynamic>> cart = await FirebaseFirestore.instance.collection('cart').doc(phone.substring(3)).get();

                    if (!cart.exists || cart.data() == null || cart.data()!.isEmpty) {
                      // Logic to display somthing went wrong
                      print('aaaa');
                    } else {
                      
                      var data = cart.data()!;
                      var cartDetailsList = data['details'] as List<dynamic>? ?? [];

                      cartDetailsList.removeWhere((item) => item['name'] == widget.data['name']);

                      // Update the cart data
                      data['details'] = cartDetailsList;
                      data['cartTotal'] = (data['cartTotal'] ?? 0) - (widget.data['price'] * _countItem);

                      // Update Firestore with the new cart data
                      await FirebaseFirestore.instance.collection('cart').doc(phone.substring(3)).set(data).then((value) {
                        setState(() {
                          isAdded = false;
                        });
                      });
                    }

                  },
                  label: "Remove from cart",
              ) : const SizedBox.shrink(),

              const SizedBox(
                height: 10,
              ),

              isAdded ? Button(
                  onClick: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
                  },
                  label: "View Cart"
              ) : const SizedBox.shrink(),

            ],
          ),
        ),
      ),
    );
  }
}

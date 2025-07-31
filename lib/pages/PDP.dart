import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/models/CartModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PDP extends StatefulWidget {
  final Map<String, dynamic> data;

  const PDP({super.key, required this.data});

  @override
  State<PDP> createState() => _PDPState();
}

class _PDPState extends State<PDP> {
  int _countItem = 1;
  bool isInCart = false;

  @override
  void initState() {
    super.initState();
    _checkIfItemInCart();
  }

  Future<void> _checkIfItemInCart() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final cartSnapshot = await FirebaseFirestore.instance.collection('cart').doc(email).get();

    if (cartSnapshot.exists && cartSnapshot.data() != null) {
      final cartData = cartSnapshot.data()!;
      final details = cartData['details'] as List<dynamic>? ?? [];

      for (var item in details) {
        if (item['name'] == widget.data['name']) {
          setState(() {
            isInCart = true;
            _countItem = item['qty'] ?? 1;
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Hero(
              tag: 'plp-title-${widget.data['name']}',
              child: Image.network(
                widget.data['img'],
                width: double.infinity,
                height: height * 0.45,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: height * 0.4,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6E1F1F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 12),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Go Back',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        widget.data['name'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${widget.data['price']}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Quantity selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _quantityButton(Icons.remove, () {
                            if (_countItem > 1) {
                              setState(() => _countItem--);
                            }
                          }),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$_countItem', style: const TextStyle(fontSize: 18)),
                          ),
                          _quantityButton(Icons.add, () {
                            setState(() => _countItem++);
                          }),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Container(
                        height: isInCart ? height * 0.18 : height * 0.25,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nutrition Information",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _NutritionItem(label: 'Calories', value: '165 kcal'),
                                  _NutritionItem(label: 'Protein', value: '21g'),
                                  _NutritionItem(label: 'Fat', value: '8g'),
                                  _NutritionItem(label: 'Carbs', value: '-'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Description",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(widget.data['desc'], style: const TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      Button(
                        onClick: () => isInCart ? _updateCart() : _addToCart(),
                        label: isInCart ? "Update Quantity" : "Add to Cart",
                        disable: _countItem == 0,
                        bgColor: 0xFFFFFFFF,
                        fontColor: 0xFF6E1F1F,
                      ),
                      if (isInCart)
                        TextButton(
                          onPressed: _removeFromCart,
                          child: const Text("Remove from Cart", style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: const Color(0xFFEEEAE4),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(email);
    final cartSnapshot = await cartRef.get();

    final newItem = CartDetails(
      qty: _countItem,
      name: widget.data['name'],
      price: widget.data['price'],
      img: widget.data['img']
    );

    if (!cartSnapshot.exists || cartSnapshot.data() == null) {
      final newCart = CartModel(
        details: [newItem],
        cartTotal: widget.data['price'] * _countItem,
      );
      await newCart.setObject(email);
    } else {
      var cartData = cartSnapshot.data()!;
      var details = List<Map<String, dynamic>>.from(cartData['details'] ?? []);
      details.add(newItem.toJson());

      cartData['details'] = details;
      cartData['cartTotal'] = (cartData['cartTotal'] ?? 0) + (widget.data['price'] * _countItem);

      await cartRef.set(cartData);
    }

    setState(() => isInCart = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added to cart')));
  }

  Future<void> _updateCart() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(email);
    final cartSnapshot = await cartRef.get();
    if (!cartSnapshot.exists) return;

    var cartData = cartSnapshot.data()!;
    var details = List<Map<String, dynamic>>.from(cartData['details'] ?? []);

    double total = 0;
    for (int i = 0; i < details.length; i++) {
      if (details[i]['name'] == widget.data['name']) {
        details[i]['qty'] = _countItem;
      }
      total += (details[i]['qty'] * details[i]['price']);
    }

    cartData['details'] = details;
    cartData['cartTotal'] = total;

    await cartRef.set(cartData);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantity updated')));
  }

  Future<void> _removeFromCart() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(email);
    final cartSnapshot = await cartRef.get();
    if (!cartSnapshot.exists) return;

    var cartData = cartSnapshot.data()!;
    var details = List<Map<String, dynamic>>.from(cartData['details'] ?? []);

    details.removeWhere((item) => item['name'] == widget.data['name']);

    double newTotal = 0;
    for (var item in details) {
      newTotal += (item['qty'] * item['price']);
    }

    cartData['details'] = details;
    cartData['cartTotal'] = newTotal;

    await cartRef.set(cartData);
    setState(() => isInCart = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

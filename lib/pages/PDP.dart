import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/pages/Cart.dart';

class PDP extends StatefulWidget {

  final int id;

  const PDP({super.key, required this.id});

  @override
  State<PDP> createState() => _PDPState();
}

class _PDPState extends State<PDP> {
  int _countItem = 0;
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
          title: const Text(
            "Chicken",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
            ),
          )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'plp-title-${widget.id}',
                  child: const Image(
                      image: NetworkImage("https://st3.depositphotos.com/2125603/34616/i/450/depositphotos_346166616-stock-photo-raw-chicken-body-isolated-white.jpg")
                  )
              ),

              const Text("Price: 455\$",
                textAlign: TextAlign.center,
                style: TextStyle(
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
                            onPressed: _countItem > 0 ? () {
                              setState(() {
                                _countItem = _countItem - 1;
                              });
                            } :
                            null,
                            icon: Icon(Icons.remove, color: _countItem > 0 ? Colors.white : Colors.grey,)
                        ),
                      ),
                      Text("${_countItem}"),
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
                            onPressed: () {
                              setState(() {
                                _countItem = _countItem + 1;
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.white)
                        ),
                      ),
                    ],
                  ),
               ),

              const Text('''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas cursus sapien vitae justo tempus euismod. Suspendisse Praesent ante lectus, placerat eu eros efficitur, condimentum ullamcorper purus. Phasellus eleifend lectus nec consequat commodo. Nullam accumsan fermentum blandit. Cras vel enim ut est bibendum euismod.'''),

              const SizedBox(
                height: 30,
              ),

              !isAdded ? Button(
                  onClick: () {
                    setState(() {
                      isAdded = true;
                    });
                  },
                  disable: _countItem == 0,
                  label: "Add to cart"
              ) : const SizedBox.shrink(),

              isAdded ? Button(
                  onClick: () {
                    setState(() {
                      isAdded = false;
                    });
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

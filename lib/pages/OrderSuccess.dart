import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:meat_delivery/components/Button.dart";
import "package:meat_delivery/pages/Base.dart";

class OrderSuccess extends StatefulWidget {
  const OrderSuccess({super.key});

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  double _iconSize = 10.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    _startAnimation();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _iconSize = 148.0;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
            onClick: () {
              Navigator.pop(context,true);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Base()));
            },
            label: "Continue Shopping"
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  const SizedBox(
                    height: 60,
                  ),
                  FadeTransition(
                      opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child:AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        width: 200,
                        height: 148,
                        child: Icon(Icons.check_circle,
                          color: Colors.green,
                          size: _iconSize,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text("Order Placed Successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),

                  ),
                  const SizedBox(
                    height: 50,
                  ),

                  const Text("Items are under packaging.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),

                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}

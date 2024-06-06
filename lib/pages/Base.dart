import "package:flutter/material.dart";
import "package:meat_delivery/components/BottomNavBar.dart";
import "package:meat_delivery/pages/Cart.dart";
import "package:meat_delivery/pages/Categories.dart";
import "package:meat_delivery/pages/Home.dart";

class Base extends StatefulWidget {
  const Base({super.key});

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {

  int _selectedIndex = 1;

  void _onItemTapped (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFDFA),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body:
      Builder(
          builder: (context) {
            if (_selectedIndex == 1) {
              return const HomePage();
            } else if (_selectedIndex == 0) {
              return const Categories();
            } else if (_selectedIndex == 2) {
              return const Cart();
            } else {
              return Container();
            }
          }
      )
    );
  }
}



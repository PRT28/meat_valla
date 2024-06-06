import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomNavBar extends StatefulWidget {

  final ValueChanged<int> onItemTapped;
  final int selectedIndex;

  const BottomNavBar({super.key,
    required this.onItemTapped,
    required this.selectedIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override

  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories', backgroundColor: Colors.green),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', backgroundColor: Colors.amber),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart', backgroundColor: Colors.red),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: const Color(0xFF850E35),
        showUnselectedLabels: true,
        currentIndex: widget.selectedIndex,
        backgroundColor: const Color(0xFFFFF7F4),
        onTap: widget.onItemTapped,
      ),
    );
  }
}
//F1313f
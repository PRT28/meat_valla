import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final VoidCallback onClick;
  final String label;
  final bool disable;

  const Button({
    super.key,
    required this.onClick,
    required this.label,
    this.disable = false
  });



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disable ? () {} : onClick,
      child: Container(
        height: 40,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(disable ? 0xFFD3AFBB : 0xFF850E35)
        ),
        child: Center(
          child: Text(label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600
          ),),
        ),
      ),
    );
  }
}

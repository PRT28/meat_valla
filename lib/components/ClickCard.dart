import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meat_delivery/pages/PDP.dart';
import 'package:meat_delivery/pages/PLP.dart';

class ClickCard extends StatelessWidget {

  final String text;
  final String imageLink;

  const ClickCard({
    super.key,
    required this.text,
    required this.imageLink
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Color(0xFF6E1F1F),
      borderRadius: BorderRadius.circular(10),
      onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PLP(title: text)))},
      child: Container(
        height: 550,
        width: 160,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: Color(0xFF6E1F1F),
            borderRadius: BorderRadius.circular(12),
          border: const BorderDirectional(
            top: BorderSide(
              color: Colors.black12
            ),
            bottom: BorderSide(
                color: Colors.black12
            ),
            start: BorderSide(
                color: Colors.black12
            ),
            end: BorderSide(
                color: Colors.black12
            )
          )
        ),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120, // Increased image height
                  width: double.infinity,
                  child: Image.network(
                    imageLink,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              height: 20,
              child: Center(
                child: Text(this.text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

          ],
        ),
      )
    );
  }
}


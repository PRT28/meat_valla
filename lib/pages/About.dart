import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
          title: const Text(
            "About", style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700
          ),)
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: SafeArea(
            child: Text('''Greetings from Meat Maestro, your dependable online meat delivery provider! We can help you with cooking for your family, yourself, or even managing a sizable hotel. Freshest and best-quality meat delivered straight to your home is our speciality at Meat Maestro.

Searching for a meat market in your area? Or maybe a nearby store that sells fish or chicken? You can stop looking now that you have Meat Maestro. A few clicks will give you access to a large selection of premium meats, including lamb, beef, and chicken, as well as unusual products like jhatka pork and chicken.

Since we recognise the value of cleanliness and quality, we obtain all of our items from approved vendors and treat them with the highest care. Meat Maestro provides everything you need, whether you're looking for jhatka meat in particular or just a meat store nearby.

Order from Meat Maestro today! Get a variety of freshly cut meat products delivered straight to your home. No frozen items, no leftovers, just freshly cut pieces for every order. If you're a home cook or a professional chef, we are your favourite meatwala.

Experience the ease and reliability of Meat Maestro—your partner in quality meat delivery.'''),
        ),
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meat_delivery/components/WideCard.dart';
import 'package:meat_delivery/pages/PDP.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PLP extends StatefulWidget {

  final String title;

  const PLP({super.key, required this.title});

  @override
  State<PLP> createState() => _PLPState();
}

class _PLPState extends State<PLP> {
  String? email = FirebaseAuth.instance.currentUser?.email;

  Future<Map<String, dynamic>> fetchData() async {
    var inventory = await FirebaseFirestore
        .instance
        .collection('inventory')
        .where('category', isEqualTo: widget.title.toString().toLowerCase())
        .get();

    var favourite = await FirebaseFirestore.instance
        .collection("favourites")
        .doc(email)
        .get();

    return {
      'inventory': inventory.docs, // inventory.docs gives a List<DocumentSnapshot>
      'favourite': favourite.data(), // favourite.data() gives a Map<String, dynamic> or null
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data Found'));
          } else {
            List<DocumentSnapshot> inventory = snapshot.data!['inventory'] as List<DocumentSnapshot>;
            Map<String, dynamic>? favourite = snapshot.data!['favourite'] as Map<String, dynamic>?;
            List<dynamic> favourites = favourite?['list'] ?? [];

            return inventory.isEmpty
                ? const Center(child: Text("No items under this category"))
                : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75, // controls height
                ),
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  var data = inventory[index].data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PDP(data: data)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF6E1F1F),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Hero(
                            tag: 'plp-title-${data['name']}',
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                data['img'],
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${data['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),

                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}


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
  String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

  Future<Map<String, dynamic>> fetchData() async {
    var inventory = await FirebaseFirestore
        .instance
        .collection('inventory')
        .where('category', isEqualTo: widget.title.toString().toLowerCase())
        .get();

    var favourite = await FirebaseFirestore.instance
        .collection("favourites")
        .doc(phone?.substring(3))
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
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
            ),
          )
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
              print(inventory);
              return inventory.isEmpty ? Center(
                child: Text("No items under this category"),
              ) :  SingleChildScrollView(
                padding: EdgeInsets.all(12.0),
                child: SafeArea(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: inventory.map((e) {
                          var data = e.data() as Map<String, dynamic>;
                          return WideCard(
                            id: data['name'],
                            title: data['name'],
                            imgUrl: data['img'],
                            showFav: favourites.contains(data),
                            reorder: false,
                            cardClick: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PDP(data: data)))},
                            showFavClick: (_isFav) {
                              if (favourites.contains(data)) {
                                favourites.remove(data);
                              } else {
                                favourites.add(data);
                              }
                              favourite?['list'] = favourites;
                              FirebaseFirestore.instance.collection('favourites').doc(phone?.substring(3)).set(favourite ?? {});
                            },
                          );
                        }).toList()
                    )
                ),
              );
            }
          },
        ),
    );
  }
}


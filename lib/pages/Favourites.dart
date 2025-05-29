import 'package:flutter/material.dart';
import 'package:meat_delivery/components/WideCard.dart';
import 'package:meat_delivery/models/Users.dart';
import 'package:meat_delivery/pages/PDP.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meat_delivery/models/Inventory.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _PLPState();
}

class _PLPState extends State<Favourites> {
  String? email = FirebaseAuth.instance.currentUser?.email;

  Future<bool> update(
      Map<String, dynamic> data, List<DocumentSnapshot<Inventory?>> favourites, String id) {
    favourites.removeWhere((e) => e.id == id);
    Users user = Users(
      name: data['name'],
      dob: data['dob'],
      gender: data['gender'],
    );
    return user.setObject(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: const Text(
          "Favourites",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("favourites")
            .doc(email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (streamSnapshot.hasError) {
            return Center(child: Text('Error: ${streamSnapshot.error}'));
          } else if (!streamSnapshot.hasData || !streamSnapshot.data!.exists) {
            return const Center(child: Text('No Data Found'));
          } else {
            Map<String, dynamic>? favInst =
            streamSnapshot.data?.data() as Map<String, dynamic>?;
            List<dynamic> favourites = favInst?['list'] ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: favourites.asMap().entries.map((entry) {
                    var data = entry.value as Map<String, dynamic>;
                    String name = data['name'] as String;
                    name.replaceAll(' ', '-');

                    return WideCard(
                      id: name,
                      title: data['name'],
                      imgUrl: data['img'],
                      showFav: true,
                      reorder: false,
                      cardClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDP(data: data),
                          ),
                        );
                      },
                      showFavClick: (_isFav) {
                        if (favourites.contains(data)) {
                          favourites.remove(data);
                        } else {
                          favourites.add(data);
                        }
                        favInst?['list'] = favourites;
                        FirebaseFirestore.instance.collection('favourites').doc(email).set(favInst!);
                        // print(data);
                        // print('_Fav Value: ${_isFav}');
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

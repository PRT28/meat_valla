import "package:flutter/material.dart";
import "package:meat_delivery/components/ClickCard.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  Future<List<DocumentSnapshot>> fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
          title: const Text(
            "Categories",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
            ),
          )
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no data is found
            return const Center(child: Text('No Data Found'));
          } else {
            List<DocumentSnapshot> categories = snapshot.data!;
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    children: categories.map((e) {
                      var data = e.data() as Map<String, dynamic>;
                      return ClickCard(
                          imageLink: data['url'],
                          text: data['name']
                      );
                    }).toList(),
                  ),
                ),),
            );
          }
        },
      ),
    );
  }
}

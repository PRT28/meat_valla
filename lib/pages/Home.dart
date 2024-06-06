import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/components/ClickCard.dart';
import 'package:meat_delivery/pages/Settings.dart' as app_settings;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? name = FirebaseAuth.instance.currentUser?.displayName;
  String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

  @override
  Widget build(BuildContext context) {

    Future<Map<String, List<DocumentSnapshot>>> fetchData() async {
      var categories = FirebaseFirestore.instance.collection('categories').limit(4).get();
      var banner = FirebaseFirestore.instance.collection('banner').get();
      var results = await Future.wait([categories, banner]);
      return {
        'categories': results[0].docs,
        'banner': results[1].docs,
      };
    }
    
    return Scaffold(
        backgroundColor: const Color(0xFFFFFDFA),
        body:FutureBuilder<Map<String, List<DocumentSnapshot>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Build the UI with the data
              var categories = snapshot.data!['categories']!;
              var banner = snapshot.data!['banner']!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child:  SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Hi, ${phone?.substring(3)}",
                            style: const TextStyle(
                                fontSize: 24,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          Hero(
                            tag: 'avatar-icon',
                            child: CircleAvatar(
                              backgroundColor: const Color(0xff000000),
                              radius: 21.5,
                              child: CircleAvatar(
                                  backgroundColor: const Color(0xFFF8F8F8),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const app_settings.Settings()));
                                    },
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.black,
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(
                        height: 15,
                      ),
                      const SizedBox(
                        width: 500,
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Color(0xFFF1F0F5),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none)
                            ),
                            hintText: 'Enter a search term',

                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CarouselSlider(
                          items: banner.map((e) {
                            var data = e.data() as Map<String, dynamic>;
                            return Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image(
                                  image: NetworkImage(data['url'])
                              ),
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: 180.0,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            aspectRatio: 16 / 9,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                          )
                      ),
                      // Container(
                      //   clipBehavior: Clip.hardEdge,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: const Image(
                      //       image: NetworkImage("https://cdn.create.vista.com/downloads/a4b7a196-a357-4d75-ace5-6fba62b5e78c_1024.jpeg")
                      //   ),
                      // ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Shop By Category",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Freshest meat jut for you",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      SizedBox(
                        height: 350,
                        width: 500,
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
                      ),
                    ],
                  ),),
              );
            }
          },
        ),
    );
  }
}


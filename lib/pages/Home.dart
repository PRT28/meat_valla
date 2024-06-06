import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/components/ClickCard.dart';
import 'package:meat_delivery/pages/Settings.dart';

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
    return Scaffold(
        backgroundColor: const Color(0xFFFFFDFA),
        body: SingleChildScrollView(
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
                        backgroundColor: Color(0xff000000),
                        radius: 21.5,
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFF8F8F8),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
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
                 Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Image(
                      image: NetworkImage("https://cdn.create.vista.com/downloads/a4b7a196-a357-4d75-ace5-6fba62b5e78c_1024.jpeg")
                  ),
                ),
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
                    children: const <Widget>[
                      ClickCard(
                          imageLink: 'https://st3.depositphotos.com/2125603/34616/i/450/depositphotos_346166616-stock-photo-raw-chicken-body-isolated-white.jpg',
                          text: 'Chicken'
                      ),
                      ClickCard(
                          imageLink: 'https://t3.ftcdn.net/jpg/02/04/61/82/360_F_204618263_v6wWkUH1lmNr2O9qU1Dvd5BBWgrhqR2b.jpg',
                          text: 'Mutton'
                      ),
                      ClickCard(
                          imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                          text: 'Fish'
                      ),
                      ClickCard(
                          imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                          text: 'Fish'
                      ),
                    ],
                  ),
                ),
              ],
            ),),
        )
    );
  }
}
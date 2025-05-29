import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:meat_delivery/pages/About.dart';
import 'package:meat_delivery/pages/AddressList.dart';
import 'package:meat_delivery/pages/EditProfile.dart';
import 'package:meat_delivery/pages/Favourites.dart';
import 'package:meat_delivery/pages/Login.dart';
import 'package:meat_delivery/pages/OrderHistory.dart';
import 'package:meat_delivery/pages/SendFeedback.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

  String? email = FirebaseAuth.instance.currentUser?.email;


  logoutHandle() async {
    await FirebaseAuth.instance.signOut().whenComplete(() {
      Navigator.pop(context,true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
    }

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const BackButton(),
                  const Hero(
                      tag: 'avatar-icon',
                      child:  CircleAvatar(
                        backgroundColor: Color(0xff000000),
                        radius: 21.5,
                        child: CircleAvatar(
                            backgroundColor: Color(0xFFF8F8F8),
                            child: Icon(
                              Icons.person,
                              color: Colors.black,
                            )
                        ),
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${email?.split('@')[0]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        GestureDetector(
                            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));},
                            child: const Text("Edit Profile",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Color(0xFF850E35),
                                fontWeight: FontWeight.w600
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
              TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Favourites()));
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text("Favourites",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18
                    ),
                  )
              ),

              TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressList(isOrder: false)));
                  },
                  icon: const Hero(
                    tag: "address-icon",
                      child: Icon(Icons.home_filled)
                  ),
                  label: const Text("Address",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                    ),
                  )
              ),

              TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistory()));
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("Order History",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                    ),
                  )
              ),


              TextButton.icon(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const About()));},
                  icon: const Icon(Icons.book),
                  label: const Text("About",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                    ),
                  )
              ),

              TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SendFeedback()));
                  },
                  icon: const Icon(Icons.send),
                  label: const Text("Send Feedback",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                    ),
                  )
              ),

              TextButton.icon(
                  onPressed: logoutHandle,
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                    ),
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }
}

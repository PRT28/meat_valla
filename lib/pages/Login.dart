import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/pages/Register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String verifyId = "";
  String otp = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  buttonHandle () async {
    print("Button is clicked");
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );


    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/bglogin.jpg"), fit: BoxFit.cover),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0x00FFFFFF),
                        border: const BorderDirectional(
                            top: BorderSide(
                              width: 3,
                                color: Colors.white
                            ),
                            bottom: BorderSide(
                                width: 3,
                                color: Colors.white
                            ),
                            start: BorderSide(
                                width: 3,
                                color: Colors.white
                            ),
                            end: BorderSide(
                                width: 3,
                                color: Colors.white
                            )
                        )
                    ),
                    height: 420,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FadeTransition(
                              opacity: _opacityAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                width: 300,
                                height: 100,
                                child: const Center(
                                  child: Text("Meat Wala",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Poppins"
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(
                          height: 20,
                        ),

                          const SizedBox(
                            height: 10,
                          ),

                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                labelText: "Email ID",
                              labelStyle: const TextStyle(
                                color: Colors.white
                              ),
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.white,),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),

                          const SizedBox(
                             height: 8,
                           ),

                          TextField(
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: const TextStyle(
                                  color: Colors.white
                              ),
                              prefixIcon: const Icon(Icons.password_outlined, color: Colors.white,),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),



                          const SizedBox(
                            height: 10,
                          ),


                          _isLoading ? const CupertinoActivityIndicator(
                              radius: 20.0, color: Colors.white
                          ) :
                          Button(
                            onClick: buttonHandle,
                            label: "Login"
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          
                          TextButton(
                              onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => Register()))}, 
                              child: const Text(
                                  "Are you new user??",
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              )
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:meat_delivery/pages/EditProfile.dart';
import 'package:meat_delivery/pages/Login.dart';

import 'package:meat_delivery/pages/Register.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
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
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (credential.user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EditProfile(isOnboarding: true)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
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

                        const Text(
                          'Register yourself',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                          ),),

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
                            label: "Register"
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        TextButton(
                            onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => Login()))},
                            child: const Text(
                              "Login into current account!!",
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

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:meat_delivery/models/Users.dart';
import 'package:meat_delivery/pages/Base.dart';
import 'dart:developer';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  TextEditingController phoneController = TextEditingController();
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

  bool _phoneEntered = false;

  bool _isLoading = false;

  buttonHandle () async {
    print("Button is clicked");
    if (!_phoneEntered) {

      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.verifyPhoneNumber(
          verificationCompleted: (PhoneAuthCredential credential) {

          },
          verificationFailed: (FirebaseAuthException ex) {},
          codeSent: (String verificationId, int? resendtoken) {
            print("Code sent success");
            setState(() {
              _isLoading = false;
              _phoneEntered = true;
              verifyId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          phoneNumber: "+91${phoneController.text}"
      );


    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        PhoneAuthCredential credential = await PhoneAuthProvider.credential(
            verificationId: verifyId, smsCode: otp
        );
        FirebaseAuth.instance.signInWithCredential(credential)
          .then((value) {
          setState(() {
            _isLoading = false;
          });

          Users user = Users(name: '', dob: DateTime(2000), gender: '');
          user.setObject(phoneController.toString());
           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Base()), (Route<dynamic> route) => false);
        });
      } catch(ex) {
        setState(() {
          _isLoading = false;
        });
        log(ex.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
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
                    height: 300,
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

                          !_phoneEntered ? TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                labelText: "Phone Number",
                              labelStyle: const TextStyle(
                                color: Colors.white
                              ),
                              prefixIcon: const Icon(Icons.phone, color: Colors.white,),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder:OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ) : const SizedBox.shrink(),

                         _phoneEntered ?
                           const Text("Enter OTP",
                             textAlign: TextAlign.left,
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 18,
                               fontWeight: FontWeight.w400,
                               fontFamily: "Poppins",
                             ),) : const SizedBox.shrink(),

                          const SizedBox(
                             height: 8,
                           ),

                          _phoneEntered ? OtpTextField(
                             numberOfFields: 6,
                             showFieldAsBox: true,
                             borderWidth: 2.0,
                             hasCustomInputDecoration: true,
                             textStyle: const TextStyle(
                               color: Colors.white
                             ),
                             borderRadius: BorderRadius.circular(12),
                             decoration: InputDecoration(
                               counterText: "",
                               border: OutlineInputBorder(
                                 borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                 borderRadius: BorderRadius.circular(12.0),
                               ),
                               focusedBorder:OutlineInputBorder(
                                 borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                 borderRadius: BorderRadius.circular(12.0),
                               ),
                             ),
                             onSubmit: (String verificationCode) {
                               setState(() {
                                 otp = verificationCode;
                               });
                             },
                           ): SizedBox.shrink(),



                          const SizedBox(
                            height: 10,
                          ),


                          _isLoading ? const CupertinoActivityIndicator(
                              radius: 20.0, color: Colors.white
                          ) :
                          Button(
                            onClick: buttonHandle,
                            label: _phoneEntered ? "Confirm OTP" : "Send OTP"
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

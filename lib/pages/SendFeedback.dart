import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendFeedback extends StatefulWidget {
  const SendFeedback({super.key});


  @override
  State<SendFeedback> createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

    sendFeedback() async {
      await FirebaseFirestore.instance.collection('feedback').add({
        'feedback': addressController.text.toString().trim(),
        'user': phone?.substring(3)
      }).then((value) {
        Navigator.of(context).pop();
      });

    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: const Text(
          "Send Feedback",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
            onClick: sendFeedback,
            label: "Send"
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: addressController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: "Write your feedback",
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF850E35), width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

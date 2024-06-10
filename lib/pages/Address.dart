import 'package:flutter/material.dart';
import 'package:meat_delivery/components/Button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Address extends StatefulWidget {
  final String? title;
  const Address({super.key, this.title});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

    saveAddress() async {
      var address = await FirebaseFirestore.instance.collection('address').doc(phone?.substring(3)).get();
      var data = address.data();
      List<dynamic> addressList = data?['list'];
      if (widget.title == null) {
        addressList.add(addressController.text.toString().trim());
      } else {
        int index = addressList.indexOf(widget.title);
        addressList[index] = addressController.text.toString().trim();
      }
      data?['list'] = addressList;
      FirebaseFirestore.instance.collection('address').doc(phone?.substring(3)).set(data!, SetOptions(merge: true)).then((value) {
        Navigator.of(context).pop();
      });

    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: Text(
          widget.title == null ? 'Add Address' : 'Edit Address',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
            onClick: saveAddress,
            label: "Save Address"
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
                labelText: "Address",
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

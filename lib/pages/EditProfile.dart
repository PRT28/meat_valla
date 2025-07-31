import "dart:ffi";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:meat_delivery/components/Button.dart";
import 'package:meat_delivery/pages/Base.dart';

class EditProfile extends StatefulWidget {

  final bool isOnboarding;
  const EditProfile({super.key, this.isOnboarding = false});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? email = FirebaseAuth.instance.currentUser?.email;

  final List<String> _genderNames = <String>[
    'Gender',
    'Male',
    'Female',
    'Others',
  ];

  int _selectedGender = 0;
  final double _kItemExtent = 32.0;
  DateTime _selectedDate = DateTime.now();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool _isLoading = true;

  Future<void> fetchData() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(email)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      nameController.text = userData['name'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      _selectedGender = userData['gender'] ?? 0;

      Timestamp t = userData['dob'] ?? Timestamp.fromDate(DateTime(2016, 10, 26));
      _selectedDate = t.toDate();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(top: false, child: child),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
          title: Text(widget.isOnboarding ? "Create Profile" : "Edit Profile",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Hero(
                  tag: 'avatar-icon',
                  child: CircleAvatar(
                    backgroundColor: Color(0xff000000),
                    radius: 42,
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFF8F8F8),
                      radius: 40,
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Color(0xFF850E35)),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showDialog(
                    CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: _kItemExtent,
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedGender,
                      ),
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          _selectedGender = selectedItem;
                        });
                      },
                      children: List<Widget>.generate(
                          _genderNames.length,
                              (int index) => Center(
                              child: Text(_genderNames[index]))),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 10),
                        Text(
                          _genderNames[_selectedGender],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Color(0xFF850E35)),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showDialog(
                    CupertinoDatePicker(
                      initialDateTime: _selectedDate,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      showDayOfWeek: true,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => _selectedDate = newDate);
                      },
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedDate.month}-${_selectedDate.day}-${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Button(
                  onClick: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(email)
                        .set({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'gender': _selectedGender,
                      'dob': _selectedDate,
                    }, SetOptions(merge: true));
                    if (widget.isOnboarding) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Base()),
                            (Route<dynamic> route) => false, // Removes all previous routes
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  label: "Save",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

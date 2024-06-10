import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:meat_delivery/components/Button.dart";
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchData() async {
    DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(phone?.substring(3))
        .get();
    return querySnapshot;
  }

  final List<String> _genderNames = <String>[
    'Gender',
    'Male',
    'Female',
    'Others',
  ];

  int _selectedGender = 0;
  final double _kItemExtent = 32.0;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) =>
          Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: child,
            ),
          ),
    );
  }

  void _showDateDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
        title: const Text(
            "Edit Profile", style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700
        ),)
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
          } else {

            DocumentSnapshot<Map<String, dynamic>> user = snapshot.data!;

            TextEditingController nameController = TextEditingController(text: user['name'] ?? '');
            Timestamp t = user['dob'] ?? DateTime(2016, 10, 26) as Timestamp;
            DateTime date = t.toDate();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: SafeArea(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Hero(
                            tag: 'avatar-icon',
                            child:  CircleAvatar(
                              backgroundColor: Color(0xff000000),
                              radius: 42,
                              child: CircleAvatar(
                                  backgroundColor: Color(0xFFF8F8F8),
                                  radius: 40,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: 50,
                                  )
                              ),
                            )
                        ),

                        const SizedBox(
                          height: 40,
                        ),

                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder:OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF850E35), width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        GestureDetector(
                          onTap: () => _showDialog(
                            CupertinoPicker(
                              magnification: 1.22,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: _kItemExtent,
                              // This sets the initial item.
                              scrollController: FixedExtentScrollController(
                                initialItem: _selectedGender,
                              ),
                              // This is called when selected item is changed.
                              onSelectedItemChanged: (int selectedItem) {
                                setState(() {
                                  _selectedGender = selectedItem;
                                });
                              },
                              children:
                              List<Widget>.generate(_genderNames.length, (int index) {
                                return Center(child: Text(_genderNames[index]));
                              }),
                            ),
                          ),
                          child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(10),
                                  border: const BorderDirectional(
                                      top: BorderSide(
                                          color: Colors.grey
                                      ),
                                      bottom: BorderSide(
                                          color: Colors.grey
                                      ),
                                      start: BorderSide(
                                          color: Colors.grey
                                      ),
                                      end: BorderSide(
                                          color: Colors.grey
                                      )
                                  )
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _genderNames[_selectedGender],
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () => _showDateDialog(
                            CupertinoDatePicker(
                              initialDateTime: date,
                              mode: CupertinoDatePickerMode.date,
                              use24hFormat: true,
                              showDayOfWeek: true,
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() => date = newDate);
                              },
                            ),
                          ),
                          child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(10),
                                  border: const BorderDirectional(
                                      top: BorderSide(
                                          color: Colors.grey
                                      ),
                                      bottom: BorderSide(
                                          color: Colors.grey
                                      ),
                                      start: BorderSide(
                                          color: Colors.grey
                                      ),
                                      end: BorderSide(
                                          color: Colors.grey
                                      )
                                  )
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${date.month}-${date.day}-${date.year}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Button(
                            onClick: () {
                              FirebaseFirestore.instance.collection('users')
                                  .doc(phone?.substring(3))
                                  .set({
                                'name': nameController.text.toString(),
                                'gender': _selectedGender,
                                'dob': date
                              }, SetOptions(merge: true)).then((value) {
                                Navigator.of(context).pop();
                              });

                            },
                            label: "Save"
                        )

                      ],
                    ),
                  )
              ),
            );
          }
        })




    );
  }
}

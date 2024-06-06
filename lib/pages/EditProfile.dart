import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:meat_delivery/components/Button.dart";

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final List<String> _fruitNames = <String>[
    'Gender',
    'Male',
    'Female',
    'Others',
  ];

  int _selectedFruit = 0;
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

    TextEditingController phoneController = TextEditingController();

  DateTime date = DateTime(2016, 10, 26);


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
      body: SingleChildScrollView(
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
                  controller: phoneController,
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
                        initialItem: _selectedFruit,
                      ),
                      // This is called when selected item is changed.
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          _selectedFruit = selectedItem;
                        });
                      },
                      children:
                      List<Widget>.generate(_fruitNames.length, (int index) {
                        return Center(child: Text(_fruitNames[index]));
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
                          _fruitNames[_selectedFruit],
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
                      Navigator.of(context).pop();
                    },
                    label: "Save"
                )

              ],
            ),
          )
        ),
      )
    );
  }
}

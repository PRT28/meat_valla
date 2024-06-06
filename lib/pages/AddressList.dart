import "package:flutter/material.dart";
import "package:meat_delivery/components/Button.dart";
import "package:meat_delivery/pages/Address.dart";
import "package:meat_delivery/pages/OrderSuccess.dart";

class AddressTextButton extends StatelessWidget {
  
  final String title;
  final int id;
  final bool selected;
  final void Function(int) setSelected;
  
  const AddressTextButton({
    super.key,
    required this.title,
    required this.id,
    required this.selected,
    required this.setSelected
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setSelected(id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(10),
            border: BorderDirectional(
                top: BorderSide(
                  width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                ),
                bottom: BorderSide(
                    width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                ),
                start: BorderSide(
                    width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                ),
                end: BorderSide(
                    width: 2,
                    color: selected ? const Color(0xFF850E35) : Colors.black
                )
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            IconButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Address(title: title)));},
                icon: const Icon(Icons.edit, size: 18,))
          ],
        ),
      ),
    );
  }
}


class AddressList extends StatefulWidget {
  final bool isOrder;


  const AddressList({super.key, required this.isOrder});


  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {

  int _selected = 1;

  setSelected(id) {
    setState(() {
      _selected = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Button(
            onClick: () {
              if (widget.isOrder) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
              } else {
                Navigator.of(context).pop();
              }

              },
            label: widget.isOrder ? "Place Order" : "Okay"
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Hero(
                    tag: "address-icon",
                    child:  Icon(
                        Icons.home_filled,
                      size: 80,
                      color: Color(0xFF850E35),
                    )
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Address",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600
                ),),
                const SizedBox(
                  height: 20,
                ),
                AddressTextButton(
                    title: "Address 1",
                    id: 1,
                    selected: 1 == _selected,
                    setSelected: setSelected,
                ),
                const SizedBox(
                  height: 10,
                ),
                AddressTextButton(
                  title: "Address 2",
                  id: 2,
                  selected: 2 == _selected,
                  setSelected: setSelected,
                ),
                const SizedBox(
                  height: 10,
                ),
                AddressTextButton(
                  title: "Address 3",
                  id: 3,
                  selected: 3 == _selected,
                  setSelected: setSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


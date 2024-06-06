import 'package:flutter/material.dart';
import 'package:meat_delivery/components/WideCard.dart';
import 'package:meat_delivery/pages/PDP.dart';

class PLP extends StatefulWidget {

  final String title;

  const PLP({super.key, required this.title});

  @override
  State<PLP> createState() => _PLPState();
}

class _PLPState extends State<PLP> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFDFA),
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
            ),
          )
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  WideCard(
                      id: 1,
                      title: 'Hiii',
                    showFav: true,
                    reorder: false,
                    cardClick: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PDP(id: 1)))},
                    showFavClick: (_isFav) {
                        print('_Fav Value: ${_isFav}');
                    },
                  ),
                  WideCard(
                    id: 2,
                    title: 'Hiii',
                    showFav: true,
                    reorder: false,
                    cardClick: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PDP(id: 2)))},
                    showFavClick: (_isFav) {
                      print('_Fav Value: ${_isFav}');
                    },
                  ),
                ],
              )
          ),
        )
    );
  }
}


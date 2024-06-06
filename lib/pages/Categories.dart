import "package:flutter/material.dart";
import "package:meat_delivery/components/ClickCard.dart";

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
          title: const Text(
            "Categories",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
            ),
          )
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                shrinkWrap: true,
                primary: false,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: const <Widget>[
                  ClickCard(
                      imageLink: 'https://st3.depositphotos.com/2125603/34616/i/450/depositphotos_346166616-stock-photo-raw-chicken-body-isolated-white.jpg',
                      text: 'Chicken'
                  ),
                  ClickCard(
                      imageLink: 'https://t3.ftcdn.net/jpg/02/04/61/82/360_F_204618263_v6wWkUH1lmNr2O9qU1Dvd5BBWgrhqR2b.jpg',
                      text: 'Mutton'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://st3.depositphotos.com/2125603/34616/i/450/depositphotos_346166616-stock-photo-raw-chicken-body-isolated-white.jpg',
                      text: 'Chicken'
                  ),
                  ClickCard(
                      imageLink: 'https://t3.ftcdn.net/jpg/02/04/61/82/360_F_204618263_v6wWkUH1lmNr2O9qU1Dvd5BBWgrhqR2b.jpg',
                      text: 'Mutton'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://st3.depositphotos.com/2125603/34616/i/450/depositphotos_346166616-stock-photo-raw-chicken-body-isolated-white.jpg',
                      text: 'Chicken'
                  ),
                  ClickCard(
                      imageLink: 'https://t3.ftcdn.net/jpg/02/04/61/82/360_F_204618263_v6wWkUH1lmNr2O9qU1Dvd5BBWgrhqR2b.jpg',
                      text: 'Mutton'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://st3.depositphotos.com/2125603/34616/i/450/depositphotos_346166616-stock-photo-raw-chicken-body-isolated-white.jpg',
                      text: 'Chicken'
                  ),
                  ClickCard(
                      imageLink: 'https://t3.ftcdn.net/jpg/02/04/61/82/360_F_204618263_v6wWkUH1lmNr2O9qU1Dvd5BBWgrhqR2b.jpg',
                      text: 'Mutton'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                  ClickCard(
                      imageLink: 'https://previews.123rf.com/images/imagedb/imagedb1108/imagedb110815532/10239720-close-up-of-a-raw-fish.jpg',
                      text: 'Fish'
                  ),
                ],
              ),
            ),),
      ),
    );
  }
}

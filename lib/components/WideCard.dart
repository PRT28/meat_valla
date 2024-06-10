import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';

class WideCard extends StatelessWidget {

  final String id;
  final String title;
  final bool showFav;
  final Function showFavClick;
  final VoidCallback cardClick;
  final bool reorder;
  final String imgUrl;

  const WideCard({
    super.key,
    required this.id,
    required this.title,
    required this.showFav,
    required this.showFavClick,
    required this.cardClick,
    required this.reorder,
    required this.imgUrl
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cardClick,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [ BoxShadow(
                color: Colors.black,
                blurRadius: 2.0,
                offset: Offset(0, 2)
            ),]
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Hero(
                    tag: 'plp-title-${id}',
                    child: Image(
                      image: NetworkImage(imgUrl),
                      height: 80,
                      width: 80,
                    ),
                  ),
                   Text(title,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                      )),
                ],
              ),

              reorder ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.replay),
              ) : const SizedBox.shrink(),

              showFav ? FavoriteButton(
                  iconSize: 36,
                  isFavorite: showFav,
                  valueChanged: showFavClick) : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
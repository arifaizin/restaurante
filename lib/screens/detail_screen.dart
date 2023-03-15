import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../model/restaurant.dart';

class DetailScreen extends StatelessWidget {

  static const routeName = '/restaurant_detail';

  final Restaurant restaurant;

  DetailScreen({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      // body: NestedScrollView(
      // headerSliverBuilder: (context, isScrolled) {
      //   return [
      //     SliverAppBar(
      //       floating: true,
      //       expandedHeight: 200,
      //       pinned: true,
      //       flexibleSpace: FlexibleSpaceBar(
      //         background: Hero(
      //           tag: "photo" + restaurant.id,
      //           child: Image.network(
      //             restaurant.pictureId,
      //             fit: BoxFit.fitWidth,
      //           ),
      //         ),
      //         title: Text(restaurant.name),
      //         titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
      //       ),
      //     ),
      //   ];
      // },
      // body: Column(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Hero(
                    tag: "photo" + restaurant.id,
                    child: Image.network(restaurant.pictureId)),
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ),
                Positioned(
                  right: 0.0,
                  bottom: 20.0,
                  child: RawMaterialButton(
                    onPressed: () {},
                    fillColor: Colors.white,
                    shape: CircleBorder(),
                    elevation: 4.0,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: FavoriteButton(),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0, left: 20.0),
                child: Text(
                  restaurant.name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito'),
                )),
            Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  restaurant.city,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18.0, fontFamily: 'Nunito'),
                )),
            Container(
                margin: EdgeInsets.only(left: 20.0),
                child: SmoothStarRating(
                    allowHalfRating: false,
                    starCount: 5,
                    rating: restaurant.rating,
                    size: 40.0,
                    color: Colors.orange,
                    borderColor: Colors.orange,
                    spacing: 0.0)),
            Container(
                margin: EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  "Description",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.w800),
                )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                restaurant.description,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
        });
      },
    );
  }
}

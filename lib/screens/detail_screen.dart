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
            Container(
                margin: EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  "Foods",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.w800),
                )),
            SizedBox(
              height: 145,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: _buildList(context, restaurant.menus.foods),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  "Drink",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.w800),
                )
            ),
            SizedBox(
              height: 145,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: _buildList(context, restaurant.menus.drinks),
              ),
            )
          ],
        ),
      ),
    );
  }
}

ListView _buildList(BuildContext context, List<Drink> foods) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    shrinkWrap: true,
    itemCount: foods.length,
    itemBuilder: (context, index) {
      return _buildRestaurantItem(context, foods[index]);
    },
  );
}

Widget _buildRestaurantItem(BuildContext context, Drink food) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: SizedBox(
      width: 120,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              child: InkWell(
                child: Icon(
                  Icons.fastfood,
                  size: 50.0,
                  color: Colors.orange,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

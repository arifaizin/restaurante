import 'package:flutter/material.dart';
import 'package:restaurant_app/model/restaurant.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            DetailScreen.routeName,
            arguments: restaurant.id,
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Hero(
                  tag: "photo" + restaurant.id,
                  child: Image.network(
                    restaurant.fullImageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.error),
                      );
                    },
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
                      restaurant.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.0,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          restaurant.city,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SmoothStarRating(
                          allowHalfRating: false,
                          starCount: 5,
                          rating: restaurant.rating,
                          size: 20.0,
                          color: Colors.orange,
                          borderColor: Colors.orange,
                          spacing: 0.0,
                        ),
                        Text(
                          " (${restaurant.rating})",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        restaurant.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
}

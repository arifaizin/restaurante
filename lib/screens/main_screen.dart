import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/model/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/util/constants.dart';
import 'package:restaurant_app/util/platform_widget.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import 'detail_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/restaurant_list';

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     automaticallyImplyLeading: false,
    //     centerTitle: true,
    //     title: Text(
    //       Constants.appName,
    //       style: TextStyle(
    //           fontSize: 28.0,
    //           fontWeight: FontWeight.bold,
    //           fontFamily: 'Nunito'),
    //     ),
    //     elevation: 0.0,
    //   ),
    //   body: _buildList(context),
    // );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            Constants.appName,
            style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito'),
          ),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, SearchScreen.routeName);
            },
            tooltip: 'Search restaurants',
          ),
        ],
      ),
      body: _buildList(context),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            Constants.appName,
            style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito'),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.search),
          onPressed: () {
            Navigator.pushNamed(context, SearchScreen.routeName);
          },
        ),
      ),
      child: _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (provider.hasError) {
          return _buildErrorState(context, provider);
        } else if (provider.hasData) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchRestaurants(),
            child: ListView.builder(
              itemCount: provider.restaurants.length,
              itemBuilder: (context, index) {
                return _buildRestaurantItem(
                    context, provider.restaurants[index]);
              },
            ),
          );
        } else {
          // Initial state - trigger fetch
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchRestaurants();
          });
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildErrorState(BuildContext context, RestaurantProvider provider) {
    final isNetworkError =
        provider.errorMessage?.toLowerCase().contains('internet') == true ||
            provider.errorMessage?.toLowerCase().contains('network') == true ||
            provider.errorMessage?.toLowerCase().contains('connection') == true;

    return RefreshIndicator(
      onRefresh: () => provider.fetchRestaurants(),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isNetworkError ? Icons.wifi_off : Icons.error_outline,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 16),
                  Text(
                    isNetworkError
                        ? 'No Internet Connection'
                        : 'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    provider.errorMessage ?? 'Unknown error occurred',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.retry(),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  if (isNetworkError) ...[
                    SizedBox(height: 12),
                    Text(
                      'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantItem(BuildContext context, Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, DetailScreen.routeName,
              arguments: restaurant.id);
        },
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
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
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 4.0),
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
                            spacing: 0.0),
                        Text(
                          " (20 review)",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        restaurant.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(fontSize: 14.0),
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

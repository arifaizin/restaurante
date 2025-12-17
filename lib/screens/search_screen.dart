import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/model/restaurant.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/util/platform_widget.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/restaurant_search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Restaurants',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
        elevation: 0.0,
      ),
      body: _buildSearchBody(context),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Search Restaurants',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
      ),
      child: _buildSearchBody(context),
    );
  }

  Widget _buildSearchBody(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(context),
        Expanded(
          child: _buildSearchResults(context),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search restaurants...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'Nunito',
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchProvider>().clearSearch();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.orange, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
        ),
        textInputAction: TextInputAction.search,
        onChanged: (query) {
          setState(() {}); // Rebuild to show/hide clear button
          context.read<SearchProvider>().searchRestaurants(query);
        },
        onSubmitted: (query) {
          _searchFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.currentQuery.isEmpty) {
          return _buildEmptySearchState();
        } else if (provider.isLoading) {
          return _buildLoadingState();
        } else if (provider.hasError) {
          return _buildErrorState(context, provider);
        } else if (provider.hasResults) {
          return _buildResultsList(context, provider.searchResults);
        } else {
          return _buildNoResultsState(provider.currentQuery);
        }
      },
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Search for restaurants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter at least 3 characters to start searching',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Searching restaurants...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SearchProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildErrorIcon(provider),
            SizedBox(height: 16),
            Text(
              _getErrorTitle(provider),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 8),
            Text(
              provider.getUserFriendlyErrorMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 24),
            _buildRetrySection(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon(SearchProvider provider) {
    IconData iconData;
    Color iconColor = Colors.grey[600]!;

    switch (provider.errorType) {
      case SearchErrorType.network:
        iconData = Icons.wifi_off;
        iconColor = Colors.orange[600]!;
        break;
      case SearchErrorType.timeout:
        iconData = Icons.access_time;
        iconColor = Colors.blue[600]!;
        break;
      case SearchErrorType.server:
        iconData = Icons.cloud_off;
        iconColor = Colors.red[600]!;
        break;
      case SearchErrorType.api:
        iconData = Icons.api;
        iconColor = Colors.purple[600]!;
        break;
      default:
        iconData = Icons.error_outline;
        iconColor = Colors.grey[600]!;
    }

    return Icon(
      iconData,
      size: 64,
      color: iconColor,
    );
  }

  String _getErrorTitle(SearchProvider provider) {
    switch (provider.errorType) {
      case SearchErrorType.network:
        return 'No Internet Connection';
      case SearchErrorType.timeout:
        return 'Request Timed Out';
      case SearchErrorType.server:
        return 'Server Error';
      case SearchErrorType.api:
        return 'Service Unavailable';
      default:
        return 'Search Failed';
    }
  }

  Widget _buildRetrySection(BuildContext context, SearchProvider provider) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: provider.isLoading ? null : () => provider.retry(),
          icon: provider.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.refresh),
          label: Text(provider.isLoading ? 'Retrying...' : 'Retry Search'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        if (provider.isNetworkError) ...[
          SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              final hasConnection = await provider.checkConnectivity();
              if (hasConnection) {
                provider.retry();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Still no internet connection detected'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            icon: Icon(Icons.network_check, size: 18),
            label: Text('Check Connection'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
          ),
        ],
        SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            provider.clearError();
            _searchController.clear();
            provider.clearSearch();
            _searchFocusNode.requestFocus();
          },
          icon: Icon(Icons.search, size: 18),
          label: Text('New Search'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Nunito',
              ),
            ),
            if (query.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Searched for: "$query"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Restaurant> restaurants) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return _buildRestaurantItem(context, restaurants[index]);
      },
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
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 16.0,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          restaurant.city,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
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
                          " (${restaurant.rating})",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        restaurant.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Nunito',
                        ),
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

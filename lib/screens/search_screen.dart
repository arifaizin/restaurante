import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/model/restaurant.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/util/error_helper.dart';
import 'package:restaurant_app/util/platform_widget.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/restaurant_search';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
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
        title: const Text('Search Restaurants'),
        elevation: 0.0,
      ),
      body: _buildSearchBody(context),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search Restaurants'),
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
      padding: const EdgeInsets.all(16.0),
      child: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search restaurants...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.currentQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.clearSearch();
                        _searchFocusNode.unfocus();
                      },
                    )
                  : null,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (query) {
              provider.searchRestaurants(query);
            },
            onSubmitted: (query) {
              _searchFocusNode.unfocus();
            },
          );
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
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
              const SizedBox(height: 16),
              Text(
                'Search Restaurants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter at least 3 characters to start searching',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching restaurants...',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SearchProvider provider) {
    final userFriendlyMessage =
        ErrorHelper.getUserFriendlyMessage(provider.errorMessage);
    final isNetworkError = ErrorHelper.isNetworkError(provider.errorMessage);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                isNetworkError ? 'No Internet Connection' : 'Search Failed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                userFriendlyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildRetrySection(context, provider, isNetworkError),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetrySection(
      BuildContext context, SearchProvider provider, bool isNetworkError) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: provider.isLoading ? null : () => provider.retry(),
          icon: provider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(provider.isLoading ? 'Retrying...' : 'Try Again'),
        ),
        if (isNetworkError) ...[
          const SizedBox(height: 12),
          Text(
            'Check your internet connection',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            _searchController.clear();
            provider.clearSearch();
            _searchFocusNode.requestFocus();
          },
          icon: const Icon(Icons.search, size: 18),
          label: const Text('New Search'),
        ),
      ],
    );
  }

  Widget _buildNoResultsState(String query) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
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
              const SizedBox(height: 16),
              Text(
                'Restaurants Not Found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Try using different keywords',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0),
              ),
              if (query.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Search: "$query"',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Restaurant> restaurants) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Hero(
                  tag: "photo${restaurant.id}",
                  child: Image.network(
                    restaurant.fullImageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
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
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 16.0,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          restaurant.city,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
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

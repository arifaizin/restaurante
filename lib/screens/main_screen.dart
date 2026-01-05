import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/preferences_provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/screens/favorite_screen.dart';
import 'package:restaurant_app/util/constants.dart';
import 'package:restaurant_app/util/error_helper.dart';
import 'package:restaurant_app/util/platform_widget.dart';
import 'package:restaurant_app/widgets/restaurant_card.dart';

import 'package:restaurant_app/screens/settings_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/restaurant_list';

  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(androidBuilder: _buildAndroid, iosBuilder: _buildIos);
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
        centerTitle: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(Constants.appName),
        ),
        elevation: 0.0,
        actions: [
          Consumer<PreferencesProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () {
                  provider.enableDarkTheme(!provider.isDarkTheme);
                },
              );
            },
          ),
          PopupMenuButton<String>(
            key: const ValueKey('myPopupMenuButton'),
            onSelected: (value) {
              switch (value) {
                case 'search':
                  Navigator.pushNamed(context, SearchScreen.routeName);
                  break;
                case 'favorite':
                  Navigator.pushNamed(context, FavoriteScreen.routeName);
                  break;
                case 'settings':
                  Navigator.pushNamed(context, SettingsScreen.routeName);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Search'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(Icons.favorite),
                    SizedBox(width: 8),
                    Text('Favorite'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
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
          child: Text(Constants.appName),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<PreferencesProvider>(
              builder: (context, provider, child) {
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    provider.isDarkTheme
                        ? CupertinoIcons.moon_stars_fill
                        : CupertinoIcons.sun_max_fill,
                  ),
                  onPressed: () {
                    provider.enableDarkTheme(!provider.isDarkTheme);
                  },
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.ellipsis_vertical),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, SearchScreen.routeName);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.search),
                            SizedBox(width: 8),
                            Text('Search'),
                          ],
                        ),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            FavoriteScreen.routeName,
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.heart),
                            SizedBox(width: 8),
                            Text('Favorite'),
                          ],
                        ),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            SettingsScreen.routeName,
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.settings),
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provider.hasError) {
          return _buildErrorState(context, provider);
        } else if (provider.hasData) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchRestaurants(),
            child: ListView.builder(
              itemCount: provider.restaurants.length,
              itemBuilder: (context, index) {
                return RestaurantCard(restaurant: provider.restaurants[index]);
              },
            ),
          );
        } else {
          // Initial state - trigger fetch
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchRestaurants();
          });
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildErrorState(BuildContext context, RestaurantProvider provider) {
    final userFriendlyMessage = ErrorHelper.getUserFriendlyMessage(
      provider.errorMessage,
    );
    final isNetworkError = ErrorHelper.isNetworkError(provider.errorMessage);

    return RefreshIndicator(
      onRefresh: () => provider.fetchRestaurants(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
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
                  const SizedBox(height: 16),
                  Text(
                    isNetworkError
                        ? 'Tidak Ada Koneksi Internet'
                        : 'Ups! Terjadi Kesalahan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userFriendlyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.retry(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                  if (isNetworkError) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Tarik ke bawah untuk memuat ulang',
                      style: Theme.of(context).textTheme.bodySmall,
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
}

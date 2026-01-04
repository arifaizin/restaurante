import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:intl/intl.dart';

import '../providers/restaurant_detail_provider.dart';
import '../providers/review_submission_provider.dart';
import '../widgets/review_submission_form.dart';
import '../util/error_helper.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/restaurant_detail';

  final String restaurantId;

  DetailScreen({required this.restaurantId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger data fetching after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantDetailProvider>(context, listen: false)
          .fetchRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (provider.hasError) {
            return _buildErrorState(context, provider);
          } else if (provider.hasData) {
            final restaurant = provider.restaurantDetail!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildRestaurantHeader(restaurant),
                  _buildBasicInformation(restaurant),
                  _buildMenusSection(restaurant),
                  _buildCustomerReviewsSection(restaurant),
                  SizedBox(height: 20.0),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildRestaurantHeader(restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Restaurant Image with overlay controls
        Stack(
          children: <Widget>[
            Hero(
              tag: "photo" + restaurant.id,
              child: Container(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  restaurant.fullImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
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
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16.0,
              bottom: 16.0,
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
        // Restaurant Name and Rating Section
        Container(
          padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Name
              Text(
                restaurant.name,
                style: Theme.of(context).textTheme.headlineMedium,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
              SizedBox(height: 8.0),
              // Rating with formatted display
              Row(
                children: [
                  SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 5,
                    rating: restaurant.rating,
                    size: 20.0,
                    color: Colors.orange,
                    borderColor: Colors.orange,
                    spacing: 2.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '${restaurant.rating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInformation(restaurant) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Information
          _buildSectionTitle('Location'),
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.grey[600], size: 18.0),
              SizedBox(width: 8.0),
              Text(
                restaurant.city,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          SizedBox(height: 4.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 18.0),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  restaurant.address,
                  style: Theme.of(context).textTheme.bodyLarge,
                  softWrap: true,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.0),

          // Categories Section
          if (restaurant.categories.isNotEmpty) ...[
            _buildSectionTitle('Categories'),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: restaurant.categories.map<Widget>((category) {
                return Chip(
                  label: Text(
                    category.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  backgroundColor: Colors.orange,
                  elevation: 2.0,
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
          ],

          // Description Section
          _buildSectionTitle('Description'),
          SizedBox(height: 8.0),
          Text(
            restaurant.description,
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenusSection(restaurant) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Menu'),
          SizedBox(height: 16.0),

          // Food Menu Section
          _buildMenuSubsection(
            'Food Menu',
            restaurant.menus.foods,
            Icons.restaurant,
          ),

          SizedBox(height: 20.0),

          // Drink Menu Section
          _buildMenuSubsection(
            'Drink Menu',
            restaurant.menus.drinks,
            Icons.local_drink,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSubsection(String title, List items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 20.0),
            SizedBox(width: 8.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 8.0),
        if (items.isEmpty)
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 18.0),
                SizedBox(width: 8.0),
                Text(
                  'No ${title.toLowerCase()} available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerReviewsSection(restaurant) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rate_review, color: Colors.orange, size: 20.0),
              SizedBox(width: 8.0),
              Text(
                'Customer Reviews',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(width: 8.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${restaurant.customerReviews.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Review Submission Form
          Consumer<ReviewSubmissionProvider>(
            builder: (context, reviewProvider, child) {
              return ReviewSubmissionForm(
                restaurantId: restaurant.id,
                onSubmissionSuccess: () {
                  // Refresh restaurant data after successful review submission
                  // Add small delay to ensure server has processed the new review
                  Future.delayed(Duration(milliseconds: 500), () {
                    final detailProvider =
                        Provider.of<RestaurantDetailProvider>(
                      context,
                      listen: false,
                    );
                    detailProvider.refreshAfterReviewSubmission();
                  });
                },
              );
            },
          ),

          // Existing Reviews Section
          if (restaurant.customerReviews.isEmpty)
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20.0),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'No customer reviews available yet.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: restaurant.customerReviews.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final review = restaurant.customerReviews[index];
                return _buildReviewCard(review);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(review) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.0,
                    backgroundColor: Colors.orange,
                    child: Text(
                      review.name.isNotEmpty
                          ? review.name[0].toUpperCase()
                          : '?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    review.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Text(
                _formatReviewDate(review.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 8.0),

          // Review text
          Text(
            review.review,
            style: Theme.of(context).textTheme.bodyMedium,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(String dateString) {
    try {
      // Try to parse the date string
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildErrorState(
      BuildContext context, RestaurantDetailProvider provider) {
    final userFriendlyMessage =
        ErrorHelper.getUserFriendlyMessage(provider.errorMessage);
    final isNetworkError = ErrorHelper.isNetworkError(provider.errorMessage);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
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
                        ? 'Tidak Ada Koneksi Internet'
                        : 'Ups! Terjadi Kesalahan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    userFriendlyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.retry(),
                    icon: Icon(Icons.refresh),
                    label: Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For now, we'll use a simple stateless implementation
    // In a real app, this would connect to a favorites provider
    return IconButton(
      icon: Icon(
        Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: () {
        // TODO: Implement favorite functionality with Provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fitur favorit segera hadir!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

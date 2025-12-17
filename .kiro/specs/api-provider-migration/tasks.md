# Implementation Plan

- [x] 1. Set up API service infrastructure
  - Create ApiService class with HTTP client setup
  - Implement basic error handling and response wrapper
  - Add http dependency to pubspec.yaml
  - _Requirements: 1.1, 3.1, 3.2_

- [x] 2. Create API response models
  - [x] 2.1 Create ApiResponse wrapper class
    - Implement generic ApiResponse class for consistent API response handling
    - Add error, message, and data fields with proper typing
    - _Requirements: 1.2, 3.4_

  - [x] 2.2 Create RestaurantListResponse model
    - Implement RestaurantListResponse class to handle API response structure
    - Add fromJson constructor to parse API response format
    - _Requirements: 4.1, 4.2_

- [x] 3. Update Restaurant model for API compatibility
  - [x] 3.1 Modify Restaurant.fromJson constructor
    - Update parsing logic to handle API response structure vs local JSON
    - Ensure backward compatibility with existing data structure
    - _Requirements: 4.1, 4.2, 4.3_

  - [x] 3.2 Add image URL helper method


    - Create fullImageUrl getter to construct complete image URLs from API
    - Update image loading to use API base URL + pictureId
    - _Requirements: 4.4, 5.3_

- [x] 4. Implement RestaurantProvider for state management




  - [x] 4.1 Create RestaurantProvider class


    - Implement ChangeNotifier with restaurants list, loading, and error states
    - Add getters for accessing state properties
    - _Requirements: 2.1, 2.2_

  - [x] 4.2 Add fetchRestaurants method


    - Implement API call logic with loading state management
    - Handle successful responses and update restaurants list
    - _Requirements: 1.1, 1.2, 2.3_

  - [x] 4.3 Implement error handling in provider


    - Add error state management for network and API errors
    - Implement retry functionality and error clearing methods
    - _Requirements: 1.3, 2.4, 3.1, 3.2, 3.3_

- [x] 5. Update MainScreen to use Provider





  - [x] 5.1 Convert MainScreen to Consumer widget


    - Replace FutureBuilder with Consumer<RestaurantProvider>
    - Access restaurant data through provider instead of local JSON
    - _Requirements: 1.1, 1.2, 2.2, 5.1_

  - [x] 5.2 Implement loading state UI

    - Show CircularProgressIndicator when provider.isLoading is true
    - Maintain existing loading indicator styling
    - _Requirements: 1.4, 5.1_

  - [x] 5.3 Implement error state UI

    - Display error messages when provider.errorMessage is not null
    - Add retry button for failed API calls
    - _Requirements: 1.3, 3.1, 3.2, 3.3_
- [x] 6. Update image loading for API URLs




- [ ] 6. Update image loading for API URLs

  - [x] 6.1 Modify restaurant item image display

    - Update Image.network calls to use restaurant.fullImageUrl
    - Ensure error handling for image loading remains functional
    - _Requirements: 4.4, 5.3_
-

- [x] 7. Remove local JSON dependencies




  - [x] 7.1 Remove local JSON asset loading


    - Remove DefaultAssetBundle.loadString calls from MainScreen
    - Clean up parseRestaurant function if no longer needed
    - _Requirements: 1.1_

  - [x] 7.2 Update pubspec.yaml assets


    - Remove restaurant.json from assets section
    - Verify http dependency is properly configured
    - _Requirements: 1.1_

- [x] 8. Add comprehensive error handling





  - [x] 8.1 Implement network connectivity checks


    - Add proper error messages for no internet connection
    - Handle timeout scenarios with appropriate user feedback
    - _Requirements: 3.1, 3.2_



  - [ ] 8.2 Add retry functionality
    - Implement retry button in error states
    - Add pull-to-refresh functionality for restaurant list
    - _Requirements: 3.3_

- [ ] 9. Write unit tests for core components
  - [ ] 9.1 Expand ApiService tests
    - Add tests for error scenarios and network failures
    - Mock HTTP responses for consistent testing
    - _Requirements: 1.1, 1.2, 1.3_

  - [ ] 9.2 Create RestaurantProvider tests
    - Test state changes during API calls
    - Verify error handling and loading states
    - _Requirements: 2.2, 2.3, 2.4_

  - [ ] 9.3 Create Restaurant model tests
    - Test JSON parsing with API response format
    - Verify image URL construction
    - _Requirements: 4.1, 4.2, 4.4_
 testing and final validation
  - [ ] 10.1 Test complete API integration flow
    - Verify end-to-end functionality from API call to UI display
    - Test error scenarios with actual network conditions
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [ ] 10.2 Validate UI consistency
    - Ensure restaurant list displays identically to previous JSON version
    - Verify navigation to detail screen works with API data
    - Test image loading and error states
    - _Requirements: 5.1, 5.2, 5.3, 5.4_s
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
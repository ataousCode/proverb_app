class AppConstants {
  // Firebase collections
  static const String usersCollection = 'users';
  static const String proverbsCollection = 'proverbs';
  static const String categoriesCollection = 'categories';
  static const String userPrefsCollection = 'userPrefs';
  static const String proverbsSubcollection = 'proverbs';
  
  // Storage paths
  static const String proverbImagesPath = 'proverbs';
  static const String categoryImagesPath = 'categories';
  static const String userImagesPath = 'users';
  
  // Default values
  static const int proverbsPerPage = 10;
  static const String defaultAuthor = 'Unknown';
  static const String defaultCategory = 'General';
  
  // Validation 
  static const int minProverbLength = 5;
  static const int maxProverbLength = 500;
  static const int minAuthorLength = 2;
  static const int maxAuthorLength = 50;
  static const int minCategoryLength = 3;
  static const int maxCategoryLength = 30;
  
  // UI constants
  static const double carouselHeight = 350;
  static const double categoryCardHeight = 100;
  static const double defaultPadding = 16;
  static const double defaultBorderRadius = 12;
  
  // Animation durations
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 250);
}
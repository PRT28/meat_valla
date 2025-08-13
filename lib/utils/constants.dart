class AppConstants {
  // App Info
  static const String appName = 'Meat Valla';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Fresh Meat, Delivered Fresh';
  
  // Contact Info
  static const String supportPhone = '+91 98765 43210';
  static const String supportEmail = 'support@meatvalla.com';
  static const String website = 'www.meatvalla.com';
  static const String address = '123 Business Park, Mumbai, India';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/meatvalla';
  static const String twitterUrl = 'https://twitter.com/meatvalla';
  static const String instagramUrl = 'https://instagram.com/meatvalla';
  
  // Business Rules
  static const double freeDeliveryThreshold = 500.0;
  static const double deliveryFee = 50.0;
  static const int estimatedDeliveryHours = 2;
  
  // Quantity Limits
  static const double minQuantity = 0.25;
  static const double maxQuantity = 10.0;
  static const double quantityStep = 0.25;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String addressesCollection = 'addresses';
  static const String feedbackCollection = 'feedback';
  
  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String authError = 'Authentication failed. Please try again.';
  
  // Success Messages
  static const String orderPlaced = 'Order placed successfully!';
  static const String addressAdded = 'Address added successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String feedbackSent = 'Thank you for your feedback!';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int phoneNumberLength = 10;
  static const int pincodeLength = 6;
  
  // Time Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy • hh:mm a';
}
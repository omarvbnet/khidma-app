class ApiConstants {
  static const String baseUrl = 'https://khidma-app1.vercel.app/api/flutter';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendOTP = '/auth/otp/send';
  static const String verifyOTP = '/auth/otp/verify';
  static const String currentUser = '/auth/current-user';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateUserProfile = '/users/profile';

  // Taxi request endpoints
  static const String createTaxiRequest = '/taxi-requests';
  static const String getTaxiRequests = '/taxi-requests';
  static const String cancelTaxiRequest = '/taxi-requests';
  static const String updateTripStatus = '/taxi-requests';
  static const String trips = '/trips';

  // Driver endpoints
  static const String driverProfile = '/driver/profile';
  static const String updateDriverProfile = '/driver/profile';
  static const String driverTrips = '/driver/trips';
  static const String driverCarInfo = '/driver/car-info';

  // Map configuration
  static const double defaultZoom = 15.0;
  static const double nearbyRadius = 300.0; // meters
  static const double tripDeduction = 500.0; // IQD

  // Location configuration
  static const double defaultLat = 33.3152; // Baghdad
  static const double defaultLng = 44.3661; // Baghdad

  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

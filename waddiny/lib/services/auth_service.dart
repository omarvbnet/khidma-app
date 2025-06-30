import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waddiny/services/location_service.dart';
import 'package:waddiny/services/notification_service.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Helper method to format phone number
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-numeric characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If the number starts with 0, remove it
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If the number starts with 964, remove it to avoid duplication
    if (cleaned.startsWith('964')) {
      cleaned = cleaned.substring(3);
    }

    // Add 964 prefix
    cleaned = '964$cleaned';

    print('Original phone number: $phoneNumber'); // Debug log
    print('Formatted phone number: $cleaned'); // Debug log
    return cleaned;
  }

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Login attempt with phone: $formattedPhone');

      // Get device information
      String? deviceToken;
      String platform = Platform.isIOS ? 'ios' : 'android';
      String appVersion = '1.0.0';

      try {
        deviceToken = await NotificationService.getDeviceToken();
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        print('⚠️ Could not get device information: $e');
      }

      final requestBody = {
        'phoneNumber': formattedPhone,
        'password': password,
      };

      // Add device information if available
      if (deviceToken != null) {
        requestBody['deviceToken'] = deviceToken;
        requestBody['platform'] = platform;
        requestBody['appVersion'] = appVersion;

        print('📱 Device Info:');
        print('- Token: ${deviceToken.substring(0, 20)}...');
        print('- Platform: $platform');
        print('- App Version: $appVersion');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login successful, saving token: ${data['token']}');
        await _saveUserData(data);
        _currentUser = User.fromJson(data['user']);

        // Send device token to server after successful authentication
        await NotificationService.sendDeviceTokenAfterAuth();

        // Get current location and update province
        try {
          final locationService = LocationService();
          final position = await locationService.getCurrentLocation();
          final province = await locationService.getProvinceFromCoordinates(
            position.latitude,
            position.longitude,
          );
          await locationService.updateUserProvince(data['token'], province);
          print('Updated user province to: $province');
        } catch (e) {
          print('Error updating province: $e');
          // Continue even if province update fails
        }

        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Error during login: $e');
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String phoneNumber,
    required String password,
    required String fullName,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Registration attempt with:');
      print('Phone: $formattedPhone');
      print('Full Name: $fullName');
      print('Password length: ${password.length}');

      // Get device information
      String? deviceToken;
      String platform = Platform.isIOS ? 'ios' : 'android';
      String appVersion = '1.0.0';

      try {
        deviceToken = await NotificationService.getDeviceToken();
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        print('⚠️ Could not get device information: $e');
      }

      final requestBody = {
        'phoneNumber': formattedPhone,
        'password': password,
        'fullName': fullName,
        'role': 'USER',
      };

      // Add device information if available
      if (deviceToken != null) {
        requestBody['deviceToken'] = deviceToken;
        requestBody['platform'] = platform;
        requestBody['appVersion'] = appVersion;

        print('📱 Device Info:');
        print('- Token: ${deviceToken.substring(0, 20)}...');
        print('- Platform: $platform');
        print('- App Version: $appVersion');
      }

      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          await _saveUserData(data);
          return data;
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Error during registration: $e');
    }
  }

  Future<Map<String, dynamic>> registerDriver({
    required String phoneNumber,
    required String password,
    required String fullName,
    required String carId,
    required String carType,
    required String licenseId,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      // Get device information
      String? deviceToken;
      String platform = Platform.isIOS ? 'ios' : 'android';
      String appVersion = '1.0.0';

      try {
        deviceToken = await NotificationService.getDeviceToken();
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        print('⚠️ Could not get device information: $e');
      }

      final requestBody = {
        'phoneNumber': formattedPhone,
        'password': password,
        'fullName': fullName,
        'role': 'DRIVER',
        'carId': carId,
        'carType': carType,
        'licenseId': licenseId,
      };

      // Add device information if available
      if (deviceToken != null) {
        requestBody['deviceToken'] = deviceToken;
        requestBody['platform'] = platform;
        requestBody['appVersion'] = appVersion;

        print('📱 Device Info:');
        print('- Token: ${deviceToken.substring(0, 20)}...');
        print('- Platform: $platform');
        print('- App Version: $appVersion');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          await _saveUserData(data);
          return data;
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Driver registration failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Error during driver registration: $e');
    }
  }

  Future<void> logout() async {
    try {
      print('🚪 Logging out user...');

      // Get current token before clearing
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Clear device token from server if we have a token
      if (token != null) {
        try {
          await _clearDeviceTokenFromServer(token);
        } catch (e) {
          print('⚠️ Could not clear device token from server: $e');
          // Continue with logout even if clearing device token fails
        }
      }

      // Clear all local data
      await prefs.clear();
      _currentUser = null;

      print('✅ Logout completed successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      // Still clear local data even if server call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _currentUser = null;
    }
  }

  // Clear device token from server
  Future<void> _clearDeviceTokenFromServer(String token) async {
    try {
      print('🗑️ Clearing device token from server...');

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Device token cleared from server successfully');
      } else {
        print(
            '⚠️ Failed to clear device token from server: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error clearing device token from server: $e');
      throw e;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    print('Saving token: ${data['token']}'); // Debug print
    await prefs.setString('token', data['token']);
    await prefs.setString('userData', json.encode(data['user']));

    // Save user role for notification filtering
    if (data['user'] != null && data['user']['role'] != null) {
      await prefs.setString('user_role', data['user']['role']);
      print('Saved user role: ${data['user']['role']}'); // Debug print
    }

    print('Token saved successfully'); // Debug print
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    print('Getting current user with token: $token'); // Debug print

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/current-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
        'Current user response status: ${response.statusCode}'); // Debug print
    print('Current user response body: ${response.body}'); // Debug print

    if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    }

    final data = await _handleResponse(response);
    _currentUser = User.fromJson(data['user']);
    return data['user'] as Map<String, dynamic>;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved token: $token'); // Debug print
    return token;
  }

  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Sending OTP to: $formattedPhone');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/otp/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'phoneNumber': formattedPhone,
        }),
      );

      print('OTP send response status: ${response.statusCode}');
      print('OTP send response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      print('OTP send error: $e');
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    print('Starting login process...');
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Verifying OTP for: $formattedPhone');

      // Get device information
      String? deviceToken;
      String platform = Platform.isIOS ? 'ios' : 'android';
      String appVersion = '1.0.0';

      try {
        deviceToken = await NotificationService.getDeviceToken();
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        print('⚠️ Could not get device information: $e');
      }

      final requestBody = {
        'phoneNumber': formattedPhone,
        'otp': otp,
      };

      // Add device information if available
      if (deviceToken != null) {
        requestBody['deviceToken'] = deviceToken;
        requestBody['platform'] = platform;
        requestBody['appVersion'] = appVersion;

        print('📱 Device Info:');
        print('- Token: ${deviceToken.substring(0, 20)}...');
        print('- Platform: $platform');
        print('- App Version: $appVersion');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/otp/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        print('Got token: ${token.substring(0, 10)}...');

        await _saveUserData(data);
        print('User data saved successfully');

        // Send device token to server after successful authentication
        await NotificationService.sendDeviceTokenAfterAuth();

        // Get location and update province
        try {
          print('Getting location for province update...');
          final locationService = LocationService();
          final position = await locationService.getCurrentLocation();
          final province = await locationService.getProvinceFromCoordinates(
            position.latitude,
            position.longitude,
          );
          print('Got province: $province');
          await locationService.updateUserProvince(token, province);
          print('Province updated successfully');
        } catch (e) {
          print('Error updating province: $e');
          // Continue with login even if province update fails
        }

        return data;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Failed to login';
        throw Exception(error);
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to handle response: ${response.body}');
    }
  }

  // Update device token, platform, and app version
  Future<void> _updateDeviceInfo(String token) async {
    try {
      print('📱 Updating device information...');

      // Get device token from notification service
      final deviceToken = await NotificationService.getDeviceToken();
      if (deviceToken == null) {
        print('⚠️ No device token available');
        return;
      }

      // Get app version
      String appVersion = '1.0.0';
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        print('⚠️ Could not get app version: $e');
      }

      // Determine platform
      final platform = Platform.isIOS ? 'ios' : 'android';

      // Get user role
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('user_role') ?? 'USER';

      print('📱 Device Info:');
      print('- Token: ${deviceToken.substring(0, 20)}...');
      print('- Platform: $platform');
      print('- App Version: $appVersion');
      print('- User Role: $userRole');

      // Send to server
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'deviceToken': deviceToken,
          'platform': platform,
          'appVersion': appVersion,
          'userRole': userRole, // Include user role for backend filtering
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Device information updated successfully');
        print('👤 Role associated: $userRole');
      } else {
        print('❌ Failed to update device information: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating device information: $e');
      throw e;
    }
  }
}

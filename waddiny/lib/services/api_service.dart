import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/taxi_request_model.dart';
import '../models/driver_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;

  ApiService()
      : _storage = const FlutterSecureStorage(),
        _client = http.Client();

  // Token management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved token: $token'); // Debug print
    return token;
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to perform request: ${response.body}');
    }
  }

  // Auth
  Future<User> login(String phoneNumber, String password) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: ApiConstants.getHeaders(null),
      body: json.encode({'phoneNumber': phoneNumber, 'password': password}),
    );

    final data = await _handleResponse(response);
    await setToken(data['token']);
    return User.fromJson(data['user']);
  }

  // User Profile
  Future<User> getUserProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    print('Getting user profile with token: $token');

    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.currentUser}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Current user response status: ${response.statusCode}');
    print('Current user response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = await _handleResponse(response);
      if (data == null) {
        throw Exception('Invalid response format: response data is null');
      }
      if (!data.containsKey('user')) {
        throw Exception('Invalid response format: missing user data');
      }
      return User.fromJson(data['user']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to load user profile');
    }
  }

  Future<User> updateUserProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateUserProfile}'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(data),
    );

    final responseData = await _handleResponse(response);
    return User.fromJson(responseData);
  }

  // Taxi Requests
  Future<TaxiRequest> createTaxiRequest(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createTaxiRequest}'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(data),
    );

    final responseData = await _handleResponse(response);
    return TaxiRequest.fromJson(responseData);
  }

  Future<List<TaxiRequest>> getTaxiRequests() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getTaxiRequests}'),
        headers: ApiConstants.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> requests = data['requests'];
        return requests.map((json) => TaxiRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load taxi requests');
      }
    } catch (e) {
      throw Exception('Error loading trips: $e');
    }
  }

  Future<void> cancelTaxiRequest(String requestId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.delete(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.cancelTaxiRequest}/$requestId',
      ),
      headers: ApiConstants.getHeaders(token),
    );

    await _handleResponse(response);
  }

  // Driver Profile
  Future<Driver> getDriverProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverProfile}'),
      headers: ApiConstants.getHeaders(token),
    );

    final data = await _handleResponse(response);
    return Driver.fromJson(data);
  }

  Future<Driver> updateDriverProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateDriverProfile}'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(data),
    );

    final responseData = await _handleResponse(response);
    return Driver.fromJson(responseData);
  }

  // Driver Trips
  Future<List<TaxiRequest>> getDriverTrips() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverTrips}'),
      headers: ApiConstants.getHeaders(token),
    );

    final data = await _handleResponse(response);
    return (data['trips'] as List)
        .map((trip) => TaxiRequest.fromJson(trip))
        .toList();
  }

  Future<TaxiRequest> updateTripStatus(String tripId, String status) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print('\n=== UPDATING TRIP STATUS ===');
      print('Trip ID: $tripId');
      print('New Status: $status');
      print('Token: ${token.substring(0, 20)}...');

      // Map the status to the server's enum value
      String serverStatus;
      switch (status.toUpperCase()) {
        case 'USER_WAITING':
          serverStatus = 'USER_WAITING';
          break;
        case 'DRIVER_ACCEPTED':
          serverStatus = 'DRIVER_ACCEPTED';
          break;
        case 'DRIVER_IN_WAY':
          serverStatus = 'DRIVER_IN_WAY';
          break;
        case 'DRIVER_ARRIVED':
          serverStatus = 'DRIVER_ARRIVED';
          break;
        case 'USER_PICKED_UP':
          serverStatus = 'USER_PICKED_UP';
          break;
        case 'DRIVER_IN_PROGRESS':
          serverStatus = 'DRIVER_IN_PROGRESS';
          break;
        case 'DRIVER_ARRIVED_DROPOFF':
          serverStatus = 'DRIVER_ARRIVED_DROPOFF';
          break;
        case 'TRIP_COMPLETED':
          serverStatus = 'TRIP_COMPLETED';
          break;
        case 'TRIP_CANCELLED':
          serverStatus = 'TRIP_CANCELLED';
          break;
        default:
          serverStatus = status;
      }

      print('Mapped status to server value: $serverStatus');

      // Use the driver trips endpoint for status updates with PUT method
      final url = '${ApiConstants.baseUrl}${ApiConstants.driverTrips}';
      print('Sending request to: $url');

      final requestBody = {
        'tripId': tripId,
        'status': serverStatus,
      };
      print('Request body: $requestBody');

      final response = await _client.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = await _handleResponse(response);
        print('✅ Successfully updated trip status');
        return TaxiRequest.fromJson(data);
      } else {
        print('❌ Failed to update trip status');
        print('Status code: ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception('Failed to update trip status: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating trip status: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('SocketException')) {
        print('Network error - check if server is running');
      }
      throw Exception('Failed to update trip status: $e');
    }
  }

  Future<Map<String, dynamic>> getDriverCarInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/driver'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load driver info');
      }
    } catch (e) {
      throw Exception('Error fetching driver info: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserTrips() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getTaxiRequests}'),
        headers: ApiConstants.getHeaders(token),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = await _handleResponse(response);
        final List<dynamic> requests = data['requests'] ?? [];
        return requests.map((trip) {
          print('Trip: $trip');
          // Parse price as double, defaulting to 0.0 if null or invalid
          double price = 0.0;
          if (trip['price'] != null ||
              trip['fare'] != null ||
              trip['tripCost'] != null) {
            if (trip['price'] != null) {
              price = trip['price'] is String
                  ? double.tryParse(trip['price']) ?? 0.0
                  : (trip['price'] as num).toDouble();
            } else if (trip['fare'] != null) {
              price = trip['fare'] is String
                  ? double.tryParse(trip['fare']) ?? 0.0
                  : (trip['fare'] as num).toDouble();
            } else if (trip['tripCost'] != null) {
              price = trip['tripCost'] is String
                  ? double.tryParse(trip['tripCost']) ?? 0.0
                  : (trip['tripCost'] as num).toDouble();
            }
          }

          // Parse distance as double, defaulting to 0.0 if null or invalid
          double distance = 0.0;
          if (trip['distance'] != null) {
            if (trip['distance'] is String) {
              distance = double.tryParse(trip['distance']) ?? 0.0;
            } else if (trip['distance'] is num) {
              distance = (trip['distance'] as num).toDouble();
            }
          }

          // Ensure locations are not null
          String pickupLocation =
              trip['pickupLocation']?.toString() ?? 'Unknown Location';
          String dropoffLocation =
              trip['dropoffLocation']?.toString() ?? 'Unknown Location';

          return {
            'id': trip['id'] ?? '',
            'pickupLocation': pickupLocation,
            'dropoffLocation': dropoffLocation,
            'fare': price,
            'distance': distance,
            'status': trip['status'] ?? 'USER_WAITING',
            'createdAt': trip['createdAt'] != null
                ? DateTime.parse(trip['createdAt'])
                : DateTime.now(),
            'driverId': trip['driverId'],
            'userId': trip['userId'] ?? '',
            'userFullName': trip['userFullName'] ?? '',
            'userPhone': trip['userPhone'] ?? '',
            'userProvince': trip['userProvince'] ?? '',
            'tripType': trip['tripType'] ?? 'ECO',
            'driverDeduction': trip['driverDeduction'] != null
                ? (trip['driverDeduction'] is String
                    ? double.tryParse(trip['driverDeduction']) ?? 0.0
                    : (trip['driverDeduction'] as num).toDouble())
                : 0.0,
            'driverPhone': trip['driverPhone'] ?? '',
            'driverName': trip['driverName'] ?? '',
            'carId': trip['carId'] ?? '',
            'carType': trip['carType'] ?? '',
            'licenseId': trip['licenseId'] ?? '',
            'driverRate': trip['driverRate'] != null
                ? (trip['driverRate'] is String
                    ? double.tryParse(trip['driverRate']) ?? 0.0
                    : (trip['driverRate'] as num).toDouble())
                : 0.0,
          };
        }).toList();
      } else {
        throw Exception('Failed to load trips: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user trips: $e');
      throw Exception('Error fetching user trips: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentTrip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/trips/current'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {};
      } else {
        throw Exception('Failed to load current trip');
      }
    } catch (e) {
      throw Exception('Error fetching current trip: $e');
    }
  }

  Future<TaxiRequest> createTrip(TaxiRequest trip) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      // Ensure all required fields are present and non-null
      if (trip.pickupLocation.isEmpty ||
          trip.dropoffLocation.isEmpty ||
          trip.userPhone.isEmpty ||
          trip.userFullName.isEmpty) {
        throw Exception(
            'Missing required fields: pickupLocation, dropoffLocation, userPhone, or userFullName');
      }

      final requestBody = {
        'pickupLocation': trip.pickupLocation,
        'dropoffLocation': trip.dropoffLocation,
        'pickupLat': trip.pickupLat,
        'pickupLng': trip.pickupLng,
        'dropoffLat': trip.dropoffLat,
        'dropoffLng': trip.dropoffLng,
        'price': trip.price,
        'distance': trip.distance,
        'status': 'USER_WAITING',
        'tripType': trip.tripType,
        'driverDeduction': trip.driverDeduction,
        'userId': trip.userId,
        'userFullName': trip.userFullName,
        'userPhone': trip.userPhone,
        'userProvince': trip.userProvince,
      };

      print(
          'Sending request to: ${ApiConstants.baseUrl}${ApiConstants.createTaxiRequest}');
      print('Request body: ${json.encode(requestBody)}');

      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createTaxiRequest}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      final responseData = await _handleResponse(response);
      return TaxiRequest.fromJson(responseData);
    } catch (e) {
      print('Error creating trip: $e');
      throw Exception('Failed to create trip: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

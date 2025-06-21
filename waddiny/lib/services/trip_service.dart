import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waddiny/constants/api_constants.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart';
import '../models/driver_model.dart';
import '../services/auth_service.dart';

class TripService {
  static const Duration _timeout = Duration(seconds: 10);
  final AuthService _authService = AuthService();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<User?> checkUserStatus() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/current-user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        return User.fromJson(data);
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to fetch user status';
        throw Exception(error);
      }
    } catch (e) {
      print('Error in checkUserStatus: $e'); // Debug log
      throw Exception('Error checking user status: $e');
    }
  }

  Future<List<Trip>> getPendingTrips() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/trips/pending'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Trip.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pending trips');
      }
    } catch (e) {
      throw Exception('Error fetching pending trips: $e');
    }
  }

  Future<List<Trip>> getUserTrips(String userId) async {
    try {
      print('\n=== GETTING USER TRIPS ===');
      print('User ID: $userId');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/taxi-requests'),
        headers: await _getHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('\nResponse data keys: ${responseData.keys.toList()}');

        // Check if the response has a 'requests' field containing the trips
        final List<dynamic> data = responseData['requests'] ?? [];
        print('\nParsed ${data.length} trips');

        // Filter trips for the current user and active status
        final trips = data.map((trip) {
          print('\nProcessing trip:');
          print('- ID: ${trip['id']}');
          print('- Status: ${trip['status']}');
          print('- User ID: ${trip['userId']}');
          print('- Driver ID: ${trip['driverId']}');

          // Normalize status
          String status = trip['status']?.toString().toUpperCase() ?? 'WAITING';
          status = status.replaceAll(' ', '_');

          // Map old status to new status
          switch (status) {
            case 'WAITING':
              status = 'USER_WAITING';
              break;
            case 'ACCEPTED':
              status = 'DRIVER_ACCEPTED';
              break;
            case 'IN_WAY':
              status = 'DRIVER_IN_WAY';
              break;
            case 'ARRIVED':
              status = 'DRIVER_ARRIVED';
              break;
            case 'PICKED_UP':
              status = 'USER_PICKED_UP';
              break;
            case 'IN_PROGRESS':
              status = 'DRIVER_IN_PROGRESS';
              break;
            case 'ARRIVED_DROPOFF':
              status = 'DRIVER_ARRIVED_DROPOFF';
              break;
            case 'COMPLETED':
              status = 'TRIP_COMPLETED';
              break;
            case 'CANCELLED':
              status = 'TRIP_CANCELLED';
              break;
          }

          // Create a new trip object with normalized status
          final Map<String, dynamic> tripData = {
            ...trip as Map<String, dynamic>,
            'status': status,
          };

          return Trip.fromJson(tripData);
        }).where((trip) {
          final isUserTrip = trip.userId == userId;
          final isActive = [
            'USER_WAITING',
            'DRIVER_ACCEPTED',
            'DRIVER_IN_WAY',
            'DRIVER_ARRIVED',
            'USER_PICKED_UP',
            'DRIVER_IN_PROGRESS',
            'DRIVER_ARRIVED_DROPOFF'
          ].contains(trip.status.toUpperCase());

          print('\nChecking trip ${trip.id}:');
          print('- Is user trip: $isUserTrip');
          print('- Is active: $isActive');
          print('- Status: ${trip.status}');

          return isUserTrip && isActive;
        }).toList();

        print('\nFiltered ${trips.length} active trips for user $userId');
        for (var trip in trips) {
          print('\nActive trip:');
          print('- ID: ${trip.id}');
          print('- Status: ${trip.status}');
          print('- Driver ID: ${trip.driverId}');
          print('- Pickup: (${trip.pickupLat}, ${trip.pickupLng})');
          print('- Dropoff: (${trip.dropoffLat}, ${trip.dropoffLng})');
        }

        return trips;
      } else {
        throw Exception('Failed to load trips: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user trips: $e');
      throw Exception('Error fetching user trips: $e');
    }
  }

  Future<List<Trip>> getDriverTrips(String driverId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('\n=== DRIVER TRIPS DEBUG ===');
      print('Driver ID: $driverId');

      final url = '${ApiConstants.baseUrl}${ApiConstants.driverTrips}';
      print('Request URL: $url');
      print('Request Headers: ${ApiConstants.getHeaders(token)}');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.getHeaders(token),
      );

      print('\nResponse Status: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('\nDecoded Data Keys: ${data.keys.toList()}');

        if (!data.containsKey('trips')) {
          print('No trips array in response');
          print('Available keys: ${data.keys.toList()}');
          return [];
        }

        final List<dynamic> trips = data['trips'];
        print('\nNumber of trips found: ${trips.length}');

        if (trips.isEmpty) {
          print('No trips found');
          return [];
        }

        final List<Trip> parsedTrips = trips.map((json) {
          print('\nProcessing trip:');
          print('Trip ID: ${json['id']}');
          print('Trip Status: ${json['status']}');
          print('Driver ID from API: ${json['driverId']}');
          print('Driver object from API: ${json['driver']}');

          // Ensure driver ID is set
          if (json['driverId'] == null) {
            print('Adding driver ID to trip data');
            json['driverId'] = driverId;
          }

          final trip = Trip.fromJson(json);
          print('Parsed Trip:');
          print('- ID: ${trip.id}');
          print('- Status: ${trip.status}');
          print('- Driver ID: ${trip.driverId}');
          return trip;
        }).toList();

        print('\nFinal parsed trips:');
        for (var trip in parsedTrips) {
          print('Trip ${trip.id}:');
          print('- Status: ${trip.status}');
          print('- Driver ID: ${trip.driverId}');
        }

        return parsedTrips;
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to load driver trips: ${response.body}');
      }
    } catch (e) {
      print('Error in getDriverTrips: $e');
      throw Exception('Error fetching driver trips: $e');
    }
  }

  Future<Trip> createTrip(Map<String, dynamic> tripData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('\n=== CREATING TRIP ===');
      print('Trip data:');
      print('- Pickup location: ${tripData['pickupLocation']}');
      print('- Dropoff location: ${tripData['dropoffLocation']}');
      print(
          '- Pickup coordinates: (${tripData['pickupLat']}, ${tripData['pickupLng']})');
      print(
          '- Dropoff coordinates: (${tripData['dropoffLat']}, ${tripData['dropoffLng']})');
      print('- Price: ${tripData['price']}');
      print('- Distance: ${tripData['distance']}');

      final requestBody = {
        'pickupLocation': tripData['pickupLocation'],
        'dropoffLocation': tripData['dropoffLocation'],
        'pickupLat': tripData['pickupLat'],
        'pickupLng': tripData['pickupLng'],
        'dropoffLat': tripData['dropoffLat'],
        'dropoffLng': tripData['dropoffLng'],
        'price': tripData['price'],
        'distance': tripData['distance'],
        'status': 'USER_WAITING',
        'tripType': tripData['tripType'] ?? 'ECO',
        'driverDeduction': tripData['driverDeduction'],
        'userId': tripData['userId'],
        'userFullName': tripData['userFullName'],
        'userPhone': tripData['userPhone'],
        'userProvince': tripData['userProvince'],
      };

      print('\nRequest body:');
      print('- Pickup: ${requestBody['pickupLocation']}');
      print('- Destination: ${requestBody['dropoffLocation']}');
      print(
          '- Pickup coordinates: (${requestBody['pickupLat']}, ${requestBody['pickupLng']})');
      print(
          '- Dropoff coordinates: (${requestBody['dropoffLat']}, ${requestBody['dropoffLng']})');

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/taxi-requests'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      print('\nResponse status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('\nParsed response data:');
        print('- ID: ${data['id']}');
        print('- Status: ${data['status']}');
        print(
            '- Pickup coordinates: (${data['pickupLat']}, ${data['pickupLng']})');
        print(
            '- Dropoff coordinates: (${data['dropoffLat']}, ${data['dropoffLng']})');

        final trip = Trip.fromJson(data);
        print('\nCreated Trip object:');
        print('- ID: ${trip.id}');
        print('- Status: ${trip.status}');
        print('- Pickup coordinates: (${trip.pickupLat}, ${trip.pickupLng})');
        print(
            '- Dropoff coordinates: (${trip.dropoffLat}, ${trip.dropoffLng})');

        return trip;
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to create trip';
        throw Exception(error);
      }
    } catch (e) {
      print('Error in createTrip: $e');
      throw Exception('Error creating trip: $e');
    }
  }

  Future<Trip> acceptTrip(String tripId, String driverId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/trips/$tripId/accept'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'driverId': driverId}),
      );

      if (response.statusCode == 200) {
        return Trip.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to accept trip');
      }
    } catch (e) {
      throw Exception('Error accepting trip: $e');
    }
  }

  Future<Trip> updateTripStatus(String tripId, String newStatus) async {
    try {
      final trips = await getUserTrips(_authService.currentUser!.id);
      final trip = trips.firstWhere((trip) => trip.id == tripId);
      trip.status = newStatus;
      return trip;
    } catch (e) {
      print('Error updating trip status: $e');
      rethrow;
    }
  }

  Future<void> updateTripStatusWithLocation(
    String tripId,
    double latitude,
    double longitude,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/trips/$tripId/update-location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverLocation': {'latitude': latitude, 'longitude': longitude},
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update trip location');
      }
    } catch (e) {
      print('Error updating trip status with location: $e');
      rethrow;
    }
  }

  Future<void> updateTripStatusWithLocationAndDistance(
    String tripId,
    double latitude,
    double longitude,
    double distance,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/trips/$tripId/update-location-distance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverLocation': {'latitude': latitude, 'longitude': longitude},
          'distance': distance,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update trip location and distance');
      }
    } catch (e) {
      print('Error updating trip status with location and distance: $e');
      rethrow;
    }
  }

  Future<void> updateTripStatusWithLocationAndDistanceAndFare(
    String tripId,
    double latitude,
    double longitude,
    double distance,
    double fare,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/trips/$tripId/update-location-distance-fare'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverLocation': {'latitude': latitude, 'longitude': longitude},
          'distance': distance,
          'fare': fare,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update trip location, distance and fare');
      }
    } catch (e) {
      print('Error updating trip status with location, distance and fare: $e');
      rethrow;
    }
  }

  Future<void> updateTripStatusWithLocationAndDistanceAndFareAndDuration(
    String tripId,
    double latitude,
    double longitude,
    double distance,
    double fare,
    int duration,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/trips/$tripId/update-location-distance-fare-duration'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverLocation': {'latitude': latitude, 'longitude': longitude},
          'distance': distance,
          'fare': fare,
          'duration': duration,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update trip location, distance, fare and duration');
      }
    } catch (e) {
      print(
          'Error updating trip status with location, distance, fare and duration: $e');
      rethrow;
    }
  }

  Future<void>
      updateTripStatusWithLocationAndDistanceAndFareAndDurationAndRating(
    String tripId,
    double latitude,
    double longitude,
    double distance,
    double fare,
    int duration,
    double rating,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/trips/$tripId/update-location-distance-fare-duration-rating'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverLocation': {'latitude': latitude, 'longitude': longitude},
          'distance': distance,
          'fare': fare,
          'duration': duration,
          'rating': rating,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update trip location, distance, fare, duration and rating');
      }
    } catch (e) {
      print(
          'Error updating trip status with location, distance, fare, duration and rating: $e');
      rethrow;
    }
  }

  Future<void>
      updateTripStatusWithLocationAndDistanceAndFareAndDurationAndRatingAndReview(
    String tripId,
    double latitude,
    double longitude,
    double distance,
    double fare,
    int duration,
    double rating,
    String review,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/trips/$tripId/update-location-distance-fare-duration-rating-review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverLocation': {'latitude': latitude, 'longitude': longitude},
          'distance': distance,
          'fare': fare,
          'duration': duration,
          'rating': rating,
          'review': review,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update trip location, distance, fare, duration, rating and review');
      }
    } catch (e) {
      print(
          'Error updating trip status with location, distance, fare, duration, rating and review: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getWaitingTrip() async {
    try {
      print('\n=== GETTING WAITING TRIP ===');

      if (_authService.currentUser == null) {
        print('No current user found');
        return null;
      }

      final trips = await getUserTrips(_authService.currentUser!.id);
      print('Found ${trips.length} trips');

      final waitingTrips =
          trips.where((trip) => trip.status == 'USER_WAITING').toList();
      if (waitingTrips.isEmpty) {
        print('No waiting trip found');
        return null;
      }

      final waitingTrip = waitingTrips.first;
      print('Found waiting trip:');
      print('- ID: ${waitingTrip.id}');
      print('- Status: ${waitingTrip.status}');
      print('- Price: ${waitingTrip.fare}');
      print('- Distance: ${waitingTrip.distance}');

      final tripData = waitingTrip.toJson();
      print('\nTrip data:');
      print(tripData);

      return tripData;
    } catch (e) {
      print('Error getting waiting trip: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    try {
      print('\n=== GETTING TRIP BY ID ===');
      print('Trip ID: $tripId');

      final trips = await getUserTrips(_authService.currentUser!.id);
      print('Found ${trips.length} trips for user');

      // Find the trip with the given ID
      Trip? foundTrip;
      for (final trip in trips) {
        if (trip.id == tripId) {
          foundTrip = trip;
          break;
        }
      }

      if (foundTrip == null) {
        print('Trip with ID $tripId not found');
        return null;
      }

      print('Found trip:');
      print('- ID: ${foundTrip.id}');
      print('- Status: ${foundTrip.status}');
      print('- Driver ID: ${foundTrip.driverId}');

      return foundTrip.toJson();
    } catch (e) {
      print('Error getting trip by ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDriverTripsWithAuth() async {
    try {
      final trips = await getUserTrips(_authService.currentUser!.id);
      return trips.map((trip) => trip.toJson()).toList();
    } catch (e) {
      print('Error getting driver trips: $e');
      return [];
    }
  }

  Future<User> getDriverProfile() async {
    try {
      final user = await checkUserStatus();
      if (user == null) {
        throw Exception('User not found');
      }
      return user;
    } catch (e) {
      print('Error getting driver profile: $e');
      rethrow;
    }
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('\n=== CANCELLING TRIP ===');
      print('Trip ID: $tripId');

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/taxi-requests/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'TRIP_CANCELLED',
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Trip cancelled successfully');
        return;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Failed to cancel trip';
        print('Error cancelling trip: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error cancelling trip: $e');
      rethrow;
    }
  }
}

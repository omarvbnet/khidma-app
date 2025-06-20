import 'package:geolocator/geolocator.dart';
import '../models/driver_model.dart';
import '../models/taxi_request_model.dart';
import 'api_service.dart';

class DriverService {
  final ApiService _apiService;

  DriverService(this._apiService);

  Future<Driver> getDriverProfile() async {
    return await _apiService.getDriverProfile();
  }

  Future<Driver> updateDriverProfile(Map<String, dynamic> data) async {
    return await _apiService.updateDriverProfile(data);
  }

  Future<List<TaxiRequest>> getWaitingTrips() async {
    final trips = await _apiService.getDriverTrips();
    return trips.where((trip) => trip.status == 'USER_WAITING').toList();
  }

  Future<List<TaxiRequest>> getTripHistory() async {
    final trips = await _apiService.getDriverTrips();
    return trips.where((trip) => trip.status != 'USER_WAITING').toList();
  }

  Future<TaxiRequest> acceptTrip(String tripId) async {
    return await _apiService.updateTripStatus(tripId, 'DRIVER_ACCEPTED');
  }

  Future<TaxiRequest> startTrip(String tripId) async {
    // Get current trip status first
    final trips = await _apiService.getDriverTrips();
    final currentTrip = trips.firstWhere((trip) => trip.id == tripId);

    // Only update if current status is DRIVER_ACCEPTED
    if (currentTrip.status == 'DRIVER_ACCEPTED') {
      return await _apiService.updateTripStatus(tripId, 'DRIVER_IN_WAY');
    } else {
      throw Exception(
          'Cannot start trip: Current status is ${currentTrip.status}. Trip must be in DRIVER_ACCEPTED status.');
    }
  }

  Future<TaxiRequest> completeTrip(String tripId) async {
    // Get current trip status first
    final trips = await _apiService.getDriverTrips();
    final currentTrip = trips.firstWhere((trip) => trip.id == tripId);

    try {
      // Follow proper status flow - only use the 7 valid statuses
      if (currentTrip.status == 'DRIVER_IN_WAY') {
        // First update to DRIVER_ARRIVED
        await _apiService.updateTripStatus(tripId, 'DRIVER_ARRIVED');
        // Then to USER_PICKED_UP
        await _apiService.updateTripStatus(tripId, 'USER_PICKED_UP');
        // Then to DRIVER_IN_PROGRESS
        await _apiService.updateTripStatus(tripId, 'DRIVER_IN_PROGRESS');
        // Finally to TRIP_COMPLETED
        return await _apiService.updateTripStatus(tripId, 'TRIP_COMPLETED');
      } else if (currentTrip.status == 'DRIVER_ARRIVED') {
        // Continue from DRIVER_ARRIVED
        await _apiService.updateTripStatus(tripId, 'USER_PICKED_UP');
        await _apiService.updateTripStatus(tripId, 'DRIVER_IN_PROGRESS');
        return await _apiService.updateTripStatus(tripId, 'TRIP_COMPLETED');
      } else if (currentTrip.status == 'USER_PICKED_UP') {
        // Continue from USER_PICKED_UP
        await _apiService.updateTripStatus(tripId, 'DRIVER_IN_PROGRESS');
        return await _apiService.updateTripStatus(tripId, 'TRIP_COMPLETED');
      } else if (currentTrip.status == 'DRIVER_IN_PROGRESS') {
        // Can directly complete from DRIVER_IN_PROGRESS
        return await _apiService.updateTripStatus(tripId, 'TRIP_COMPLETED');
      } else {
        throw Exception(
            'Cannot complete trip: Current status is ${currentTrip.status}. Trip must be in DRIVER_IN_WAY, DRIVER_ARRIVED, USER_PICKED_UP, or DRIVER_IN_PROGRESS status.');
      }
    } catch (e) {
      print('Error in status transition: $e');
      throw Exception('Failed to complete trip: $e');
    }
  }

  Future<TaxiRequest> cancelTrip(String tripId) async {
    // Cancel the trip by updating status to TRIP_CANCELLED
    return await _apiService.updateTripStatus(tripId, 'TRIP_CANCELLED');
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  bool isNearPickupLocation(
    double driverLat,
    double driverLng,
    double pickupLat,
    double pickupLng,
  ) {
    final distance = calculateDistance(
      driverLat,
      driverLng,
      pickupLat,
      pickupLng,
    );
    return distance <= 300; // 300 meters
  }
}

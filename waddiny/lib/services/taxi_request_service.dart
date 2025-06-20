import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/taxi_request_model.dart';
import 'api_service.dart';

class TaxiRequestService {
  final ApiService _apiService;

  TaxiRequestService(this._apiService);

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

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  Future<TaxiRequest> createRequest({
    required double pickupLat,
    required double pickupLng,
    required double destinationLat,
    required double destinationLng,
    required String tripType,
    required DateTime tripTime,
  }) async {
    final pickupAddress = await getAddressFromCoordinates(pickupLat, pickupLng);
    final destinationAddress = await getAddressFromCoordinates(
      destinationLat,
      destinationLng,
    );

    final data = {
      'pickup': pickupAddress,
      'destination': destinationAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'tripType': tripType,
      'tripTime': tripTime.toIso8601String(),
      'paymentStatus': 'PENDING',
    };

    return await _apiService.createTaxiRequest(data);
  }

  Future<List<TaxiRequest>> getWaitingRequests() async {
    final requests = await _apiService.getTaxiRequests();
    return requests
        .where((request) => request.status == 'USER_WAITING')
        .toList();
  }

  Future<List<TaxiRequest>> getUserRequests() async {
    return await _apiService.getTaxiRequests();
  }

  Future<void> cancelRequest(String requestId) async {
    await _apiService.cancelTaxiRequest(requestId);
  }

  Future<List<TaxiRequest>> getDriverTrips() async {
    return await _apiService.getDriverTrips();
  }

  Future<TaxiRequest> updateTripStatus(String tripId, String status) async {
    return await _apiService.updateTripStatus(tripId, status);
  }

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  bool isDriverNearby(
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

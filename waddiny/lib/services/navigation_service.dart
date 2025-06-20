import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NavigationService {
  final Function(LatLng) onLocationUpdate;
  final Function(double) onHeadingUpdate;
  final Function(double) onSpeedUpdate;
  Timer? _locationTimer;
  Timer? _headingTimer;
  StreamSubscription<Position>? _positionStream;

  NavigationService({
    required this.onLocationUpdate,
    required this.onHeadingUpdate,
    required this.onSpeedUpdate,
  });

  void startNavigation(LatLng destination) {
    // Start location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      final location = LatLng(position.latitude, position.longitude);
      onLocationUpdate(location);
      onSpeedUpdate(position.speed);
    });

    // Start heading updates
    _headingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      Geolocator.getLastKnownPosition().then((position) {
        if (position != null) {
          onHeadingUpdate(position.heading);
        }
      });
    });
  }

  void dispose() {
    _locationTimer?.cancel();
    _headingTimer?.cancel();
    _positionStream?.cancel();
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/map_service.dart';
import '../services/navigation_service.dart';
import '../services/location_service.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/api_service.dart';

class DriverNavigationScreen extends StatefulWidget {
  final Trip trip;
  final bool isPickup;
  final Function(String) onTripStatusChanged;

  const DriverNavigationScreen({
    Key? key,
    required this.trip,
    required this.isPickup,
    required this.onTripStatusChanged,
  }) : super(key: key);

  @override
  _DriverNavigationScreenState createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final _tripService = TripService();
  final _mapService = MapService();
  final _locationService = LocationService();
  final _apiService = ApiService();
  LatLng? _currentLocation;
  double _currentHeading = 0;
  double _currentSpeed = 0;
  double _distanceToDestination = 0;
  String _estimatedTime = '';
  bool _isLoading = true;
  BitmapDescriptor? _carIcon;
  String _currentAddress = '';
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  double _deviceHeading = 0;
  bool _isUpdating = false;
  bool _showArrivedButton = false;
  bool _showPickupButton = false;
  Timer? _autoProgressTimer;
  String? _error;
  late String _status; // current status

  @override
  void initState() {
    super.initState();
    _status = widget.trip.status;
    print('Initializing DriverNavigationScreen');
    // Create car icon before initializing map
    _createCarIcon().then((_) {
      print('Car icon created, initializing map');
      _initializeMap();
    }).catchError((error) {
      print('Error in initState: $error');
      // Initialize map even if car icon fails
      _initializeMap();
    });
    _startMagnetometerUpdates();
    // Auto-switch to DRIVER_IN_PROGRESS 30s after pickup
    if (widget.trip.status == 'USER_PICKED_UP') {
      _autoProgressTimer = Timer(const Duration(seconds: 30), () {
        _updateTripStatus('DRIVER_IN_PROGRESS');
      });
    }
  }

  Future<Uint8List> _resizeImage(String assetPath, int targetWidth) async {
    try {
      // Load the image from assets
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Decode the image
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new height maintaining aspect ratio
      final double aspectRatio = image.width / image.height;
      final int targetHeight = (targetWidth / aspectRatio).round();

      // Resize the image with better quality
      final img.Image resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img
            .Interpolation.cubic, // Use cubic interpolation for better quality
      );

      // Encode the resized image with maximum quality
      final Uint8List resizedBytes =
          Uint8List.fromList(img.encodePng(resized, level: 9));
      return resizedBytes;
    } catch (e) {
      print('Error resizing image: $e');
      rethrow;
    }
  }

  Future<void> _createCarIcon() async {
    try {
      print('Starting to load car marker...');

      // Resize the image to 144x144 pixels for better visibility
      final Uint8List resizedImage =
          await _resizeImage('assets/images/car_marker.png', 144);

      // Create bitmap descriptor from resized image
      _carIcon = BitmapDescriptor.fromBytes(resizedImage);
      print('Car marker loaded successfully');
    } catch (e, stackTrace) {
      print('Error loading car marker: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default marker if image loading fails
      _carIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      print('Using fallback blue marker');
    }
  }

  void _startMagnetometerUpdates() {
    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
      // Calculate heading from magnetometer data
      double heading = atan2(event.y, event.x) * (180 / pi);
      // Convert to 0-360 range
      heading = (heading + 360) % 360;

      if (_deviceHeading != heading) {
        setState(() {
          _deviceHeading = heading;
        });
        // Update both camera and marker with the new heading
        _updateCameraRotation(heading);
        if (_currentLocation != null) {
          _updateMarkers();
        }
      }
    });
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    setState(() {
      _markers = {
        // Current location marker (car)
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: _currentHeading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
        // Pickup marker
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
        ),
        // Dropoff marker
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Dropoff Location'),
        ),
      };
    });
  }

  void _updateCameraRotation(double heading) {
    if (_mapController.future != null && _currentLocation != null) {
      _mapController.future.then((controller) {
        // Calculate the camera position based on the heading
        final double offset = 0.0002;
        final double headingRadians = heading * (pi / 180);
        final double newLat =
            _currentLocation!.latitude + (offset * cos(headingRadians));
        final double newLng =
            _currentLocation!.longitude + (offset * sin(headingRadians));

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(newLat, newLng),
              zoom: 18,
              bearing: heading, // Use device heading directly
              tilt: 60,
            ),
          ),
        );
      });
    }
  }

  void _updateLocation(LatLng location) {
    setState(() {
      _currentLocation = location;
    });
    _updateMarkers();
    _checkDistance();
  }

  void _updateHeading(double heading) {
    setState(() {
      _currentHeading = heading;
      // Update car marker rotation
      _markers = {
        ..._markers.where((m) => m.markerId.value != 'current'),
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: heading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      };
    });

    // Update camera bearing to match car heading
    if (_mapController.future != null && _currentLocation != null) {
      _mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 18,
              bearing: heading,
              tilt: 60,
            ),
          ),
        );
      });
    }
  }

  void _updateSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
    });
  }

  Future<void> _updateTripStatus(String newStatus) async {
    try {
      setState(() {
        _isUpdating = true;
      });

      print('\n=== UPDATING TRIP STATUS ===');
      print('Trip ID: ${widget.trip.id}');
      print('Current Status: ${widget.trip.status}');
      print('New Status: $newStatus');

      // Validate status transition using current trip status
      bool isValidTransition = false;
      switch (widget.trip.status.toUpperCase()) {
        case 'USER_WAITING':
          isValidTransition = newStatus == 'DRIVER_ACCEPTED';
          break;
        case 'DRIVER_ACCEPTED':
          isValidTransition = newStatus == 'DRIVER_IN_WAY';
          break;
        case 'DRIVER_IN_WAY':
          isValidTransition = newStatus == 'DRIVER_ARRIVED';
          break;
        case 'DRIVER_ARRIVED':
          isValidTransition = newStatus == 'USER_PICKED_UP';
          break;
        case 'USER_PICKED_UP':
          isValidTransition = newStatus == 'DRIVER_IN_PROGRESS';
          break;
        case 'DRIVER_IN_PROGRESS':
          isValidTransition = newStatus == 'TRIP_COMPLETED';
          break;
        default:
          isValidTransition = false;
      }

      if (!isValidTransition) {
        throw Exception(
            'Invalid status transition from ${widget.trip.status} to $newStatus');
      }

      final updatedTaxiRequest =
          await _apiService.updateTripStatus(widget.trip.id, newStatus);
      final updatedTrip = Trip.fromJson(updatedTaxiRequest.toJson());

      if (mounted) {
        setState(() {
          _isUpdating = false;
          _status = updatedTrip.status;
          widget.trip.status = updatedTrip.status; // Update the trip status
          if (widget.trip.status == 'DRIVER_ARRIVED') {
            _showPickupButton = true;
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip ${newStatus.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home screen if trip is completed
        if (newStatus == 'TRIP_COMPLETED') {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('Error updating trip status: $e');
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStatusText(widget.trip.status)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.isPickup
                  ? LatLng(widget.trip.pickupLat, widget.trip.pickupLng)
                  : LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
              zoom: 18,
              tilt: 60,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController.complete(controller),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            onCameraMove: (CameraPosition position) {
              if (position.bearing != _currentHeading) {
                setState(() {
                  _currentHeading = position.bearing;
                });
              }
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_distanceToDestination <= 0.05 && widget.isPickup)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                            'Distance',
                            '${widget.trip.distance.toStringAsFixed(1)} km',
                            Icons.route,
                            Colors.blue,
                          ),
                          _buildInfoColumn(
                            'Time',
                            _calculateTripDuration(),
                            Icons.timer,
                            Colors.orange,
                          ),
                          _buildInfoColumn(
                            'Speed',
                            '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                            Icons.speed,
                            Colors.green,
                          ),
                          _buildInfoColumn(
                            'Fare',
                            '${widget.trip.fare} IQD',
                            Icons.attach_money,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.trip.status == 'DRIVER_IN_PROGRESS')
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(
                        'Speed',
                        '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                        Icons.speed,
                        Colors.green,
                      ),
                      _buildInfoColumn(
                        'Time',
                        _estimatedTime,
                        Icons.timer,
                        Colors.orange,
                      ),
                      _buildInfoColumn(
                        'Distance',
                        '${_distanceToDestination.toStringAsFixed(1)} km',
                        Icons.route,
                        Colors.blue,
                      ),
                      _buildInfoColumn(
                        'Fare',
                        '${widget.trip.fare} IQD',
                        Icons.attach_money,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _buildStatusButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusButtons() {
    if (!_showArrivedButton && !_showPickupButton)
      return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showPickupButton) ...[
                Text(
                  'User picked up?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoChip(Icons.speed,
                        '${_currentSpeed.toStringAsFixed(1)} km/h'),
                    _infoChip(Icons.timer, _estimatedTime),
                    _infoChip(Icons.directions_car,
                        '${_distanceToDestination.toStringAsFixed(1)} km'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUpdating ? null : _onPickupPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Confirm Picked Up'),
                ),
              ] else ...[
                Text(
                  'You have arrived at your destination!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateTripStatus('TRIP_COMPLETED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Complete Trip'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'USER_WAITING':
        return Colors.orange;
      case 'DRIVER_ACCEPTED':
        return Colors.blue;
      case 'DRIVER_IN_WAY':
        return Colors.purple;
      case 'DRIVER_ARRIVED':
        return Colors.green;
      case 'USER_PICKED_UP':
        return Colors.teal;
      case 'DRIVER_IN_PROGRESS':
        return Colors.indigo;
      case 'TRIP_COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'USER_WAITING':
        return 'Waiting for Driver';
      case 'DRIVER_ACCEPTED':
        return 'Driver Accepted';
      case 'DRIVER_IN_WAY':
        return 'Driver is on the way';
      case 'DRIVER_ARRIVED':
        return 'Driver has arrived';
      case 'USER_PICKED_UP':
        return 'You are picked up';
      case 'DRIVER_IN_PROGRESS':
        return 'On the way to destination';
      case 'TRIP_COMPLETED':
        return 'Trip completed';
      default:
        return 'Unknown status';
    }
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    _locationService.dispose();
    _autoProgressTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      print('Initializing map...');

      // Validate trip coordinates before proceeding
      if (!_validateTripCoordinates()) {
        throw Exception('Invalid trip coordinates detected');
      }

      // Get current location
      final position = await _locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);
      print(
          'Current location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');

      // Set up markers
      _setupMarkers();

      // Get route details
      await _getRouteDetails();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing map: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing map: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateTripCoordinates() {
    try {
      // Validate pickup coordinates
      if (widget.isPickup) {
        if (!_isValidCoordinate(
            LatLng(widget.trip.pickupLat, widget.trip.pickupLng))) {
          print(
              'Invalid pickup coordinates: ${widget.trip.pickupLat}, ${widget.trip.pickupLng}');
          return false;
        }
      } else {
        // Validate dropoff coordinates
        if (!_isValidCoordinate(
            LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng))) {
          print(
              'Invalid dropoff coordinates: ${widget.trip.dropoffLat}, ${widget.trip.dropoffLng}');
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error validating coordinates: $e');
      return false;
    }
  }

  bool _isValidCoordinate(LatLng coordinate) {
    // Check for null coordinates
    if (coordinate == null) {
      return false;
    }

    // Check for NaN values
    if (coordinate.latitude.isNaN ||
        coordinate.longitude.isNaN ||
        coordinate.latitude.isInfinite ||
        coordinate.longitude.isInfinite) {
      return false;
    }

    // Check for zero coordinates (common invalid value)
    if (coordinate.latitude == 0.0 && coordinate.longitude == 0.0) {
      return false;
    }

    // Check if coordinates are within valid ranges
    if (coordinate.latitude < -90 ||
        coordinate.latitude > 90 ||
        coordinate.longitude < -180 ||
        coordinate.longitude > 180) {
      return false;
    }

    return true;
  }

  void _setupMarkers() {
    final markers = <Marker>{};

    // Add pickup marker
    if (widget.isPickup) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup Location'),
      ));
    }

    // Add dropoff marker
    markers.add(Marker(
      markerId: const MarkerId('dropoff'),
      position: LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: 'Dropoff Location'),
    ));

    // Add car marker if we have current location
    if (_currentLocation != null && _carIcon != null) {
      markers.add(Marker(
        markerId: const MarkerId('car'),
        position: _currentLocation!,
        icon: _carIcon!,
        rotation: _currentHeading,
        flat: true,
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _getRouteDetails() async {
    try {
      if (_currentLocation == null) {
        throw Exception('Current location not available');
      }

      final destination = widget.isPickup
          ? LatLng(widget.trip.pickupLat, widget.trip.pickupLng)
          : LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

      final routeDetails = await _mapService.getRouteDetails(
        _currentLocation!,
        destination,
      );

      final points = routeDetails['points'] as List<LatLng>;
      final polyline = Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
      );

      setState(() {
        _polylines = {polyline};
        _distanceToDestination = _parseDistance(routeDetails['distance']);
        _estimatedTime = routeDetails['duration'];
      });

      // Start location updates after route is loaded
      _startLocationUpdates();
    } catch (e) {
      print('Error getting route details: $e');
      // Continue without route if there's an error
      _startLocationUpdates();
    }
  }

  double _parseDistance(String distanceText) {
    try {
      // Extract numeric value from distance text (e.g., "2.5 km" -> 2.5)
      final match = RegExp(r'(\d+\.?\d*)').firstMatch(distanceText);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  void _startLocationUpdates() {
    _locationService.startLocationUpdates(
      onLocationChanged: (position) {
        _updateLocation(LatLng(position.latitude, position.longitude));
      },
      onHeadingChanged: (heading) {
        _updateHeading(heading);
      },
      onSpeedChanged: (speed) {
        _updateSpeed(speed);
      },
    );
  }

  void _checkDistance() {
    if (_currentLocation == null) return;

    // Calculate destination based on current status
    final bool goingToPickup = widget.trip.status == 'DRIVER_ACCEPTED' ||
        widget.trip.status == 'DRIVER_IN_WAY';

    final destination = goingToPickup
        ? LatLng(widget.trip.pickupLat, widget.trip.pickupLng)
        : LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      destination.latitude,
      destination.longitude,
    );

    setState(() {
      _distanceToDestination = distance / 1000; // Convert to kilometers
      _estimatedTime = _calculateEstimatedTime(distance);
    });

    if (goingToPickup) {
      // Auto-arrive at pickup within 200 m
      if (distance <= 200 && widget.trip.status == 'DRIVER_IN_WAY') {
        _updateTripStatus('DRIVER_ARRIVED');
      }

      // Show "User picked up" button once arrived
      if (widget.trip.status == 'DRIVER_ARRIVED') {
        setState(() {
          _showPickupButton = true;
        });
      } else {
        setState(() {
          _showPickupButton = false;
        });
      }
    } else {
      // Show arrived button at drop-off within 400 m (existing logic)
      if (distance <= 400 && !_isUpdating) {
        setState(() {
          _showArrivedButton = true;
        });
      } else {
        setState(() {
          _showArrivedButton = false;
        });
      }

      // Auto-arrive at drop-off within 200 m
      if (distance <= 200 && widget.trip.status == 'DRIVER_IN_PROGRESS') {
        _updateTripStatus('TRIP_COMPLETED');
      }
    }
  }

  String _calculateEstimatedTime(double distanceInMeters) {
    // Assuming average speed of 40 km/h in city traffic
    final averageSpeedKmh = 40.0;
    final distanceInKm = distanceInMeters / 1000;
    final timeInHours = distanceInKm / averageSpeedKmh;
    final timeInMinutes = (timeInHours * 60).round();

    if (timeInMinutes < 1) {
      return 'Less than 1 min';
    } else if (timeInMinutes < 60) {
      return '$timeInMinutes mins';
    } else {
      final hours = timeInMinutes ~/ 60;
      final mins = timeInMinutes % 60;
      return '$hours h ${mins > 0 ? '$mins min' : ''}';
    }
  }

  String _calculateTripDuration() {
    final startTime = widget.trip.startedAt ?? widget.trip.createdAt;
    final endTime = widget.trip.completedAt ?? DateTime.now();
    final duration = endTime.difference(startTime);

    if (duration.inMinutes < 1) {
      return 'Less than 1 min';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} mins';
    } else {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      return '$hours h ${mins > 0 ? '$mins min' : ''}';
    }
  }

  void _showDriverArrivedNotification() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.directions_car, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver has arrived!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Your driver is waiting at the pickup location',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
      String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _onPickupPressed() async {
    await _updateTripStatus('USER_PICKED_UP');

    // After 30 seconds automatically set DRIVER_IN_PROGRESS
    _autoProgressTimer?.cancel();
    _autoProgressTimer = Timer(const Duration(seconds: 30), () {
      _updateTripStatus('DRIVER_IN_PROGRESS');
    });
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon),
    );
  }
}

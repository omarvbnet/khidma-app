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
import '../services/notification_service.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

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

    // Start magnetometer updates to track phone rotation
    Future.delayed(const Duration(milliseconds: 500), () {
      _startMagnetometerUpdates();
    });

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

  double _getCarRotationOffset() {
    // Add offset to make car point in the correct direction
    // This may need adjustment based on the car icon image orientation
    return 0.0; // Adjust this value if car is not pointing in the right direction
  }

  void _adjustCarRotation() {
    // Maps.me style navigation - no direction controls needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.map, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child:
                  Text(getLocalizations(context).mapsMeStyleNavigationMessage),
            ),
          ],
        ),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _testHeadingDirection() {
    // Show actual movement tracking test instructions
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.gps_fixed, color: Colors.blue),
              SizedBox(width: 8),
              Text(getLocalizations(context).actualMovementTestTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getLocalizations(context)
                  .actualMovementTrackingInstructionsTitle),
              SizedBox(height: 12),
              Text(getLocalizations(context).movePhoneLeftMessage),
              Text(getLocalizations(context).movePhoneRightMessage),
              Text(getLocalizations(context).bothFollowActualMovementMessage),
              Text(getLocalizations(context).gpsBasedMovementTrackingMessage),
              Text(getLocalizations(context).realTimeMovementFollowingMessage),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(getLocalizations(context).okButton),
            ),
          ],
        );
      },
    );
  }

  void _tryAlternativeCalibration() {
    // Show Maps.me navigation information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.map, color: Colors.blue),
              SizedBox(width: 8),
              Text(getLocalizations(context).mapsMeInfo),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getLocalizations(context).mapsMeStyleFeatures),
              SizedBox(height: 12),
              Text('• Route to destination'),
              Text('• GPS-based navigation'),
              Text('• Clean interface'),
              Text('• No direction controls'),
              Text('• Focus on the road ahead'),
              SizedBox(height: 8),
              Text(
                getLocalizations(context)
                    .distanceKm(_distanceToDestination.toStringAsFixed(1)),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(getLocalizations(context).ok),
            ),
          ],
        );
      },
    );
  }

  void _startMagnetometerUpdates() {
    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
      // Use GPS heading for actual phone movement instead of magnetometer rotation
      // Both camera and marker follow actual movement direction

      // Keep the current GPS heading for actual movement tracking
      // Don't update with magnetometer data - use GPS for real movement

      // Debug logging for actual movement tracking
      print(
          '📱 Actual movement tracking - GPS heading: ${_currentHeading.toStringAsFixed(1)}° (X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)})');

      // Update both camera and marker with GPS heading (actual movement)
      _updateCameraRotation(_currentHeading);
      if (_currentLocation != null) {
        _updateMarkers();
      }
    });
  }

  double _getCalibratedHeading(double rawHeading) {
    // Return GPS heading directly for Maps.me style
    return rawHeading;
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    // Both camera and marker follow actual phone movement using GPS heading
    final double carRotation =
        _currentHeading; // Use GPS heading for actual movement

    setState(() {
      _markers = {
        // Current location marker (car) - rotate to match actual movement direction
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation:
              carRotation, // Use GPS heading for actual movement direction
          anchor: const Offset(0.5, 0.5), // Center the rotation point
          flat: true, // Keep marker flat on the map
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

    // Debug logging for car marker rotation
    print('🚗 Car follows actual movement: ${carRotation.toStringAsFixed(1)}°');
  }

  void _updateCameraRotation(double heading) {
    if (_mapController.future != null && _currentLocation != null) {
      _mapController.future.then((controller) {
        // Camera follows phone rotation exactly with same degree
        final double cameraBearing = heading;

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!, // Focus on driver's current location
              zoom: 17.5, // Maps.me style zoom
              bearing:
                  cameraBearing, // Use phone heading for camera - same degree as phone
              tilt: 60, // Maps.me style 3D perspective
            ),
          ),
        );

        // Debug logging for camera rotation
        print(
            '📱 Camera follows phone rotation exactly - bearing: ${cameraBearing.toStringAsFixed(1)}°');
      });
    }
  }

  void _updateLocation(LatLng location) {
    setState(() {
      _currentLocation = location;
    });
    _updateMarkers();
    _checkDistance();

    // Update camera to work like Maps.me - follows GPS heading for route navigation
    _updateCameraToFollowDriver();
  }

  void _updateCameraToFollowDriver() {
    // Update camera to work like Maps.me - follows GPS heading for route navigation
    if (_currentLocation != null) {
      _updateCameraRotation(_currentHeading);
    }
  }

  void _updateHeading(double heading) {
    setState(() {
      _currentHeading =
          heading; // Keep GPS heading for Maps.me style navigation
    });

    // Update camera with GPS heading for route navigation
    _updateCameraRotation(heading);
  }

  void _updateSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
    });
  }

  Future<void> _updateTripStatus(String newStatus) async {
    try {
      // Don't update if already in the target status
      if (_status == newStatus) {
        print('Already in status: $newStatus, skipping update');
        return;
      }

      setState(() {
        _isUpdating = true;
      });

      print('\n=== UPDATING TRIP STATUS ===');
      print('Trip ID: ${widget.trip.id}');
      print('Current Status: $_status');
      print('New Status: $newStatus');

      // Validate status transition using current trip status
      bool isValidTransition = false;
      switch (_status.toUpperCase()) {
        case 'USER_WAITING':
          isValidTransition = newStatus == 'DRIVER_ACCEPTED';
          break;
        case 'DRIVER_ACCEPTED':
          isValidTransition =
              newStatus == 'DRIVER_IN_WAY' || newStatus == 'DRIVER_ARRIVED';
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
            'Invalid status transition from $_status to $newStatus');
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

        // Send local notification for status change
        await NotificationService.handleTripStatusChangeForDriver(
          trip: widget.trip,
          previousStatus: widget.trip.status,
          newStatus: newStatus,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context).tripStatusSuccess),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback to notify the main screen about the status change
        // This will trigger the home screen to refresh and show the appropriate screen
        if (widget.onTripStatusChanged != null) {
          widget.onTripStatusChanged!(newStatus);
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
            content: Text(getLocalizations(context).errorUpdatingTrip),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        widget.trip == null ||
        widget.trip.pickupLat == 0.0 ||
        widget.trip.dropoffLat == 0.0) {
      // Show loading spinner until trip data is fetched and valid
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).driverNavigation),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ??
                  LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
              zoom: 17.5, // Maps.me style zoom
              tilt: 60, // Maps.me style 3D perspective
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController.complete(controller),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            rotateGesturesEnabled:
                false, // Disable manual rotation for Maps.me style
            tiltGesturesEnabled: true, // Allow tilt adjustments
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            onCameraMove: (CameraPosition position) {
              // Don't override device heading when user manually moves camera
              // Let magnetometer continue to control rotation
            },
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
                            getLocalizations(context).distance,
                            '${widget.trip.distance.toStringAsFixed(1)} km',
                            Icons.route,
                            Colors.blue,
                          ),
                          _buildInfoColumn(
                            getLocalizations(context).time,
                            _calculateTripDuration(),
                            Icons.timer,
                            Colors.orange,
                          ),
                          _buildInfoColumn(
                            getLocalizations(context).speed,
                            '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                            Icons.speed,
                            Colors.green,
                          ),
                          _buildInfoColumn(
                            getLocalizations(context).fare,
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
          // Debug info panel when close to pickup
          if ((_status == 'DRIVER_ACCEPTED' || _status == 'DRIVER_IN_WAY') &&
              _distanceToDestination <= 0.3 &&
              widget.isPickup)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.orange.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            getLocalizations(context).debugInfo,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        getLocalizations(context).status,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        getLocalizations(context).distance,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        getLocalizations(context).autoArrival,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Permanent heading indicator
          Positioned(
            top: 80,
            right: 16,
            child: GestureDetector(
              onTap: _calibrateMagnetometer,
              onLongPress: _adjustCarRotation,
              onDoubleTap: _testHeadingDirection,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.compass_calibration,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_currentHeading.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _getDirectionText(_currentHeading),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Camera controls
          Positioned(
            top: 140,
            right: 16,
            child: GestureDetector(
              onTap: _forceCameraUpdate,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      getLocalizations(context).actual,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getLocalizations(context).movement,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Reset camera button
          Positioned(
            top: 200,
            right: 16,
            child: GestureDetector(
              onTap: _resetCamera,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      getLocalizations(context).reset,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getLocalizations(context).north,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_status == 'DRIVER_IN_PROGRESS')
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
                        getLocalizations(context).speed,
                        '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                        Icons.speed,
                        Colors.green,
                      ),
                      _buildInfoColumn(
                        getLocalizations(context).time,
                        _estimatedTime,
                        Icons.timer,
                        Colors.orange,
                      ),
                      _buildInfoColumn(
                        getLocalizations(context).distance,
                        '${_distanceToDestination.toStringAsFixed(1)} km',
                        Icons.route,
                        Colors.blue,
                      ),
                      _buildInfoColumn(
                        getLocalizations(context).fare,
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
          // GPS heading indicator
          Positioned(
            top: 80,
            right: 16,
            child: GestureDetector(
              onTap: _testHeadingDirection,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_currentHeading.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _getDirectionText(_currentHeading),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Phone rotation indicator
          Positioned(
            top: 80,
            right: 16,
            child: GestureDetector(
              onTap: _testHeadingDirection,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_currentHeading.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _getDirectionText(_currentHeading),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons() {
    // Show manual arrived button for pickup when close but not auto-arrived
    final bool showManualArrivedButton =
        (_status == 'DRIVER_ACCEPTED' || _status == 'DRIVER_IN_WAY') &&
            _distanceToDestination <= 0.3 && // Within 300m
            !_isUpdating;

    if (!_showArrivedButton && !_showPickupButton && !showManualArrivedButton)
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
              if (showManualArrivedButton) ...[
                Text(
                  getLocalizations(context).closeToPickupLocation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  getLocalizations(context).distance,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateTripStatus('DRIVER_ARRIVED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(getLocalizations(context).iHaveArrived),
                ),
              ] else if (_showPickupButton) ...[
                Text(
                  getLocalizations(context).userPickedUp,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _infoChip(Icons.speed,
                          '${_currentSpeed.toStringAsFixed(1)} km/h'),
                    ),
                    Flexible(
                      child: _infoChip(Icons.timer, _estimatedTime),
                    ),
                    Flexible(
                      child: _infoChip(Icons.directions_car,
                          '${_distanceToDestination.toStringAsFixed(1)} km'),
                    ),
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
                  child: Text(getLocalizations(context).confirmPickedUp),
                ),
              ] else ...[
                Text(
                  getLocalizations(context).youHaveArrivedAtYourDestination,
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
                  child: Text(getLocalizations(context).completeTrip),
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
        return getLocalizations(context).waitingForDriver;
      case 'DRIVER_ACCEPTED':
        return getLocalizations(context).driverAccepted;
      case 'DRIVER_IN_WAY':
        return getLocalizations(context).driverIsOnTheWay;
      case 'DRIVER_ARRIVED':
        return getLocalizations(context).driverHasArrived;
      case 'USER_PICKED_UP':
        return getLocalizations(context).youArePickedUp;
      case 'DRIVER_IN_PROGRESS':
        return getLocalizations(context).onTheWayToDestination;
      case 'TRIP_COMPLETED':
        return getLocalizations(context).tripCompleted;
      default:
        return getLocalizations(context).unknownStatus;
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

      // Get current location
      final position = await _locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);
      print(
          'Current location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');

      // Set up markers
      _setupMarkers();

      // Get route details
      await _getRouteDetails();

      // Initialize camera with Maps.me style settings after a short delay
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted && _currentLocation != null) {
          _forceCameraUpdate();
          print(
              '🗺️ Maps.me style camera initialized with heading: ${_currentHeading.toStringAsFixed(1)}°');
        }
      });

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
        });
        // Don't show error message to user if map initialization fails
        // The app will continue to work with basic functionality
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
    final bool goingToPickup =
        _status == 'DRIVER_ACCEPTED' || _status == 'DRIVER_IN_WAY';

    final destination = goingToPickup
        ? LatLng(widget.trip.pickupLat, widget.trip.pickupLng)
        : LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Debug logging
    if (goingToPickup && distance <= 300) {
      // Log when within 300m of pickup
      print(
          '📍 Distance to pickup: ${distance.toStringAsFixed(1)}m, Status: $_status, IsUpdating: $_isUpdating');
    }

    setState(() {
      _distanceToDestination = distance / 1000; // Convert to kilometers
      _estimatedTime = _calculateEstimatedTime(distance);
    });

    if (goingToPickup) {
      // Auto-arrive at pickup within 150 m - handle both DRIVER_ACCEPTED and DRIVER_IN_WAY
      if (distance <= 150 &&
          (_status == 'DRIVER_ACCEPTED' || _status == 'DRIVER_IN_WAY') &&
          !_isUpdating) {
        print(
            '🚗 Driver close to pickup (${distance.toStringAsFixed(1)}m), auto-arriving...');
        print(
            '📍 Current status: $_status, Distance: ${distance.toStringAsFixed(1)}m, IsUpdating: $_isUpdating');
        _updateTripStatus('DRIVER_ARRIVED');
      }

      // Show "User picked up" button once arrived
      if (_status == 'DRIVER_ARRIVED') {
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

      // Auto-arrive at drop-off within 200 m - only if not already completed
      if (distance <= 200 && _status == 'DRIVER_IN_PROGRESS' && !_isUpdating) {
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
    print('🚀 Pickup button pressed - updating status to USER_PICKED_UP');
    await _updateTripStatus('USER_PICKED_UP');

    // Call the callback to notify the main screen about the status change
    if (widget.onTripStatusChanged != null) {
      widget.onTripStatusChanged!('USER_PICKED_UP');
    }

    // After 30 seconds automatically set DRIVER_IN_PROGRESS
    _autoProgressTimer?.cancel();
    _autoProgressTimer = Timer(const Duration(seconds: 30), () {
      _updateTripStatus('DRIVER_IN_PROGRESS');
      if (widget.onTripStatusChanged != null) {
        widget.onTripStatusChanged!('DRIVER_IN_PROGRESS');
      }
    });
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectionText(double heading) {
    if (heading >= 315 || heading < 45) return 'N';
    if (heading >= 45 && heading < 135) return 'E';
    if (heading >= 135 && heading < 225) return 'S';
    if (heading >= 225 && heading < 315) return 'W';
    return 'N';
  }

  void _calibrateMagnetometer() {
    // Show Maps.me style navigation instructions
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.map, color: Colors.blue),
              SizedBox(width: 8),
              Text(getLocalizations(context).mapsMeNavigation),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getLocalizations(context).mapsMeStyleNavigationInstructions),
              SizedBox(height: 12),
              Text('1. GPS-based route navigation'),
              Text('2. No phone rotation required'),
              Text('3. Clean, simple interface'),
              Text('4. Focus on the route ahead'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GPS Heading: ${_currentHeading.toStringAsFixed(1)}°\n'
                  'Distance: ${_distanceToDestination.toStringAsFixed(1)} km',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(getLocalizations(context).ok),
            ),
          ],
        );
      },
    );
  }

  void _forceCameraUpdate() {
    // Force camera update with Maps.me style settings
    if (_currentLocation != null) {
      _mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 17.5, // Maps.me style zoom
              bearing: _currentHeading, // Use GPS heading for route navigation
              tilt: 60, // Maps.me style 3D perspective
            ),
          ),
        );
        print(
            '🗺️ Maps.me style camera forced update - bearing: ${_currentHeading.toStringAsFixed(1)}°');
      });
    }
  }

  void _resetCamera() {
    // Reset camera to default orientation (North-facing) at same location
    if (_currentLocation != null) {
      _mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 17.5, // Maps.me style zoom
              bearing: 0, // Reset to North (0 degrees)
              tilt: 60, // Maps.me style 3D perspective
            ),
          ),
        );

        // Reset GPS heading to North
        setState(() {
          _currentHeading = 0;
        });

        print('🗺️ Maps.me style camera reset to North (0°) at same location');

        // Update markers with reset heading
        _updateMarkers();
      });
    }
  }
}

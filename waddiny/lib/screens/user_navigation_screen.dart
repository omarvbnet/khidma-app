import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/map_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'dart:math';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

class UserNavigationScreen extends StatefulWidget {
  final Trip trip;
  final Function(String) onTripStatusChanged;

  const UserNavigationScreen({
    Key? key,
    required this.trip,
    required this.onTripStatusChanged,
  }) : super(key: key);

  @override
  _UserNavigationScreenState createState() => _UserNavigationScreenState();
}

class _UserNavigationScreenState extends State<UserNavigationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final _tripService = TripService();
  final _mapService = MapService();
  final _locationService = LocationService();
  LatLng? _currentLocation;
  LatLng? _driverLocation;
  double _distanceToDestination = 0;
  String _estimatedTime = '';
  bool _isLoading = true;
  String _currentAddress = '';
  Timer? _statusCheckTimer;
  Timer? _driverLocationTimer;
  double _currentHeading = 0.0;
  double _deviceHeading = 0.0;
  String? _error;
  bool _showArrivedButton = false;
  bool _isUpdating = false;
  bool _hasShownDriverNearNotification = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    // Start periodic status and distance checks
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkTripStatus();
      _checkDistance();
    });
    // Start tracking driver location
    _startDriverLocationTracking();
  }

  Future<void> _checkTripStatus() async {
    try {
      final updatedTrip = await _tripService.getTripById(widget.trip.id);
      if (updatedTrip != null) {
        final newStatus = updatedTrip['status'] as String;
        if (newStatus != widget.trip.status) {
          final previousStatus = widget.trip.status;
          widget.onTripStatusChanged(newStatus);

          // Send local notification for status change
          await NotificationService.handleTripStatusChangeForUser(
            trip: widget.trip,
            previousStatus: previousStatus,
            newStatus: newStatus,
          );

          if (newStatus == 'TRIP_COMPLETED' || newStatus == 'TRIP_CANCELLED') {
            _statusCheckTimer?.cancel();
            _driverLocationTimer?.cancel();
          }
        }
      }
    } catch (e) {
      print('Error checking trip status: $e');
    }
  }

  void _startDriverLocationTracking() {
    _driverLocationTimer?.cancel();
    _driverLocationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateDriverLocation();
    });
  }

  Future<void> _updateDriverLocation() async {
    try {
      final updatedTrip = await _tripService.getTripById(widget.trip.id);
      if (updatedTrip != null && updatedTrip['driverLocation'] != null) {
        final driverLocationStr = updatedTrip['driverLocation'].toString();
        final location = driverLocationStr.split(',');

        // Ensure we have exactly 2 elements before accessing them
        if (location.length == 2) {
          try {
            final lat = double.parse(location[0].trim());
            final lng = double.parse(location[1].trim());

            // Validate coordinates
            if (_isValidCoordinate(lat, lng)) {
              setState(() {
                _driverLocation = LatLng(lat, lng);
              });
              _updateMarkers();
              _checkDriverDistance();
            } else {
              print('Invalid driver coordinates: $lat, $lng');
            }
          } catch (e) {
            print('Error parsing driver location coordinates: $e');
          }
        } else {
          print('Invalid driver location format: $driverLocationStr');
        }
      }
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  void _checkDriverDistance() {
    if (_currentLocation == null || _driverLocation == null) return;

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _driverLocation!.latitude,
      _driverLocation!.longitude,
    );

    // Show notification when driver is within 200 meters and hasn't shown notification yet
    if (distance <= 200 && !_hasShownDriverNearNotification) {
      _showDriverNearNotification();
      setState(() {
        _hasShownDriverNearNotification = true;
      });
    }
  }

  void _showDriverNearNotification() {
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
                    getLocalizations(context).driverIsNearMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    getLocalizations(context).driverApproachingMessage,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: getLocalizations(context).okButton,
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    final markers = <Marker>{
      // Current location marker
      Marker(
        markerId: const MarkerId('current'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow:
            InfoWindow(title: getLocalizations(context).yourLocationLabel),
      ),
      // Dropoff location marker
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: getLocalizations(context).dropoffLocationLabel,
          snippet: widget.trip.dropoffLocation,
        ),
      ),
    };

    // Add driver marker if available
    if (_driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: getLocalizations(context).driverLocationLabel,
            snippet: getLocalizations(context).driverIsHereMessage,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _updateLocation(LatLng position, double heading) async {
    if (!mounted) return;

    print('\n=== UPDATING LOCATION ===');
    print('Current position:');
    print('- Latitude: ${position.latitude}');
    print('- Longitude: ${position.longitude}');
    print('Current heading: $heading');

    // Validate current position
    if (!_isValidCoordinate(position.latitude, position.longitude)) {
      print('Invalid current position coordinates, skipping update');
      return;
    }

    setState(() {
      _currentLocation = position;
      _currentHeading = heading;
    });

    // Always use current location as start point
    final startLocation = position;

    // Validate dropoff coordinates
    if (!_isValidCoordinate(widget.trip.dropoffLat, widget.trip.dropoffLng)) {
      print('Invalid dropoff coordinates detected:');
      print('- Latitude: ${widget.trip.dropoffLat}');
      print('- Longitude: ${widget.trip.dropoffLng}');
      print('Skipping route calculation due to invalid dropoff coordinates');
      return;
    }

    // Create dropoff location
    final dropoffLocation =
        LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

    print('\nCalculating route:');
    print(
        'From (current location): ${startLocation.latitude}, ${startLocation.longitude}');
    print(
        'To (dropoff): ${dropoffLocation.latitude}, ${dropoffLocation.longitude}');

    // Get route details with retry logic
    Map<String, dynamic>? routeDetails;
    int attempts = 0;
    const maxAttempts = 3;
    const retryDelay = Duration(seconds: 1);

    while (attempts < maxAttempts) {
      try {
        routeDetails = await _mapService.getRouteDetails(
          startLocation,
          dropoffLocation,
        );
        if (routeDetails != null) break;
      } catch (e) {
        print('Attempt ${attempts + 1} failed: $e');
        if (attempts == maxAttempts - 1) {
          print('Failed to get route after $maxAttempts attempts');
          return;
        }
        await Future.delayed(retryDelay);
      }
      attempts++;
    }

    if (routeDetails != null) {
      setState(() {
        // Update polylines
        final polyline = routeDetails?['polyline'] as String?;
        if (polyline != null) {
          _polylines = _mapService.decodePolyline(polyline);
        } else {
          _polylines = {};
        }

        // Update distance
        try {
          final distanceValue = routeDetails?['distance'];
          if (distanceValue != null) {
            if (distanceValue is num) {
              _distanceToDestination = distanceValue.toDouble() / 1000;
            } else {
              final distanceStr =
                  distanceValue.toString().replaceAll(RegExp(r'[^0-9.]'), '');
              _distanceToDestination = double.tryParse(distanceStr) ?? 0.0;
            }
          } else {
            _distanceToDestination = 0.0;
          }
        } catch (e) {
          print('Error parsing distance: $e');
          _distanceToDestination = 0.0;
        }

        // Update estimated time
        _estimatedTime = routeDetails?['duration'] as String? ?? 'Unknown';
      });

      // Update markers
      _updateMarkers();

      // Update camera to show the entire route
      if (_mapController.future != null) {
        _mapController.future.then((controller) {
          // Calculate bounds to include both current location and destination
          final bounds = LatLngBounds(
            southwest: LatLng(
              min(startLocation.latitude, dropoffLocation.latitude),
              min(startLocation.longitude, dropoffLocation.longitude),
            ),
            northeast: LatLng(
              max(startLocation.latitude, dropoffLocation.latitude),
              max(startLocation.longitude, dropoffLocation.longitude),
            ),
          );

          // Animate camera to show the entire route with padding
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50.0),
          );
          print('Camera position updated to show route');
        });
      }

      // Check distance to destination for auto-updating trip status
      final distance = Geolocator.distanceBetween(
        startLocation.latitude,
        startLocation.longitude,
        dropoffLocation.latitude,
        dropoffLocation.longitude,
      );

      print('Distance to destination: ${distance.toStringAsFixed(2)} meters');

      // Auto-update status when near destination
      if (distance <= 400) {
        // 400 meters
        if (widget.trip.status == 'USER_PICKED_UP') {
          print('Near dropoff location, updating status to TRIP_COMPLETED');
          _updateTripStatus('TRIP_COMPLETED');
        }
      }
    } else {
      print('No route details received during location update');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).tripInProgressTitle),
        backgroundColor: Colors.blue,
        actions: [],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController.complete(controller),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          // Status card
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getStatusIcon(),
                            color: _getStatusColor(),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (_driverLocation != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Driver is ${(_distanceToDestination * 1000).toStringAsFixed(0)}m away',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                          _estimatedTime,
                          Icons.timer,
                          Colors.orange,
                        ),
                        _buildInfoColumn(
                          getLocalizations(context).price,
                          '${widget.trip.fare} IQD',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom card with trip details
          Positioned(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      getLocalizations(context).fromLabel,
                      widget.trip.pickupLocation,
                      Icons.location_on,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      getLocalizations(context).toLabel,
                      widget.trip.dropoffLocation,
                      Icons.location_on,
                      Colors.red,
                    ),
                    if (widget.trip.driverName != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).driverLabel,
                        widget.trip.driverName!,
                        Icons.person,
                        Colors.blue,
                      ),
                    ],
                    if (widget.trip.driverPhone != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).phoneLabel,
                        widget.trip.driverPhone!,
                        Icons.phone,
                        Colors.orange,
                      ),
                    ],
                    if (widget.trip.carType != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).carLabel,
                        widget.trip.carType!,
                        Icons.directions_car,
                        Colors.purple,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayStatus;
    switch (status.toUpperCase()) {
      case 'DRIVER_ACCEPTED':
        color = Colors.blue;
        displayStatus = getLocalizations(context).driverAccepted;
        break;
      case 'DRIVER_IN_WAY':
        color = Colors.orange;
        displayStatus = getLocalizations(context).statusDriverInWay;
        break;
      case 'DRIVER_ARRIVED':
        color = Colors.green;
        displayStatus = getLocalizations(context).driverArrived;
        break;
      case 'USER_PICKED_UP':
        color = Colors.purple;
        displayStatus = getLocalizations(context).userPickedUp;
        break;
      case 'DRIVER_IN_PROGRESS':
        color = Colors.blue;
        displayStatus = getLocalizations(context).statusDriverInProgress;
        break;
      case 'TRIP_COMPLETED':
        color = Colors.green;
        displayStatus = getLocalizations(context).tripCompleted;
        break;
      case 'TRIP_CANCELLED':
        color = Colors.red;
        displayStatus = getLocalizations(context).tripCancelled;
        break;
      case 'USER_WAITING':
        color = Colors.orangeAccent;
        displayStatus = getLocalizations(context).statusUserWaiting;
        break;
      default:
        color = Colors.grey;
        displayStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLocationRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _driverLocationTimer?.cancel();
    super.dispose();
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat != 0.0 &&
        lng != 0.0 &&
        !lat.isNaN &&
        !lng.isNaN &&
        !lat.isInfinite &&
        !lng.isInfinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Get current address
      final address =
          await _locationService.getAddressFromLatLng(_currentLocation!);
      if (!mounted) return;

      setState(() {
        _currentAddress = address;
      });

      // Calculate route
      await _updateRoute();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRoute() async {
    if (_currentLocation == null) return;

    try {
      // Validate coordinates
      if (!_isValidCoordinate(widget.trip.dropoffLat, widget.trip.dropoffLng)) {
        throw Exception('Invalid dropoff coordinates. Please contact support.');
      }

      final dropoffLocation =
          LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

      // Get route details
      final routeDetails = await _mapService.getRouteDetails(
        _currentLocation!,
        dropoffLocation,
      );

      if (!mounted) return;

      setState(() {
        // Update polylines
        final polyline = routeDetails['polyline'] as String?;
        if (polyline != null) {
          _polylines = _mapService.decodePolyline(polyline);
        } else {
          _polylines = {};
        }

        // Update distance
        try {
          final distanceValue = routeDetails['distance'];
          if (distanceValue != null) {
            if (distanceValue is num) {
              _distanceToDestination = distanceValue.toDouble() / 1000;
            } else {
              final distanceStr =
                  distanceValue.toString().replaceAll(RegExp(r'[^0-9.]'), '');
              _distanceToDestination = double.tryParse(distanceStr) ?? 0.0;
            }
          } else {
            _distanceToDestination = 0.0;
          }
        } catch (e) {
          print('Error parsing distance: $e');
          _distanceToDestination = 0.0;
        }

        // Update estimated time
        _estimatedTime = routeDetails['duration'] as String? ?? 'Unknown';
        _error = null;
      });

      // Update markers
      _updateMarkers();

      // Update camera to show the entire route
      if (_mapController.isCompleted) {
        final bounds = _getBoundsForRoute();
        if (bounds != null) {
          _mapController.future.then((controller) {
            controller.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50.0),
            );
          });
        }
      }
    } catch (e) {
      print('Error updating route: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  LatLngBounds? _getBoundsForRoute() {
    if (_currentLocation == null) return null;

    final dropoffLocation =
        LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

    return LatLngBounds(
      southwest: LatLng(
        min(_currentLocation!.latitude, dropoffLocation.latitude),
        min(_currentLocation!.longitude, dropoffLocation.longitude),
      ),
      northeast: LatLng(
        max(_currentLocation!.latitude, dropoffLocation.latitude),
        max(_currentLocation!.longitude, dropoffLocation.longitude),
      ),
    );
  }

  void _checkDistance() {
    if (_currentLocation == null) return;

    // Calculate distance to destination
    final destination = widget.trip.status == 'DRIVER_ACCEPTED' ||
            widget.trip.status == 'DRIVER_IN_WAY'
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

    // Show arrived button when within 400 meters of destination
    if (distance <= 400 && !_isUpdating) {
      setState(() {
        _showArrivedButton = true;
      });
    } else {
      setState(() {
        _showArrivedButton = false;
      });
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

  Widget _buildStatusButtons() {
    if (!_showArrivedButton) return const SizedBox.shrink();

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
            ],
          ),
        ),
      ),
    );
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

      // Validate status transition
      bool isValidTransition = false;
      switch (widget.trip.status.toUpperCase()) {
        case 'DRIVER_ARRIVED':
          isValidTransition = newStatus == 'USER_PICKED_UP';
          break;
        case 'DRIVER_ARRIVED_DROPOFF':
          isValidTransition = newStatus == 'TRIP_COMPLETED';
          break;
        default:
          isValidTransition = false;
      }

      if (!isValidTransition) {
        throw Exception(
            'Invalid status transition from ${widget.trip.status} to $newStatus');
      }

      final updatedTrip =
          await _tripService.updateTripStatus(widget.trip.id, newStatus);
      print('Trip updated successfully:');
      print('- New Status: ${updatedTrip.status}');
      print('- Started At: ${updatedTrip.startedAt}');
      print('- Completed At: ${updatedTrip.completedAt}');

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip ${newStatus.toLowerCase()} successfully'),
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
            content: Text('Error updating trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText() {
    switch (widget.trip.status.toUpperCase()) {
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
      case 'DRIVER_ARRIVED_DROPOFF':
        return 'Arrived at destination';
      case 'TRIP_COMPLETED':
        return 'Trip completed';
      case 'TRIP_CANCELLED':
        return 'Trip cancelled';
      default:
        return 'Unknown status';
    }
  }

  Color _getStatusColor() {
    switch (widget.trip.status.toUpperCase()) {
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
      case 'DRIVER_ARRIVED_DROPOFF':
        return Colors.amber;
      case 'TRIP_COMPLETED':
        return Colors.green;
      case 'TRIP_CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.trip.status.toUpperCase()) {
      case 'DRIVER_ACCEPTED':
        return Icons.check_circle;
      case 'DRIVER_IN_WAY':
        return Icons.directions_car;
      case 'DRIVER_ARRIVED':
        return Icons.location_on;
      case 'USER_PICKED_UP':
        return Icons.person;
      case 'DRIVER_IN_PROGRESS':
        return Icons.directions;
      case 'DRIVER_ARRIVED_DROPOFF':
        return Icons.flag;
      case 'TRIP_COMPLETED':
        return Icons.check_circle;
      case 'TRIP_CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildInfoColumn(
      String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

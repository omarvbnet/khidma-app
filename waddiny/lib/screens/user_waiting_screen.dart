import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../services/map_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper
import 'user_single_trip_screen.dart';

class UserWaitingScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onTripCancelled;

  const UserWaitingScreen({
    Key? key,
    required this.trip,
    required this.onTripCancelled,
  }) : super(key: key);

  @override
  _UserWaitingScreenState createState() => _UserWaitingScreenState();
}

class _UserWaitingScreenState extends State<UserWaitingScreen> {
  final _tripService = TripService();
  final _authService = AuthService();
  final _mapService = MapService();
  Timer? _timer;
  int _waitingSeconds = 0;
  DateTime? _tripStartTime;
  bool _isCancelling = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tripStartTime = DateTime.parse(widget.trip['createdAt']);
    _waitingSeconds = DateTime.now().difference(_tripStartTime!).inSeconds;
    _startTimer();
    _initializeMap();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tripStartTime != null && mounted) {
        setState(() {
          _waitingSeconds =
              DateTime.now().difference(_tripStartTime!).inSeconds;
        });
      }
    });
  }

  String _formatWaitingTime() {
    final minutes = (_waitingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_waitingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Create markers for pickup and dropoff locations
      final pickupMarker = Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          widget.trip['pickupLat'],
          widget.trip['pickupLng'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: widget.trip['pickupLocation'],
        ),
      );

      final dropoffMarker = Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
          widget.trip['dropoffLat'],
          widget.trip['dropoffLng'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Dropoff',
          snippet: widget.trip['dropoffLocation'],
        ),
      );

      // Get route details
      final routeDetails = await _mapService.getRouteDetails(
        LatLng(widget.trip['pickupLat'], widget.trip['pickupLng']),
        LatLng(widget.trip['dropoffLat'], widget.trip['dropoffLng']),
      );

      if (!mounted) return;

      setState(() {
        _markers = {pickupMarker, dropoffMarker};
        _polylines = _mapService.decodePolyline(routeDetails['polyline']);
        _isLoading = false;
      });

      // Fit map bounds to show both markers
      if (_mapController != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            min(widget.trip['pickupLat'], widget.trip['dropoffLat']),
            min(widget.trip['pickupLng'], widget.trip['dropoffLng']),
          ),
          northeast: LatLng(
            max(widget.trip['pickupLat'], widget.trip['dropoffLat']),
            max(widget.trip['pickupLng'], widget.trip['dropoffLng']),
          ),
        );
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0),
        );
      }
    } catch (e) {
      print('Error initializing map: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelTrip() async {
    try {
      setState(() {
        _isCancelling = true;
      });

      print('\n=== CANCELLING TRIP ===');
      print('Trip ID: ${widget.trip['id']}');

      await _tripService.cancelTrip(widget.trip['id']);
      print('Trip cancelled successfully');

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalizations(context).tripCancelledSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      print('Navigating back to user main screen...');
      // Navigate to user main screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/user-main',
        (route) => false,
      );
      print('Navigation completed');
    } catch (e) {
      print('Error cancelling trip: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getLocalizations(context).errorCancellingTrip(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map in the background
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.trip['pickupLat'],
                widget.trip['pickupLng'],
              ),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _initializeMap();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          // Trip card overlay
          SafeArea(
            child: Column(
              children: [
                // Top card with trip details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getLocalizations(context).waitingForDriverTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatWaitingTime(),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            getLocalizations(context).fromLabel,
                            widget.trip['pickupLocation'],
                            Icons.location_on,
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            getLocalizations(context).toLabel,
                            widget.trip['dropoffLocation'],
                            Icons.location_on,
                            Colors.red,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            getLocalizations(context).priceLabel,
                            '${widget.trip['fare']} IQD',
                            Icons.attach_money,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            getLocalizations(context).distance,
                            '${widget.trip['distance'].toStringAsFixed(1)} km',
                            Icons.route,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Bottom card with action buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (!_isCancelling)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _cancelTrip,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                    getLocalizations(context).cancelTripButton),
                              ),
                            ),
                          if (_isCancelling)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

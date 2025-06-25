import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/taxi_request_model.dart';
import '../services/api_service.dart';
import '../services/map_service.dart';
import '../services/location_service.dart';
import '../models/trip_model.dart';
import 'driver_navigation_screen.dart';

class DriverArrivedScreen extends StatefulWidget {
  final TaxiRequest trip;
  const DriverArrivedScreen({super.key, required this.trip});

  @override
  State<DriverArrivedScreen> createState() => _DriverArrivedScreenState();
}

class _DriverArrivedScreenState extends State<DriverArrivedScreen> {
  final _apiService = ApiService();
  final _mapService = MapService();
  final _locationService = LocationService();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  double _currentSpeed = 0;
  double _distance = 0;
  String _estimatedTime = '';
  bool _isLoading = true;
  bool _isUpdating = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getCurrentLocation();
    await _buildMarkersAndRoute();
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _getCurrentLocation();
      await _updateRoute();
    });
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    final pos = await _locationService.getCurrentLocation();
    _currentLocation = LatLng(pos.latitude, pos.longitude);
    _currentSpeed = pos.speed;
  }

  Future<void> _buildMarkersAndRoute() async {
    final pickup = LatLng(widget.trip.pickupLat, widget.trip.pickupLng);
    final dropoff = LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);
    _markers = {
      Marker(
        markerId: const MarkerId('current'),
        position: _currentLocation ?? pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: dropoff,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Dropoff'),
      ),
    };
    await _updateRoute();
  }

  Future<void> _updateRoute() async {
    if (_currentLocation == null) return;
    final result = await _mapService.getRouteDetails(_currentLocation!,
        LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng));
    if (result['polyline'] != null) {
      _polylines = _mapService.decodePolyline(result['polyline']);
    }
    final rawDist = result['distance'];
    double km = 0;
    if (rawDist is num) {
      km = rawDist / 1000;
    } else if (rawDist is String) {
      final cleaned = rawDist.replaceAll(RegExp(r'[^0-9.]'), '');
      km = double.tryParse(cleaned) ?? 0;
    }
    _distance = km;
    _estimatedTime = result['duration'] ?? '';
    setState(() {});
  }

  Future<void> _onPickup() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      final updated =
          await _apiService.updateTripStatus(widget.trip.id, 'USER_PICKED_UP');
      final tripObj = Trip.fromJson(updated.toJson());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DriverNavigationScreen(
            trip: tripObj,
            isPickup: false,
            onTripStatusChanged: (_) {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick up Passenger'),
        actions: [],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: _currentLocation ??
                        LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
                    zoom: 16),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                onMapCreated: (c) => _controller.complete(c),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: [
                            _infoChip(Icons.speed,
                                '${_currentSpeed.toStringAsFixed(1)} km/h'),
                            _infoChip(Icons.timer, _estimatedTime),
                            _infoChip(Icons.route,
                                '${_distance.toStringAsFixed(1)} km'),
                            _infoChip(Icons.attach_money,
                                '${widget.trip.price.toStringAsFixed(0)} IQD'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _onPickup,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                            child: _isUpdating
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('User Picked Up'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
    );
  }
}

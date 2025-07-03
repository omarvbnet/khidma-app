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
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

class DriverArrivedScreen extends StatefulWidget {
  final TaxiRequest trip;
  final Function(String)? onTripStatusChanged;

  const DriverArrivedScreen({
    super.key,
    required this.trip,
    this.onTripStatusChanged,
  });

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
    try {
      await _getCurrentLocation();
      await _buildMarkersAndRoute();
      _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        if (mounted) {
          await _getCurrentLocation();
          await _updateRoute();
        }
      });
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error in _init: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final pos = await _locationService.getCurrentLocation();
      if (mounted) {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _currentSpeed = pos.speed;
      }
    } catch (e) {
      print('Error getting current location: $e');
      // Use a default location if current location fails
      if (mounted && _currentLocation == null) {
        _currentLocation = LatLng(widget.trip.pickupLat, widget.trip.pickupLng);
      }
    }
  }

  Future<void> _buildMarkersAndRoute() async {
    try {
      final pickup = LatLng(widget.trip.pickupLat, widget.trip.pickupLng);
      final dropoff = LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);

      if (!mounted) return;

      _markers = {
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation ?? pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow:
              InfoWindow(title: getLocalizations(context).yourLocationLabel),
        ),
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: getLocalizations(context).pickupLabel),
        ),
        Marker(
          markerId: const MarkerId('dropoff'),
          position: dropoff,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: getLocalizations(context).dropoffLabel),
        ),
      };

      if (mounted) {
        await _updateRoute();
      }
    } catch (e) {
      print('Error building markers and route: $e');
    }
  }

  Future<void> _updateRoute() async {
    if (_currentLocation == null) return;

    try {
      final result = await _mapService.getRouteDetails(_currentLocation!,
          LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng));

      if (!mounted) return;

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

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error updating route: $e');
      // Don't call setState on error to avoid null check issues
    }
  }

  Future<void> _onPickup() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      print('🚀 Starting pickup process for trip: ${widget.trip.id}');
      final updated =
          await _apiService.updateTripStatus(widget.trip.id, 'USER_PICKED_UP');
      print('✅ Trip status updated to USER_PICKED_UP');

      if (!mounted) return;

      // Call the callback to notify the main screen about the status change
      if (widget.onTripStatusChanged != null) {
        widget.onTripStatusChanged!('USER_PICKED_UP');
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(getLocalizations(context).passengerPickedUpSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      // Give the main screen time to refresh its trip data
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Pop back to the main screen - it will automatically refresh and show the navigation screen
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error during pickup: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(getLocalizations(context).errorDuringPickup(e.toString())),
          backgroundColor: Colors.red,
        ),
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
    // Only show map if trip data is loaded and coordinates are valid
    if (_isLoading ||
        widget.trip == null ||
        widget.trip.pickupLat == 0.0 ||
        widget.trip.dropoffLat == 0.0) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).pickupPassengerTitle),
        actions: [],
      ),
      body: Stack(children: [
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
                      _infoChip(
                          Icons.route, '${_distance.toStringAsFixed(1)} km'),
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(getLocalizations(context).userPickedUpButton),
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

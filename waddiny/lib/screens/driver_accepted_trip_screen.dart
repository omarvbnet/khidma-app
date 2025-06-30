import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip_model.dart';
import '../services/driver_service.dart';
import '../services/api_service.dart';
import '../screens/driver_navigation_screen.dart';
import '../screens/driver_trip_details_screen.dart';
import '../screens/driver_home_screen.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

class DriverAcceptedTripScreen extends StatefulWidget {
  final Trip trip;

  const DriverAcceptedTripScreen({Key? key, required this.trip})
      : super(key: key);

  @override
  _DriverAcceptedTripScreenState createState() =>
      _DriverAcceptedTripScreenState();
}

class _DriverAcceptedTripScreenState extends State<DriverAcceptedTripScreen> {
  final _driverService = DriverService(ApiService());
  bool _isStarting = false;
  bool _isLoading = true;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Create markers for pickup and dropoff locations
    final pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
      infoWindow: InfoWindow(
        title: 'Pickup',
        snippet: widget.trip.pickupLocation,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    final dropoffMarker = Marker(
      markerId: const MarkerId('dropoff'),
      position: LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
      infoWindow: InfoWindow(
        title: 'Dropoff',
        snippet: widget.trip.dropoffLocation,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers = {pickupMarker, dropoffMarker};
      _isLoading = false;
    });
  }

  Future<void> _startTrip() async {
    try {
      setState(() {
        _isStarting = true;
      });

      print('🚀 Starting trip: ${widget.trip.id}');
      // Start the trip using the driver service
      final updatedTaxiRequest = await _driverService.startTrip(widget.trip.id);
      print('✅ Trip started successfully');

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalizations(context).tripStartedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to the main screen - it will automatically refresh and show the navigation screen
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error starting trip: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(getLocalizations(context).errorStartingTrip(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
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
        title: Text(getLocalizations(context).tripAcceptedTitle),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [],
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                // Fit bounds to show both pickup and dropoff
                final bounds = LatLngBounds(
                  southwest: LatLng(
                    widget.trip.pickupLat < widget.trip.dropoffLat
                        ? widget.trip.pickupLat
                        : widget.trip.dropoffLat,
                    widget.trip.pickupLng < widget.trip.dropoffLng
                        ? widget.trip.pickupLng
                        : widget.trip.dropoffLng,
                  ),
                  northeast: LatLng(
                    widget.trip.pickupLat > widget.trip.dropoffLat
                        ? widget.trip.pickupLat
                        : widget.trip.dropoffLat,
                    widget.trip.pickupLng > widget.trip.dropoffLng
                        ? widget.trip.pickupLng
                        : widget.trip.dropoffLng,
                  ),
                );
                controller.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 50.0),
                );
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),
          // Trip details and start button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip details
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
                const SizedBox(height: 12),
                _buildInfoRow(
                  getLocalizations(context).priceLabel,
                  '${widget.trip.fare} IQD',
                  Icons.attach_money,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  getLocalizations(context).distance,
                  '${widget.trip.distance.toStringAsFixed(1)} km',
                  Icons.straighten,
                  Colors.purple,
                ),
                if (widget.trip.userFullName != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    getLocalizations(context).userLabel,
                    widget.trip.userFullName!,
                    Icons.person,
                    Colors.teal,
                  ),
                ],
                if (widget.trip.userPhone != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    getLocalizations(context).phoneLabel,
                    widget.trip.userPhone!,
                    Icons.phone,
                    Colors.indigo,
                  ),
                ],
                const SizedBox(height: 20),
                // Start trip button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isStarting ? null : _startTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isStarting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            getLocalizations(context).startTripButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/taxi_request_model.dart';
import '../services/map_service.dart';
import '../services/driver_service.dart';
import '../services/api_service.dart';
import '../screens/driver_home_screen.dart';
import '../models/trip_model.dart';

class DriverTripDetailsScreen extends StatefulWidget {
  final TaxiRequest trip;

  const DriverTripDetailsScreen({Key? key, required this.trip})
      : super(key: key);

  @override
  _DriverTripDetailsScreenState createState() =>
      _DriverTripDetailsScreenState();
}

class _DriverTripDetailsScreenState extends State<DriverTripDetailsScreen> {
  final _mapService = MapService();
  final _driverService = DriverService(ApiService());
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Create markers for pickup and dropoff locations
      final pickupMarker = Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: widget.trip.pickupLocation,
        ),
      );

      final dropoffMarker = Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Dropoff',
          snippet: widget.trip.dropoffLocation,
        ),
      );

      // Get route details
      final routeDetails = await _mapService.getRouteDetails(
        LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
        LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng),
      );

      // Create polyline for the route using the decoded points
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: routeDetails['points'],
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(30), PatternItem.gap(20)],
        geodesic: true,
      );

      setState(() {
        _markers = {pickupMarker, dropoffMarker};
        _polylines = {polyline};
        _isLoading = false;
      });

      // Fit map bounds to show both markers
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getBounds(),
            50.0, // padding
          ),
        );
      }
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptTrip() async {
    try {
      setState(() {
        _isAccepting = true;
      });

      // Get driver profile to include driver data
      final driverProfile = await _driverService.getDriverProfile();

      // Accept the trip with driver data
      final updatedTrip = await _driverService.acceptTrip(widget.trip.id);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to driver home screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DriverHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  LatLngBounds _getBounds() {
    final pickup = LatLng(widget.trip.pickupLat, widget.trip.pickupLng);
    final dropoff = LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);
    return LatLngBounds(
      southwest: LatLng(
        pickup.latitude < dropoff.latitude ? pickup.latitude : dropoff.latitude,
        pickup.longitude < dropoff.longitude
            ? pickup.longitude
            : dropoff.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > dropoff.latitude ? pickup.latitude : dropoff.latitude,
        pickup.longitude > dropoff.longitude
            ? pickup.longitude
            : dropoff.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          LatLng(widget.trip.pickupLat, widget.trip.pickupLng),
                      zoom: 15,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngBounds(_getBounds(), 50.0),
                      );
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                  ),
                ),
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
                      _buildInfoRow(
                        'From',
                        widget.trip.pickupLocation,
                        Icons.location_on,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'To',
                        widget.trip.dropoffLocation,
                        Icons.location_on,
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Price',
                        '${widget.trip.price} IQD',
                        Icons.attach_money,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Distance',
                        '${widget.trip.distance.toStringAsFixed(1)} km',
                        Icons.straighten,
                        Colors.purple,
                      ),
                      if (widget.trip.userFullName != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'User',
                          widget.trip.userFullName!,
                          Icons.person,
                          Colors.teal,
                        ),
                      ],
                      if (widget.trip.userPhone != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Phone',
                          widget.trip.userPhone!,
                          Icons.phone,
                          Colors.indigo,
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAccepting ? null : _acceptTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isAccepting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Accept Trip',
                                  style: TextStyle(
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
        Icon(icon, color: color, size: 20),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/taxi_request_model.dart';
import '../services/map_service.dart';
import '../services/driver_service.dart';
import '../services/api_service.dart';
import '../screens/driver_home_screen.dart';
import '../models/trip_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

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
  Map<String, dynamic>? _driverBudget;
  bool _isLoadingBudget = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _loadDriverBudget();
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

  Future<void> _loadDriverBudget() async {
    try {
      setState(() {
        _isLoadingBudget = true;
      });

      final budget = await _driverService.getDriverBudget();

      if (mounted) {
        setState(() {
          _driverBudget = budget;
          _isLoadingBudget = false;
        });
      }
    } catch (e) {
      print('❌ Error loading driver budget: $e');
      if (mounted) {
        setState(() {
          _isLoadingBudget = false;
        });
      }
    }
  }

  Future<void> _acceptTrip() async {
    try {
      setState(() {
        _isAccepting = true;
      });

      // Accept the trip with driver data (includes budget checking)
      final updatedTrip = await _driverService.acceptTrip(widget.trip.id);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalizations(context).tripAcceptedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      // Use pushReplacement for smoother transition
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DriverHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show more detailed error message for budget issues
      String errorMessage =
          getLocalizations(context).errorAcceptingTrip(e.toString());
      if (e.toString().contains('Insufficient budget')) {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: getLocalizations(context).viewBudgetButton,
            textColor: Colors.white,
            onPressed: () => _showBudgetDetails(),
          ),
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

  void _showBudgetDetails() {
    if (_driverBudget != null) {
      final deductionAmount = widget.trip.price * 0.12;
      final canAfford = _driverBudget!['budget'] >= deductionAmount;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(getLocalizations(context).budgetInformationTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Budget: ${_driverBudget!['budget']} IQD'),
              const SizedBox(height: 8),
              Text('Trip Price: ${widget.trip.price} IQD'),
              const SizedBox(height: 8),
              Text(
                'Deduction (12%): ${deductionAmount.toStringAsFixed(0)} IQD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text('Driver: ${_driverBudget!['driverName']}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: canAfford
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canAfford
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      canAfford ? Icons.check_circle : Icons.error,
                      color: canAfford ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        canAfford
                            ? getLocalizations(context).canAffordTripMessage
                            : getLocalizations(context)
                                .insufficientBudgetMessage,
                        style: TextStyle(
                          color: canAfford ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(getLocalizations(context).okButton),
            ),
          ],
        ),
      );
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
        title: Text(getLocalizations(context).tripDetailsTitle),
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
                        '${widget.trip.price} IQD',
                        Icons.attach_money,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).distanceLabel,
                        '${widget.trip.distance.toStringAsFixed(1)} km',
                        Icons.straighten,
                        Colors.purple,
                      ),
                      // Budget information
                      if (_driverBudget != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 16,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    getLocalizations(context).budgetInformation,
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Budget:',
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${_driverBudget!['budget']} IQD',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Deduction (12%):',
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${(widget.trip.price * 0.12).toStringAsFixed(0)} IQD',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _driverBudget!['budget'] >=
                                          (widget.trip.price * 0.12)
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _driverBudget!['budget'] >=
                                            (widget.trip.price * 0.12)
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _driverBudget!['budget'] >=
                                              (widget.trip.price * 0.12)
                                          ? Icons.check_circle
                                          : Icons.error,
                                      size: 14,
                                      color: _driverBudget!['budget'] >=
                                              (widget.trip.price * 0.12)
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _driverBudget!['budget'] >=
                                              (widget.trip.price * 0.12)
                                          ? getLocalizations(context)
                                              .canAffordThisTripMessage
                                          : getLocalizations(context)
                                              .insufficientBudgetShortMessage,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _driverBudget!['budget'] >=
                                                (widget.trip.price * 0.12)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isAccepting ||
                                  (_driverBudget != null &&
                                      _driverBudget!['budget'] <
                                          (widget.trip.price * 0.12)))
                              ? null
                              : _acceptTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_driverBudget != null &&
                                    _driverBudget!['budget'] <
                                        (widget.trip.price * 0.12))
                                ? Colors.grey
                                : Colors.green,
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
                              : Text(
                                  (_driverBudget != null &&
                                          _driverBudget!['budget'] <
                                              (widget.trip.price * 0.12))
                                      ? getLocalizations(context)
                                          .insufficientBudgetButton
                                      : getLocalizations(context)
                                          .acceptTripButton,
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

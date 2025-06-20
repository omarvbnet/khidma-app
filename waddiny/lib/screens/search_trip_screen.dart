import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/map_service.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';
import 'package:provider/provider.dart';

class SearchTripScreen extends StatefulWidget {
  const SearchTripScreen({Key? key}) : super(key: key);

  @override
  _SearchTripScreenState createState() => _SearchTripScreenState();
}

class _SearchTripScreenState extends State<SearchTripScreen> {
  final _mapService = MapService();
  final _apiService = ApiService();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  double? _distance;
  double? _price;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _mapService.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      // Set current location as pickup location by default
      _pickupLocation = _currentLocation;
      _updatePickupAddress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _updatePickupAddress() async {
    if (_pickupLocation != null) {
      try {
        final address =
            await _mapService.getAddressFromLatLng(_pickupLocation!);
        _pickupController.text = address;
      } catch (e) {
        print('Error getting pickup address: $e');
      }
    }
  }

  Future<void> _updateDropoffAddress() async {
    if (_dropoffLocation != null) {
      try {
        final address =
            await _mapService.getAddressFromLatLng(_dropoffLocation!);
        _dropoffController.text = address;
      } catch (e) {
        print('Error getting dropoff address: $e');
      }
    }
  }

  Future<void> _searchLocation(String query, bool isPickup) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final results = await _mapService.searchPlaces(query);
      if (results.isNotEmpty) {
        final location = results[0];
        if (isPickup) {
          setState(() {
            _pickupLocation = location;
            _pickupController.text = query;
          });
        } else {
          setState(() {
            _dropoffLocation = location;
            _dropoffController.text = query;
          });
        }
        _calculateDistanceAndPrice();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateDistanceAndPrice() {
    if (_pickupLocation != null && _dropoffLocation != null) {
      final distance = Geolocator.distanceBetween(
            _pickupLocation!.latitude,
            _pickupLocation!.longitude,
            _dropoffLocation!.latitude,
            _dropoffLocation!.longitude,
          ) /
          1000; // Convert to kilometers

      setState(() {
        _distance = distance;
        _price = _calculatePrice(distance);
      });
    }
  }

  double _calculatePrice(double distance) {
    // For distances over 90km, calculate price per km
    if (distance > 90) {
      return distance * AppConstants.costPerKm;
    }

    // For distances under 90km, use the predefined ranges
    for (var entry in AppConstants.tripCosts.entries) {
      final range = entry.key.split('-');
      final min = double.parse(range[0]);
      final max = double.parse(range[1]);

      if (distance >= min && distance <= max) {
        return entry.value.toDouble();
      }
    }
    // If distance is greater than the maximum range but less than 90km
    return AppConstants.tripCosts.values.last.toDouble();
  }

  Future<void> _createTrip() async {
    if (_pickupLocation == null || _dropoffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select pickup and dropoff locations')),
      );
      return;
    }

    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both pickup and dropoff addresses')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final user = await _apiService.getUserProfile();

      if (user.status != 'ACTIVE') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Your account is not active. Please contact support.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final distance = _distance ?? 0.0;
      final price = _calculatePrice(distance);
      final driverDeduction = price * AppConstants.driverDeduction;

      final trip = await _apiService.createTaxiRequest({
        'pickupLocation': _pickupController.text,
        'dropoffLocation': _dropoffController.text,
        'price': price,
        'distance': distance,
        'pickupLat': _pickupLocation!.latitude,
        'pickupLng': _pickupLocation!.longitude,
        'dropoffLat': _dropoffLocation!.latitude,
        'dropoffLng': _dropoffLocation!.longitude,
        'status': 'USER_WAITING',
        'userId': user.id,
        'userFullName': user.fullName ?? 'Unknown',
        'userPhone': user.phoneNumber ?? 'Unknown',
        'tripType': 'ECO',
        'driverDeduction': driverDeduction,
        'userProvince': 'Baghdad',
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/trip_details',
            arguments: trip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating trip: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Trip'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon:
                      const Icon(Icons.location_on, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) => _searchLocation(value, true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dropoffController,
                decoration: InputDecoration(
                  labelText: 'Dropoff Location',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) => _searchLocation(value, false),
              ),
              const SizedBox(height: 24),
              if (_distance != null && _price != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Distance:'),
                            Text('${_distance!.toStringAsFixed(1)} km'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Price:'),
                            Text(
                              '${_price!.toStringAsFixed(0)} ${AppConstants.currency}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }
}

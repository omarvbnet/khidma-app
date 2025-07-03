import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../services/map_service.dart';
import '../services/api_service.dart';
import '../models/taxi_request_model.dart';
import '../constants/app_constants.dart';
import '../constants/api_keys.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

class UserSelectTripScreen extends StatefulWidget {
  const UserSelectTripScreen({Key? key}) : super(key: key);

  @override
  _UserSelectTripScreenState createState() => _UserSelectTripScreenState();
}

class _UserSelectTripScreenState extends State<UserSelectTripScreen> {
  final _tripService = TripService();
  final _authService = AuthService();
  final _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  String? _pickupAddress;
  String? _dropoffAddress;
  bool _isLoading = false;
  Map<String, dynamic>? _routeInfo;
  final _placesController = TextEditingController();
  final _placesFocusNode = FocusNode();
  final String _googleApiKey = ApiKeys.googleMapsApiKey;
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoadingPredictions = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _placesController.dispose();
    _placesFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current location
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _pickupLocation = _currentLocation;
      });
      _updatePickupAddress();

      // Focus camera on current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 15),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(getLocalizations(context).errorGettingCurrentLocation)),
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
      _updateMarkers();
    }
  }

  void _onMapTap(LatLng location) {
    if (_pickupLocation == null) {
      setState(() {
        _pickupLocation = location;
        _updatePickupAddress();
      });
    } else if (_dropoffLocation == null) {
      setState(() {
        _dropoffLocation = location;
        _updateDropoffAddress();
        _updateRoute();
      });
    }
    _updateMarkers();
  }

  Future<void> _updatePickupAddress() async {
    if (_pickupLocation != null) {
      try {
        final placemarks = await placemarkFromCoordinates(
          _pickupLocation!.latitude,
          _pickupLocation!.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _pickupAddress =
                '${place.street}, ${place.locality}, ${place.country}';
          });
        }
      } catch (e) {
        print('Error getting pickup address: $e');
      }
    }
  }

  Future<void> _updateDropoffAddress() async {
    if (_dropoffLocation != null) {
      try {
        final placemarks = await placemarkFromCoordinates(
          _dropoffLocation!.latitude,
          _dropoffLocation!.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _dropoffAddress =
                '${place.street}, ${place.locality}, ${place.country}';
          });
        }
      } catch (e) {
        print('Error getting dropoff address: $e');
      }
    }
  }

  Future<void> _updateRoute() async {
    if (_pickupLocation != null && _dropoffLocation != null) {
      try {
        setState(() {
          _isLoading = true;
        });

        final routeDetails = await _mapService.getRouteDetails(
          _pickupLocation!,
          _dropoffLocation!,
        );

        if (!mounted) return;

        setState(() {
          _routeInfo = routeDetails;
          _polylines = _mapService.decodePolyline(routeDetails['polyline']);
        });

        // Calculate price based on distance
        final distance = routeDetails['distance'] as String;
        final distanceInKm = double.parse(distance.replaceAll(' km', ''));
        final fare = _calculatePrice(distanceInKm);
        setState(() {
          _routeInfo = {
            ...routeDetails,
            'fare': fare,
          };
        });

        // Fit map to show entire route
        if (_mapController != null) {
          final bounds = _getBoundsForRoute();
          if (bounds != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50.0),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGettingRoute),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
              textColor: Colors.white,
              onPressed: _updateRoute,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
      // Ensure we have exactly 2 elements before accessing them
      if (range.length != 2) {
        print('Invalid range format: ${entry.key}');
        continue;
      }

      try {
        final min = double.parse(range[0]);
        final max = double.parse(range[1]);

        if (distance >= min && distance <= max) {
          return entry.value.toDouble();
        }
      } catch (e) {
        print('Error parsing range values: ${entry.key}, error: $e');
        continue;
      }
    }
    // If distance is greater than the maximum range but less than 90km
    return AppConstants.tripCosts.values.last.toDouble();
  }

  LatLngBounds? _getBoundsForRoute() {
    if (_polylines.isEmpty || _polylines.first.points.isEmpty) {
      return null;
    }

    final points = _polylines.first.points;
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _updateMarkers() {
    final markers = <Marker>{};
    if (_pickupLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
              title: _pickupAddress ??
                  AppLocalizations.of(context)!.pickupLocation),
        ),
      );
    }
    if (_dropoffLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoffLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
              title: _dropoffAddress ??
                  AppLocalizations.of(context)!.dropoffLocation),
        ),
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _createTrip() async {
    if (_pickupLocation == null || _dropoffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(getLocalizations(context)
                .pleaseSelectPickupAndDropoffLocations)),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception(getLocalizations(context).userNotAuthenticated);
      }

      // Check for any active trips
      final trips = await _tripService.getUserTrips(user['id']);
      final hasActiveTrip = trips.any((trip) {
        final status = trip.status.toUpperCase();
        return status == 'USER_WAITING' ||
            status == 'DRIVER_ACCEPTED' ||
            status == 'DRIVER_IN_WAY' ||
            status == 'USER_PICKED_UP' ||
            status == 'DRIVER_IN_PROGRESS' ||
            status == 'DRIVER_ARRIVED' ||
            status == 'DRIVER_ARRIVED_DROPOFF';
      });

      if (hasActiveTrip) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context).youAlreadyHaveAnActiveTrip),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      final distance = _routeInfo!['distance'] as String;
      final distanceInKm = double.parse(distance.replaceAll(' km', ''));
      final fare = _calculatePrice(distanceInKm);
      final driverDeduction = fare * AppConstants.driverDeduction;

      // Ensure all required fields are present
      final userFullName =
          user['fullName'] ?? user['name'] ?? getLocalizations(context).unknown;
      final userPhone = user['phoneNumber'] ??
          user['phone'] ??
          getLocalizations(context).unknown;
      final userProvince =
          user['province'] ?? getLocalizations(context).baghdad;

      if (userFullName == getLocalizations(context).unknown ||
          userPhone == getLocalizations(context).unknown) {
        throw Exception(getLocalizations(context).userProfileIsIncomplete);
      }

      final trip = await _tripService.createTrip({
        'pickupLocation': _pickupAddress,
        'dropoffLocation': _dropoffAddress,
        'pickupLat': _pickupLocation!.latitude,
        'pickupLng': _pickupLocation!.longitude,
        'dropoffLat': _dropoffLocation!.latitude,
        'dropoffLng': _dropoffLocation!.longitude,
        'price': fare,
        'distance': distanceInKm,
        'status': 'USER_WAITING',
        'tripType': 'ECO',
        'driverDeduction': driverDeduction,
        'userId': user['id'],
        'userFullName': userFullName,
        'userPhone': userPhone,
        'userProvince': userProvince,
      });

      if (!mounted) return;

      // Show success message with notification info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getLocalizations(context).tripCreatedMessage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                getLocalizations(context).notifyingAvailableDrivers,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: getLocalizations(context).viewTripButton,
            textColor: Colors.white,
            onPressed: () {
              // Navigate to trip status screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );

      // Navigate back to home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(getLocalizations(context).errorCreatingTrip(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _isLoadingPredictions = true;
      });

      // Get user's province from user data
      String? userProvince;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        userProvince = user['province'];
      }

      // Add province to search query if available
      String searchQuery = query;
      if (userProvince != null && userProvince.isNotEmpty) {
        searchQuery = '$query, $userProvince, Iraq';
      } else {
        searchQuery = '$query, Iraq';
      }

      // Use Google Places API to get predictions
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$searchQuery'
        '&key=$_googleApiKey'
        '&components=country:iq'
        '&types=geocode|establishment',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          if (mounted) {
            setState(() {
              _predictions =
                  List<Map<String, dynamic>>.from(data['predictions']);
              _isLoadingPredictions = false;
            });
          }
        } else {
          throw Exception(data['error_message'] ??
              getLocalizations(context).failedToGetPredictions);
        }
      } else {
        throw Exception(getLocalizations(context).failedToGetPredictions);
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _isLoadingPredictions = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onPlaceSelected(Map<String, dynamic> prediction) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get place details
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=${prediction['place_id']}'
          '&key=$_googleApiKey'
          '&fields=geometry,formatted_address',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final latLng = LatLng(location['lat'], location['lng']);
          final formattedAddress = data['result']['formatted_address'];

          // Get current position to check distance
          Position? currentPosition;
          try {
            currentPosition = await Geolocator.getCurrentPosition();
          } catch (e) {
            print('Error getting current position: $e');
          }

          // Check distance if we have current position
          if (currentPosition != null) {
            final distance = Geolocator.distanceBetween(
              currentPosition.latitude,
              currentPosition.longitude,
              latLng.latitude,
              latLng.longitude,
            );

            // If distance is more than 50km, show warning
            if (distance > 50000) {
              // 50km in meters
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation),
                    backgroundColor: Colors.orange[400],
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.useAnyway,
                      textColor: Colors.white,
                      onPressed: () {
                        _setDropoffLocation(latLng, formattedAddress);
                      },
                    ),
                  ),
                );
              }
              return;
            }
          }

          _setDropoffLocation(latLng, formattedAddress);
        } else {
          throw Exception(data['error_message'] ??
              AppLocalizations.of(context)!.failedToGetPlaceDetails);
        }
      } else {
        throw Exception(AppLocalizations.of(context)!.failedToGetPlaceDetails);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.errorGettingPlaceDetails),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSearching = false;
          _predictions = [];
        });
      }
    }
  }

  void _setDropoffLocation(LatLng location, String address) {
    setState(() {
      _dropoffLocation = location;
      _dropoffAddress = address;
    });
    _updateDropoffAddress();
    _updateRoute();
    _updateMarkers();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getLocalizations(context).destinationSetTo),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).createNewTripTitle),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ??
                  const LatLng(33.3152, 44.3661), // Default to Baghdad
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isSearching) _buildSearchOverlay(),
          if (!_isSearching && _routeInfo != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.tripDetails,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Distance', _routeInfo!['distance'],
                          Icons.route, Colors.blue),
                      const SizedBox(height: 8),
                      _buildInfoRow('Duration', _routeInfo!['duration'],
                          Icons.timer, Colors.orange),
                      const SizedBox(height: 8),
                      _buildInfoRow('Price', '${_routeInfo!['fare']} IQD',
                          Icons.attach_money, Colors.green),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _createTrip,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(
                                _isLoading
                                    ? getLocalizations(context)
                                        .creatingTripMessage
                                    : getLocalizations(context).bookTripButton,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _pickupLocation = _currentLocation;
                                  _dropoffLocation = null;
                                  _pickupAddress = null;
                                  _dropoffAddress = null;
                                });
                                _updateMarkers();
                                _updatePickupAddress();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                getLocalizations(context).changeTripButton,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isSearching && _routeInfo == null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getLocalizations(context).selectLocationsTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_pickupLocation != null)
                        _buildInfoRow(
                            getLocalizations(context).pickupLocationLabel,
                            _pickupAddress ??
                                getLocalizations(context).currentLocationLabel,
                            Icons.location_on,
                            Colors.green),
                      if (_dropoffLocation != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            getLocalizations(context).dropoffLocationLabel,
                            _dropoffAddress ??
                                getLocalizations(context).selectedLocationLabel,
                            Icons.location_on,
                            Colors.red),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isSearching = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.search),
                              label: Text(
                                getLocalizations(context).searchLocationButton,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _pickupLocation = _currentLocation;
                                  _dropoffLocation = null;
                                  _pickupAddress = null;
                                  _dropoffAddress = null;
                                });
                                _updateMarkers();
                                _updatePickupAddress();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                getLocalizations(context).resetButton,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _placesController,
                      focusNode: _placesFocusNode,
                      decoration: InputDecoration(
                        hintText:
                            getLocalizations(context).searchForDestination,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        if (value.length > 2) {
                          _searchLocation(value);
                        } else {
                          setState(() {
                            _predictions = [];
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _placesController.clear();
                        _predictions = [];
                      });
                    },
                  ),
                ],
              ),
            ),
            if (_isLoadingPredictions)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (_predictions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(prediction['description'] ?? ''),
                      subtitle: Text(
                        AppLocalizations.of(context)!.tapToSetAsDestination,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () => _onPlaceSelected(prediction),
                    );
                  },
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                AppLocalizations.of(context)!
                    .searchForDestinationsWithin50kmOfYourCurrentPosition,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

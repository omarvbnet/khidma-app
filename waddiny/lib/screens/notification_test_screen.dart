import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/trip_service.dart';
import '../models/trip_model.dart';
import 'dart:io' show Platform;
import 'dart:convert';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;
  Trip? _currentTrip;
  String? _deviceToken;
  final TripService _tripService = TripService();

  @override
  void initState() {
    super.initState();
    _loadCurrentTrip();
    _loadDeviceToken();
  }

  Future<void> _loadCurrentTrip() async {
    try {
      setState(() {
        _isLoading = true;
        _status = 'Loading current trip...';
      });

      // Get current user's trips
      final user = await _tripService.checkUserStatus();
      if (user != null) {
        final trips = await _tripService.getUserTrips(user.id);
        if (trips.isNotEmpty) {
          setState(() {
            _currentTrip = trips.first;
            _status = 'Current trip: ${_currentTrip!.status}';
          });
        } else {
          setState(() {
            _status = 'No active trips found';
          });
        }
      } else {
        setState(() {
          _status = 'User not authenticated';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error loading trip: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDeviceToken() async {
    try {
      final token = await NotificationService.getDeviceToken();
      setState(() {
        _deviceToken = token;
      });
    } catch (e) {
      print('Error loading device token: $e');
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing notification...';
    });

    try {
      await NotificationService.testNotification();
      setState(() {
        _status = 'Test notification sent! Check if you received it.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking permissions...';
    });

    try {
      await NotificationService.checkPermissions();
      setState(() {
        _status = 'Permissions checked. Check console for details.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking permissions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testTripNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing trip notification...';
    });

    try {
      await NotificationService.showLocalNotification(
        title: 'Driver Accepted Your Trip!',
        body:
            'A driver has accepted your trip request. They will be on their way soon.',
        payload: '{"tripId": "test123", "type": "DRIVER_ACCEPTED"}',
        id: 1001,
      );
      setState(() {
        _status = 'Trip notification sent!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCurrentTripNotification() async {
    if (_currentTrip == null) {
      setState(() {
        _status = 'No current trip to test with';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing current trip notification...';
    });

    try {
      // Test notification based on current trip status
      String title = '';
      String body = '';
      String notificationType = '';

      switch (_currentTrip!.status.toUpperCase()) {
        case 'USER_WAITING':
          title = 'Trip Request Sent';
          body =
              'Your trip request has been sent. Waiting for a driver to accept.';
          notificationType = 'USER_WAITING';
          break;
        case 'DRIVER_ACCEPTED':
          title = 'Driver Accepted Your Trip!';
          body =
              'A driver has accepted your trip request. They will be on their way soon.';
          notificationType = 'DRIVER_ACCEPTED';
          break;
        case 'DRIVER_IN_WAY':
          title = 'Driver is on the Way!';
          body = 'Your driver is heading to your pickup location.';
          notificationType = 'DRIVER_IN_WAY';
          break;
        case 'DRIVER_ARRIVED':
          title = 'Driver Has Arrived!';
          body = 'Your driver has arrived at your pickup location.';
          notificationType = 'DRIVER_ARRIVED';
          break;
        case 'USER_PICKED_UP':
          title = 'Trip Started!';
          body = 'You have been picked up. Enjoy your ride!';
          notificationType = 'USER_PICKED_UP';
          break;
        case 'DRIVER_IN_PROGRESS':
          title = 'Trip in Progress';
          body = 'Your trip is currently in progress.';
          notificationType = 'DRIVER_IN_PROGRESS';
          break;
        case 'TRIP_COMPLETED':
          title = 'Trip Completed!';
          body = 'Your trip has been completed successfully.';
          notificationType = 'TRIP_COMPLETED';
          break;
        case 'TRIP_CANCELLED':
          title = 'Trip Cancelled';
          body = 'Your trip has been cancelled.';
          notificationType = 'TRIP_CANCELLED';
          break;
        default:
          title = 'Trip Status Update';
          body =
              'Your trip status has been updated to: ${_currentTrip!.status}';
          notificationType = 'STATUS_UPDATE';
      }

      await NotificationService.showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode({
          'tripId': _currentTrip!.id,
          'type': notificationType,
          'status': _currentTrip!.status,
          'pickupLocation': _currentTrip!.pickupLocation,
          'dropoffLocation': _currentTrip!.dropoffLocation,
        }),
        id: 1002,
      );

      setState(() {
        _status =
            'Current trip notification sent! Status: ${_currentTrip!.status}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAllTripNotifications() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing all trip notifications...';
    });

    try {
      // Test all possible trip status notifications
      final statuses = [
        'USER_WAITING',
        'DRIVER_ACCEPTED',
        'DRIVER_IN_WAY',
        'DRIVER_ARRIVED',
        'USER_PICKED_UP',
        'DRIVER_IN_PROGRESS',
        'TRIP_COMPLETED',
        'TRIP_CANCELLED',
      ];

      for (int i = 0; i < statuses.length; i++) {
        final status = statuses[i];
        String title = '';
        String body = '';

        switch (status) {
          case 'USER_WAITING':
            title = 'Trip Request Sent';
            body =
                'Your trip request has been sent. Waiting for a driver to accept.';
            break;
          case 'DRIVER_ACCEPTED':
            title = 'Driver Accepted Your Trip!';
            body =
                'A driver has accepted your trip request. They will be on their way soon.';
            break;
          case 'DRIVER_IN_WAY':
            title = 'Driver is on the Way!';
            body = 'Your driver is heading to your pickup location.';
            break;
          case 'DRIVER_ARRIVED':
            title = 'Driver Has Arrived!';
            body = 'Your driver has arrived at your pickup location.';
            break;
          case 'USER_PICKED_UP':
            title = 'Trip Started!';
            body = 'You have been picked up. Enjoy your ride!';
            break;
          case 'DRIVER_IN_PROGRESS':
            title = 'Trip in Progress';
            body = 'Your trip is currently in progress.';
            break;
          case 'TRIP_COMPLETED':
            title = 'Trip Completed!';
            body = 'Your trip has been completed successfully.';
            break;
          case 'TRIP_CANCELLED':
            title = 'Trip Cancelled';
            body = 'Your trip has been cancelled.';
            break;
        }

        await NotificationService.showLocalNotification(
          title: title,
          body: body,
          payload: jsonEncode({
            'tripId': _currentTrip?.id ?? 'test123',
            'type': status,
            'status': status,
          }),
          id: 2000 + i,
        );

        // Wait a bit between notifications
        await Future.delayed(Duration(milliseconds: 500));
      }

      setState(() {
        _status = 'All trip notifications sent! Check your notification panel.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testForceNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing force notification...';
    });

    try {
      await NotificationService.forceNotification(
        title: '🚨 URGENT: Test Notification',
        body:
            'This is a high-priority test notification. If you see this, notifications are working!',
        payload: jsonEncode({
          'type': 'FORCE_TEST',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        id: 9999,
      );

      setState(() {
        _status = 'Force notification sent! Check your device immediately.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDeviceToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing device token...';
    });

    try {
      final token = await NotificationService.getDeviceToken();
      setState(() {
        _deviceToken = token;
        _status = 'Device token: ${token ?? "Not available"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform: ${Platform.isIOS ? "iOS" : "Android"}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_currentTrip != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Trip Info:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text('ID: ${_currentTrip!.id}'),
                            Text('Status: ${_currentTrip!.status}'),
                            Text('Pickup: ${_currentTrip!.pickupLocation}'),
                            Text('Dropoff: ${_currentTrip!.dropoffLocation}'),
                            if (_currentTrip!.driverName != null)
                              Text('Driver: ${_currentTrip!.driverName}'),
                          ],
                        ),
                      ),
                    ],
                    if (_deviceToken != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Token:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _deviceToken!,
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadCurrentTrip,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Trip Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkPermissions,
              icon: const Icon(Icons.security),
              label: const Text('Check Permissions'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Test Basic Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testTripNotification,
              icon: const Icon(Icons.directions_car),
              label: const Text('Test Trip Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCurrentTripNotification,
              icon: const Icon(Icons.directions_car),
              label: const Text('Test Current Trip Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testAllTripNotifications,
              icon: const Icon(Icons.directions_car),
              label: const Text('Test All Trip Notifications'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testForceNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Test Force Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDeviceToken,
              icon: const Icon(Icons.notifications),
              label: const Text('Test Device Token'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            if (Platform.isIOS) ...[
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'iOS Troubleshooting Tips:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Make sure notifications are enabled in iOS Settings\n'
                        '2. Check if "Do Not Disturb" is enabled\n'
                        '3. Verify app has notification permissions\n'
                        '4. Try testing in different app states (foreground/background)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const Card(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 NOTIFICATION TROUBLESHOOTING GUIDE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'If notifications are not working:\n\n'
                      '1. 📱 Check Device Settings:\n'
                      '   • Go to Settings > Notifications > Waddiny\n'
                      '   • Enable "Allow Notifications"\n'
                      '   • Enable "Alert", "Badge", and "Sound"\n\n'
                      '2. 🔕 Check Do Not Disturb:\n'
                      '   • Go to Settings > Focus > Do Not Disturb\n'
                      '   • Make sure it\'s OFF or Waddiny is allowed\n\n'
                      '3. 🔄 Test Different States:\n'
                      '   • Try with app in foreground\n'
                      '   • Try with app in background\n'
                      '   • Try with app completely closed\n\n'
                      '4. 🚨 Use Force Notification:\n'
                      '   • Tap "Test Force Notification" above\n'
                      '   • This uses maximum priority settings\n\n'
                      '5. 📞 Check Console Logs:\n'
                      '   • Look for "✅" success messages\n'
                      '   • Look for "❌" error messages',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

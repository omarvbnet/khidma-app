import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';
import '../services/trip_service.dart';
import '../constants/api_constants.dart';
import '../models/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final TripService _tripService = TripService();
  Trip? _currentTrip;
  bool _isLoading = false;
  String _deviceToken = '';
  String _fcmToken = '';
  String _notificationStatus = '';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentTrip();
    _loadDeviceTokens();
  }

  Future<void> _loadCurrentTrip() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null) {
        final response = await _tripService.getUserTrips(userId);
        if (response.isNotEmpty) {
          setState(() {
            _currentTrip = response.first;
          });
        }
      }
    } catch (e) {
      _addLog('❌ Error loading trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDeviceTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceToken = prefs.getString('device_token') ?? 'Not found';
      _fcmToken = prefs.getString('fcm_token') ?? 'Not found';
      setState(() {});
    } catch (e) {
      _addLog('❌ Error loading device tokens: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      final now = DateTime.now();
      final timeString = now.toString();
      // Safely extract time part (HH:MM:SS)
      String timePart;
      try {
        if (timeString.length >= 19) {
          timePart = timeString.substring(11, 19);
        } else {
          timePart =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        timePart =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      }

      _logs.add('$timePart: $message');
      if (_logs.length > 20) {
        _logs.removeAt(0);
      }
    });
  }

  Future<void> _testLocalNotification() async {
    _addLog('🔔 Testing local notification...');
    try {
      await NotificationService.showLocalNotification(
        title: 'Test Notification',
        body: 'This is a test local notification!',
        payload: '{"type": "test", "message": "Local notification test"}',
      );
      _addLog('✅ Local notification sent successfully');
    } catch (e) {
      _addLog('❌ Local notification failed: $e');
    }
  }

  Future<void> _testFirebaseNotification() async {
    _addLog('🔥 Testing Firebase notification...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');

      if (token == null || token.isEmpty) {
        _addLog('❌ No FCM token available');
        return;
      }

      // Send test notification via Firebase
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/send-simple'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
        body: jsonEncode({
          'title': 'Firebase Test',
          'body': 'This is a Firebase push notification test!',
          'deviceToken': token,
          'data': {'type': 'test', 'message': 'Firebase notification test'}
        }),
      );

      if (response.statusCode == 200) {
        _addLog('✅ Firebase notification sent successfully');
        final responseData = jsonDecode(response.body);
        _addLog('Response: ${responseData['message']}');
      } else {
        _addLog('❌ Firebase notification failed: ${response.statusCode}');
        _addLog('Response: ${response.body}');
      }
    } catch (e) {
      _addLog('❌ Firebase notification error: $e');
    }
  }

  Future<void> _testTripStatusNotification() async {
    if (_currentTrip == null) {
      _addLog('❌ No current trip available');
      return;
    }

    _addLog('🚕 Testing trip status notification...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('fcm_token') ?? prefs.getString('device_token');

      if (token == null || token.isEmpty) {
        _addLog('❌ No device token available');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
        body: jsonEncode({
          'userId': prefs.getString('user_id'),
          'title': 'Trip Status Update',
          'message':
              'Your trip status has been updated to: ${_currentTrip!.status}',
          'type': 'TRIP_STATUS',
          'data': {
            'tripId': _currentTrip!.id,
            'status': _currentTrip!.status,
            'type': 'trip_status'
          }
        }),
      );

      if (response.statusCode == 200) {
        _addLog('✅ Trip status notification sent successfully');
        final responseData = jsonDecode(response.body);
        _addLog('Response: ${responseData['success']}');
      } else {
        _addLog('❌ Trip status notification failed: ${response.statusCode}');
        _addLog('Response: ${response.body}');
      }
    } catch (e) {
      _addLog('❌ Trip status notification error: $e');
    }
  }

  Future<void> _checkDriverStatus() async {
    _addLog('👥 Checking driver status...');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/test-drivers-simple'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _addLog('✅ Driver status check completed');
        _addLog('Total drivers: ${responseData['totalDrivers']}');
        _addLog('Active drivers: ${responseData['activeDrivers']}');
        _addLog('Available drivers: ${responseData['availableDrivers']}');
        _addLog('Drivers with tokens: ${responseData['driversWithTokens']}');

        // Show details for each driver
        if (responseData['driverDetails'] != null) {
          _addLog('📋 Driver Details:');
          for (final driver in responseData['driverDetails']) {
            _addLog(
                '- ${driver['name']}: ${driver['status']} | Available: ${driver['isAvailable']} | Token: ${driver['hasDeviceToken'] ? 'Yes' : 'No'}');
          }
        }
      } else {
        _addLog('❌ Driver status check failed: ${response.statusCode}');
        _addLog('Response: ${response.body}');
      }
    } catch (e) {
      _addLog('❌ Driver status check error: $e');
    }
  }

  Future<void> _testDriverNotification() async {
    _addLog('🚕 Testing driver notification...');
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try the simple endpoint first (no auth required)
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/test-drivers-simple'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _addLog('✅ Driver notification test sent');
        final responseData = jsonDecode(response.body);
        _addLog('Response: ${responseData['message']}');
        _addLog('Available drivers: ${responseData['availableDrivers']}');
        _addLog('Notifications sent: ${responseData['notificationsSent']}');
        _addLog('Notifications failed: ${responseData['notificationsFailed']}');
      } else {
        _addLog('❌ Driver notification test failed: ${response.statusCode}');
        _addLog('Response: ${response.body}');

        // Try the authenticated endpoint as fallback
        final token = prefs.getString('token');
        if (token != null) {
          _addLog('🔄 Trying authenticated endpoint...');
          final authResponse = await http.post(
            Uri.parse('${ApiConstants.baseUrl}/notifications/test-drivers'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (authResponse.statusCode == 200) {
            _addLog('✅ Driver notification test sent (authenticated)');
            final authResponseData = jsonDecode(authResponse.body);
            _addLog('Response: ${authResponseData['message']}');
          } else {
            _addLog(
                '❌ Authenticated endpoint also failed: ${authResponse.statusCode}');
            _addLog('Response: ${authResponse.body}');
          }
        }
      }
    } catch (e) {
      _addLog('❌ Driver notification test error: $e');
    }
  }

  Future<void> _checkNotificationPermissions() async {
    _addLog('🔐 Checking notification permissions...');
    try {
      final hasPermissions =
          await NotificationService.checkNotificationPermissions();
      _addLog(
          '✅ Permission check completed: ${hasPermissions ? "Granted" : "Not Granted"}');
    } catch (e) {
      _addLog('❌ Permission check failed: $e');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    _addLog('🔐 Requesting notification permissions...');
    try {
      final hasPermissions =
          await NotificationService.checkNotificationPermissions();
      _addLog(
          '✅ Permission request completed: ${hasPermissions ? "Granted" : "Not Granted"}');
    } catch (e) {
      _addLog('❌ Permission request failed: $e');
    }
  }

  Future<void> _refreshDeviceToken() async {
    _addLog('🔄 Refreshing device token...');
    try {
      final token = await NotificationService.getDeviceToken();
      if (token != null) {
        final tokenPreview =
            token.length > 20 ? '${token.substring(0, 20)}...' : token;
        _addLog('✅ New device token: $tokenPreview');
        await _loadDeviceTokens();
      } else {
        _addLog('❌ Failed to get new device token');
      }
    } catch (e) {
      _addLog('❌ Error refreshing device token: $e');
    }
  }

  Future<void> _forceNotification() async {
    _addLog('🚨 Testing force notification...');
    try {
      await NotificationService.forceNotification(
        title: 'Force Test',
        body: 'This is a force notification test!',
        payload: '{"type": "force_test"}',
      );
      _addLog('✅ Force notification sent');
    } catch (e) {
      _addLog('❌ Force notification failed: $e');
    }
  }

  Future<void> _comprehensiveNotificationCheck() async {
    _addLog('🔍 Starting comprehensive notification check...');
    try {
      final results = await NotificationService.checkNotificationSystem();

      _addLog('✅ Comprehensive check completed');
      _addLog('Firebase initialized: ${results['firebaseInitialized']}');
      _addLog('Has device token: ${results['hasDeviceToken']}');
      _addLog('Has permissions: ${results['hasPermissions']}');
      _addLog(
          'Local notifications ready: ${results['localNotificationsReady']}');
      _addLog('Platform: ${results['platform']}');

      // Server connectivity
      if (results['serverConnectivity'] != null) {
        final connectivity = results['serverConnectivity'];
        _addLog('Server connectivity: ${connectivity['status']}');
        _addLog('Can connect: ${connectivity['canConnect']}');
      }

      // Token registration
      if (results['tokenRegistration'] != null) {
        final registration = results['tokenRegistration'];
        _addLog('Token registration: ${registration['status']}');
        _addLog('Registered: ${registration['registered']}');
      }

      // Platform-specific settings
      if (results['iosSettings'] != null) {
        final iosSettings = results['iosSettings'];
        _addLog('iOS Authorization: ${iosSettings['authorizationStatus']}');
        _addLog('iOS Alert: ${iosSettings['alert']}');
        _addLog('iOS Badge: ${iosSettings['badge']}');
        _addLog('iOS Sound: ${iosSettings['sound']}');
      }

      if (results['androidSettings'] != null) {
        final androidSettings = results['androidSettings'];
        _addLog('Android Platform: ${androidSettings['platform']}');
        _addLog('Has trip channel: ${androidSettings['hasTripChannel']}');
        _addLog('Has urgent channel: ${androidSettings['hasUrgentChannel']}');
      }
    } catch (e) {
      _addLog('❌ Comprehensive check failed: $e');
    }
  }

  Future<void> _testNotificationWithDetails() async {
    _addLog('🧪 Testing notification with detailed analysis...');
    try {
      final results = await NotificationService.testNotificationWithDetails(
        title: 'Detailed Test',
        body: 'This is a comprehensive notification test',
        payload: '{"type": "detailed_test", "timestamp": "${DateTime.now()}"}',
      );

      _addLog('✅ Detailed test completed');
      _addLog('Success: ${results['success']}');

      if (results['localNotification'] != null) {
        _addLog('Local notification: ${results['localNotification']}');
      }

      if (results['firebaseNotification'] != null) {
        final firebase = results['firebaseNotification'];
        _addLog(
            'Firebase notification: ${firebase['success'] ? "Success" : "Failed"}');
        if (!firebase['success']) {
          _addLog('Firebase error: ${firebase['error']}');
        }
      }

      if (results['systemCheck'] != null) {
        final systemCheck = results['systemCheck'];
        _addLog('System check - Permissions: ${systemCheck['hasPermissions']}');
        _addLog(
            'System check - Device token: ${systemCheck['hasDeviceToken']}');
      }
    } catch (e) {
      _addLog('❌ Detailed test failed: $e');
    }
  }

  Future<void> _getNotificationStatus() async {
    _addLog('📊 Getting notification status...');
    try {
      final status = await NotificationService.getNotificationStatus();

      _addLog('✅ Status retrieved');
      _addLog('Initialized: ${status['isInitialized']}');
      _addLog('Platform: ${status['platform']}');
      _addLog('Permissions: ${status['permissions']}');
      _addLog('Firebase ready: ${status['firebaseReady']}');
      _addLog(
          'Local notifications ready: ${status['localNotificationsReady']}');
      _addLog('User token: ${status['userToken']}');

      if (status['deviceToken'] != null) {
        final token = status['deviceToken'];
        final preview =
            token.length > 20 ? '${token.substring(0, 20)}...' : token;
        _addLog('Device token: $preview');
      } else {
        _addLog('Device token: None');
      }
    } catch (e) {
      _addLog('❌ Status check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Device Token Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Tokens',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Device Token: ${_deviceToken.isEmpty ? 'Not found' : _deviceToken.length > 20 ? '${_deviceToken.substring(0, 20)}...' : _deviceToken}'),
                    Text(
                        'FCM Token: ${_fcmToken.isEmpty ? 'Not found' : _fcmToken.length > 20 ? '${_fcmToken.substring(0, 20)}...' : _fcmToken}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshDeviceToken,
                      child: const Text('Refresh Token'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Trip Information
            if (_currentTrip != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${_currentTrip!.id}'),
                      Text('Status: ${_currentTrip!.status}'),
                      Text('From: ${_currentTrip!.pickupLocation}'),
                      Text('To: ${_currentTrip!.dropoffLocation}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Local Notification Test
                    ElevatedButton.icon(
                      onPressed: _testLocalNotification,
                      icon: const Icon(Icons.notifications),
                      label: const Text('Test Local Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Firebase Notification Test
                    ElevatedButton.icon(
                      onPressed: _testFirebaseNotification,
                      icon: const Icon(Icons.cloud),
                      label: const Text('Test Firebase Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Trip Status Notification Test
                    if (_currentTrip != null)
                      ElevatedButton.icon(
                        onPressed: _testTripStatusNotification,
                        icon: const Icon(Icons.local_taxi),
                        label: const Text('Test Trip Status Notification'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Comprehensive Notification Check
                    ElevatedButton.icon(
                      onPressed: _comprehensiveNotificationCheck,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Comprehensive Check'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Detailed Notification Test
                    ElevatedButton.icon(
                      onPressed: _testNotificationWithDetails,
                      icon: const Icon(Icons.science),
                      label: const Text('Detailed Test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Get Notification Status
                    ElevatedButton.icon(
                      onPressed: _getNotificationStatus,
                      icon: const Icon(Icons.info),
                      label: const Text('Get Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Driver Status Check
                    ElevatedButton.icon(
                      onPressed: _checkDriverStatus,
                      icon: const Icon(Icons.people),
                      label: const Text('Check Driver Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Driver Notification Test
                    ElevatedButton.icon(
                      onPressed: _testDriverNotification,
                      icon: const Icon(Icons.person),
                      label: const Text('Test Driver Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Permission Tests
                    ElevatedButton.icon(
                      onPressed: _checkNotificationPermissions,
                      icon: const Icon(Icons.security),
                      label: const Text('Check Permissions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ElevatedButton.icon(
                      onPressed: _requestNotificationPermissions,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Request Permissions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Logs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Test Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _logs.clear()),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              _logs[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Troubleshooting Guide
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Troubleshooting Guide',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If notifications are not working:\n'
                      '1. Check device settings for notification permissions\n'
                      '2. Ensure Firebase is properly configured\n'
                      '3. Verify device token is being sent to server\n'
                      '4. Check server logs for notification delivery\n'
                      '5. Test with both local and Firebase notifications',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
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
        Uri.parse('${ApiConstants.baseUrl}/api/notifications/send-simple'),
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
        Uri.parse('${ApiConstants.baseUrl}/api/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
        body: jsonEncode({
          'userId': prefs.getString('user_id'),
          'title': 'Trip Status Update',
          'body':
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
      } else {
        _addLog('❌ Trip status notification failed: ${response.statusCode}');
        _addLog('Response: ${response.body}');
      }
    } catch (e) {
      _addLog('❌ Trip status notification error: $e');
    }
  }

  Future<void> _checkNotificationPermissions() async {
    _addLog('🔐 Checking notification permissions...');
    try {
      await NotificationService.checkPermissions();
      _addLog('✅ Permission check completed');
    } catch (e) {
      _addLog('❌ Permission check failed: $e');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    _addLog('🔐 Requesting notification permissions...');
    try {
      await NotificationService.checkPermissions();
      _addLog('✅ Permission request completed');
    } catch (e) {
      _addLog('❌ Permission request failed: $e');
    }
  }

  Future<void> _refreshDeviceToken() async {
    _addLog('🔄 Refreshing device token...');
    try {
      final token = await NotificationService.getDeviceToken();
      if (token != null) {
        _addLog('✅ New device token: ${token.substring(0, 20)}...');
        await _loadDeviceTokens();
      } else {
        _addLog('❌ Failed to get new device token');
      }
    } catch (e) {
      _addLog('❌ Error refreshing device token: $e');
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
                        'Device Token: ${_deviceToken.isEmpty ? 'Not found' : '${_deviceToken.substring(0, 20)}...'}'),
                    Text(
                        'FCM Token: ${_fcmToken.isEmpty ? 'Not found' : '${_fcmToken.substring(0, 20)}...'}'),
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

                    // Permission Tests
                    ElevatedButton.icon(
                      onPressed: _checkNotificationPermissions,
                      icon: const Icon(Icons.security),
                      label: const Text('Check Permissions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
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

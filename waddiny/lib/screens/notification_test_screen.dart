import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'dart:io' show Platform;

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;

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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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

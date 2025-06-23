import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({Key? key}) : super(key: key);

  @override
  _NotificationDebugScreenState createState() =>
      _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _testResults;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification System Test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will test all aspects of the notification system including Firebase, local notifications, and server connectivity.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _runComprehensiveTest,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Run Comprehensive Test'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                    ],
                  ),
                ),
              ),
            if (_testResults != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Timestamp: ${_testResults!['timestamp']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      ..._buildTestResults(),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Tests',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testLocalNotification,
                            child: const Text('Test Local'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testFirebaseNotification,
                            child: const Text('Test Firebase'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkPermissions,
                            child: const Text('Check Permissions'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _getDeviceToken,
                            child: const Text('Get Token'),
                          ),
                        ),
                      ],
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

  List<Widget> _buildTestResults() {
    final tests = _testResults!['tests'] as Map<String, dynamic>;
    final widgets = <Widget>[];

    tests.forEach((testName, testResult) {
      final isSuccess = testResult is Map && testResult['success'] == true;

      widgets.add(
        Card(
          color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      testName.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (testResult is Map) ...[
                  ...testResult.entries.map((entry) {
                    if (entry.key == 'success') return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }),
                ] else ...[
                  Text(
                    testResult.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      );

      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }

  Future<void> _runComprehensiveTest() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _testResults = null;
    });

    try {
      final results = await NotificationService.comprehensiveNotificationTest();
      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _testLocalNotification() async {
    try {
      await NotificationService.showLocalNotification(
        title: 'Local Test',
        body: 'This is a local notification test',
        payload: '{"type": "local_test"}',
        id: 1001,
      );
      _showSnackBar('Local notification sent!', Colors.green);
    } catch (e) {
      _showSnackBar('Local notification failed: $e', Colors.red);
    }
  }

  Future<void> _testFirebaseNotification() async {
    try {
      final deviceToken = await NotificationService.getDeviceToken();
      if (deviceToken == null) {
        _showSnackBar('No device token available', Colors.orange);
        return;
      }

      // This will trigger a Firebase notification through the server
      await NotificationService.testNotificationWithDetails(
        title: 'Firebase Test',
        body: 'This is a Firebase notification test',
        payload: '{"type": "firebase_test"}',
        id: 1002,
      );
      _showSnackBar('Firebase notification test completed!', Colors.green);
    } catch (e) {
      _showSnackBar('Firebase notification failed: $e', Colors.red);
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermissions =
          await NotificationService.checkNotificationPermissions();
      _showSnackBar(
        'Permissions: ${hasPermissions ? "Granted" : "Not Granted"}',
        hasPermissions ? Colors.green : Colors.red,
      );
    } catch (e) {
      _showSnackBar('Permission check failed: $e', Colors.red);
    }
  }

  Future<void> _getDeviceToken() async {
    try {
      final token = await NotificationService.getDeviceToken();
      if (token != null) {
        _showSnackBar('Token: ${token.substring(0, 20)}...', Colors.green);
      } else {
        _showSnackBar('No device token available', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Token retrieval failed: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

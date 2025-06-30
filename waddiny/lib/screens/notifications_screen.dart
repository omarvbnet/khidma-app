import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../constants/api_constants.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 20;
  String _userRole = 'USER';
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('user_role') ?? 'USER';
    final isDriver = await NotificationService.isCurrentUserDriver();

    setState(() {
      _userRole = userRole;
      _isDriver = isDriver;
    });
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _offset = 0;
        _notifications.clear();
      });
    }

    try {
      final notifications = await NotificationService.getUserNotifications(
        limit: _limit,
        offset: _offset,
      );

      // Validate notifications data
      final validNotifications = notifications.where((notification) {
        try {
          // Check if required fields exist
          final hasId = notification['id'] != null;
          final hasTitle = notification['title'] != null;
          final hasMessage = notification['message'] != null;

          return hasId && hasTitle && hasMessage;
        } catch (e) {
          print('Error validating notification: $e');
          return false;
        }
      }).toList();

      setState(() {
        if (refresh) {
          _notifications = validNotifications;
        } else {
          _notifications.addAll(validNotifications);
        }
        _offset += _limit;
        _hasMore = validNotifications.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await NotificationService.markNotificationsAsRead(
        notificationIds: [notificationId],
      );

      // Update local state
      setState(() {
        final index =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking notification as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markNotificationsAsRead(markAllAsRead: true);

      // Update local state
      setState(() {
        for (var notification in _notifications) {
          notification['isRead'] = true;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking all notifications as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'DRIVER_ACCEPTED':
        return '🚗';
      case 'DRIVER_ARRIVED':
        return '📍';
      case 'USER_PICKED_UP':
        return '✅';
      case 'TRIP_COMPLETED':
        return '🎉';
      case 'TRIP_CANCELLED':
        return '❌';
      case 'NEW_TRIP_AVAILABLE':
        return '🆕';
      default:
        return '📱';
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'DRIVER_ACCEPTED':
        return Colors.blue;
      case 'DRIVER_ARRIVED':
        return Colors.green;
      case 'USER_PICKED_UP':
        return Colors.teal;
      case 'TRIP_COMPLETED':
        return Colors.green;
      case 'TRIP_CANCELLED':
        return Colors.red;
      case 'NEW_TRIP_AVAILABLE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _testNotificationFiltering() async {
    try {
      print('\n🧪 TESTING NOTIFICATION FILTERING');
      print('=====================================');

      final userRole = await NotificationService.getCurrentUserRole();
      final isDriver = await NotificationService.isCurrentUserDriver();

      print('👤 User Role: $userRole');
      print('🚗 Is Driver: $isDriver');

      // Test notification system status
      final status = await NotificationService.getNotificationStatus();
      print('📱 Notification Status: $status');

      // Simulate receiving a new trip notification
      print('\n🧪 SIMULATING NEW TRIP NOTIFICATION');

      // Create a mock Firebase message
      final mockMessage = RemoteMessage(
        data: {
          'type': 'NEW_TRIP_AVAILABLE',
          'tripId': 'test_trip_123',
          'pickupLocation': 'Test Pickup',
          'dropoffLocation': 'Test Dropoff',
          'fare': '2000',
        },
        notification: RemoteNotification(
          title: 'New Trip Available!',
          body:
              'A new trip request is available in your area. Tap to view details.',
        ),
      );

      // Manually call the filtering method
      print('🎯 Testing role-based filtering...');
      await _testRoleBasedFiltering(mockMessage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'User Role: $userRole, Is Driver: $isDriver\nCheck console for detailed logs'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ Error testing notification filtering: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testRoleBasedFiltering(RemoteMessage message) async {
    try {
      print('\n🎯 TESTING ROLE-BASED FILTERING');
      print('=====================================');

      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('user_role') ?? 'USER';

      print('👤 Current user role: $userRole');
      print('📨 Message type: ${message.data['type']}');

      // Check if this is a new trip notification
      final isNewTripNotification =
          message.data['type'] == 'NEW_TRIP_AVAILABLE' ||
              message.data['type'] == 'NEW_TRIPS_AVAILABLE' ||
              message.data['type'] == 'trip_created' ||
              message.data['type'] == 'new_trip';

      print('🔍 Is new trip notification: $isNewTripNotification');

      if (isNewTripNotification) {
        if (userRole == 'DRIVER') {
          print('✅ WOULD SHOW notification to DRIVER');
        } else {
          print('❌ WOULD BLOCK notification for USER');
        }
      } else {
        print('ℹ️ Non-trip notification - would show to all users');
      }

      print('=====================================');
    } catch (e) {
      print('❌ Error in role-based filtering test: $e');
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      final isDriver = await NotificationService.isCurrentUserDriver();
      final title =
          isDriver ? 'Test Driver Notification' : 'Test User Notification';
      final body = isDriver
          ? 'This is a test notification for drivers'
          : 'This is a test notification for users';

      await NotificationService.showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode({
          'type': 'test_notification',
          'userRole': _userRole,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        id: 9999,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testBackendNotification() async {
    try {
      print('\n🧪 TESTING BACKEND NOTIFICATION');
      print('=====================================');

      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');
      final deviceToken = prefs.getString('fcm_token');
      final userRole = prefs.getString('user_role') ?? 'USER';

      print('👤 User Role: $userRole');
      print('🔑 User Token: ${userToken != null ? "Present" : "Missing"}');
      print('📱 Device Token: ${deviceToken != null ? "Present" : "Missing"}');

      if (userToken == null || deviceToken == null) {
        print('❌ Missing tokens - cannot test backend notification');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Missing tokens - cannot test backend notification'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Send a test notification to the current user
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/flutter/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'userId': 'self', // Send to self
          'type': 'TEST_NOTIFICATION',
          'title': 'Test Notification',
          'message':
              'This is a test notification to verify the system is working',
          'data': {
            'type': 'TEST_NOTIFICATION',
            'timestamp': DateTime.now().toIso8601String(),
          },
          'deviceToken': deviceToken,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Test notification sent successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Test notification sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Failed to send test notification: ${response.statusCode}');
        print('Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to send test notification: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error testing backend notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing backend notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotificationToSelf() async {
    try {
      print('\n🧪 SENDING TEST NOTIFICATION TO SELF');
      print('=====================================');

      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');
      final userRole = prefs.getString('user_role') ?? 'USER';

      print('👤 User Role: $userRole');
      print('🔑 User Token: ${userToken != null ? "Present" : "Missing"}');

      if (userToken == null) {
        print('❌ Missing user token - cannot send test notification');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Missing user token - cannot send test notification'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Send a test notification to the current user
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'userId': 'self', // Send to self
          'type': 'TEST_NOTIFICATION',
          'title': 'Test Notification',
          'message':
              'This is a test notification to verify the system is working',
          'data': {
            'type': 'TEST_NOTIFICATION',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Test notification sent successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Test notification sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Failed to send test notification: ${response.statusCode}');
        print('Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to send test notification: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending test notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadNotifications(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('User Role: $_userRole'),
                  Text('Is Driver: $_isDriver'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _testNotificationFiltering,
                          child: const Text('Test Filtering'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _sendTestNotification,
                          child: const Text('Send Test'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _testBackendNotification,
                          child: const Text('Test Backend'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _sendTestNotificationToSelf,
                          child: const Text('Test Self'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadNotifications(refresh: true),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notifications.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _notifications.length) {
                              return _buildLoadMoreButton();
                            }

                            final notification = _notifications[index];
                            final isRead = notification['isRead'] ?? false;
                            final type =
                                notification['type'] ?? 'TRIP_STATUS_CHANGE';
                            final title = notification['title'] ?? '';
                            final message = notification['message'] ?? '';

                            // Safely parse the createdAt date
                            DateTime createdAt;
                            try {
                              final createdAtStr =
                                  notification['createdAt']?.toString();
                              if (createdAtStr != null &&
                                  createdAtStr.isNotEmpty) {
                                createdAt = DateTime.parse(createdAtStr);
                              } else {
                                createdAt = DateTime.now();
                              }
                            } catch (e) {
                              print('Error parsing notification date: $e');
                              createdAt = DateTime.now();
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              color:
                                  isRead ? null : Colors.blue.withOpacity(0.1),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getNotificationColor(type),
                                  child: Text(
                                    _getNotificationIcon(type),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(message),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: isRead
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () =>
                                            _markAsRead(notification['id']),
                                        tooltip: 'Mark as read',
                                      ),
                                onTap: () {
                                  if (!isRead) {
                                    _markAsRead(notification['id']);
                                  }
                                  // Handle notification tap - could navigate to trip details
                                  final data = notification['data'];
                                  if (data != null && data['tripId'] != null) {
                                    // Navigate to trip details
                                    print(
                                        'Navigate to trip: ${data['tripId']}');
                                  }
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: _hasMore ? _loadNotifications : null,
          child: Text(_hasMore ? 'Load More' : 'No More Notifications'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

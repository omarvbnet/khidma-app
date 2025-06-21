import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadNotifications();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
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
                      final type = notification['type'] ?? 'TRIP_STATUS_CHANGE';
                      final title = notification['title'] ?? '';
                      final message = notification['message'] ?? '';

                      // Safely parse the createdAt date
                      DateTime createdAt;
                      try {
                        final createdAtStr =
                            notification['createdAt']?.toString();
                        if (createdAtStr != null && createdAtStr.isNotEmpty) {
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
                        color: isRead ? null : Colors.blue.withOpacity(0.1),
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
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
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
                              print('Navigate to trip: ${data['tripId']}');
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _loadNotifications(),
        child: const Text('Load More'),
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

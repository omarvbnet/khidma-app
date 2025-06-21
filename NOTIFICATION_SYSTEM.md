# Notification System Implementation

## Overview

This document describes the notification system implemented for the Khidma taxi booking app. The system provides real-time notifications for both users and drivers based on trip status changes and new trip availability.

## Features

### For Users
- **Trip Status Notifications**: Receive notifications when:
  - Driver accepts the trip
  - Driver is on the way
  - Driver has arrived
  - Trip starts (user picked up)
  - Trip is completed
  - Trip is cancelled

### For Drivers
- **Trip Status Notifications**: Receive notifications when:
  - Trip is accepted
  - Heading to pickup
  - Arrived at pickup
  - Passenger picked up
  - Trip completed
  - Trip cancelled
- **New Trip Notifications**: Receive notifications when new trips are available in their area

## Implementation Details

### Backend (Next.js)

#### 1. Notification Endpoints

**Notification Sender** (`/api/notifications/send`)
- Stores notifications in the database using Prisma
- Accepts: userId, type, title, message, data
- Returns success response with created notification

**Trip Status Update Integration** (`/api/flutter/driver/trips`)
- Automatically creates notifications when trip status changes
- Sends notifications to both users and drivers

**Notification Management** (`/api/flutter/notifications`)
- GET: Fetch user notifications with pagination
- PATCH: Mark notifications as read

#### 2. Database Schema

The system uses a `Notification` model with the following structure:
```prisma
model Notification {
  id        String           @id @default(cuid())
  userId    String
  type      NotificationType
  title     String
  message   String
  data      Json?
  isRead    Boolean          @default(false)
  createdAt DateTime         @default(now())
  user      User             @relation(fields: [userId], references: [id])
}

enum NotificationType {
  TRIP_STATUS_CHANGE
  DRIVER_ACCEPTED
  DRIVER_ARRIVED
  USER_PICKED_UP
  TRIP_COMPLETED
  NEW_TRIP_AVAILABLE
  TRIP_CANCELLED
  SYSTEM_MESSAGE
}
```

### Frontend (Flutter)

#### 1. Notification Service (`lib/services/notification_service.dart`)

**Key Features:**
- Local notification display using `flutter_local_notifications`
- Server notification sending
- Trip status change handling for both users and drivers
- New trip availability notifications for drivers
- Database integration for notification history

**Main Methods:**
- `initialize()`: Initialize local notifications
- `showLocalNotification()`: Display local notification
- `sendNotification()`: Send notification to server
- `getUserNotifications()`: Fetch notifications from database
- `markNotificationsAsRead()`: Mark notifications as read
- `handleTripStatusChangeForUser()`: Handle user trip status notifications
- `handleTripStatusChangeForDriver()`: Handle driver trip status notifications
- `handleNewTripAvailableForDriver()`: Handle new trip notifications

#### 2. Screen Integration

**User Navigation Screen** (`lib/screens/user_navigation_screen.dart`)
- Monitors trip status changes
- Sends notifications when status changes
- Shows local notifications for important events

**Driver Navigation Screen** (`lib/screens/driver_navigation_screen.dart`)
- Monitors trip status changes
- Sends notifications when status changes
- Shows local notifications for important events

**Driver Home Screen** (`lib/screens/driver_home_screen.dart`)
- Checks for new available trips
- Sends notifications to drivers for new trips
- Refreshes every 10 seconds

**Notifications Screen** (`lib/screens/notifications_screen.dart`)
- Displays user notifications from database
- Allows marking notifications as read
- Pull-to-refresh functionality
- Load more notifications with pagination

## Notification Types and Messages

### User Notifications

| Status | Title | Message | Type |
|--------|-------|---------|------|
| DRIVER_ACCEPTED | Driver Accepted Your Trip! | A driver has accepted your trip request. They will be on their way soon. | DRIVER_ACCEPTED |
| DRIVER_IN_WAY | Driver is on the Way! | Your driver is heading to your pickup location. | TRIP_STATUS_CHANGE |
| DRIVER_ARRIVED | Driver Has Arrived! | Your driver has arrived at the pickup location. | DRIVER_ARRIVED |
| USER_PICKED_UP | Trip Started! | You have been picked up. Enjoy your ride! | USER_PICKED_UP |
| TRIP_COMPLETED | Trip Completed! | Your trip has been completed successfully. Thank you for using our service! | TRIP_COMPLETED |
| TRIP_CANCELLED | Trip Cancelled | Your trip has been cancelled. | TRIP_CANCELLED |

### Driver Notifications

| Status | Title | Message | Type |
|--------|-------|---------|------|
| DRIVER_ACCEPTED | Trip Accepted! | You have successfully accepted the trip. Head to the pickup location. | TRIP_STATUS_CHANGE |
| DRIVER_IN_WAY | Heading to Pickup | You are on your way to pick up the passenger. | TRIP_STATUS_CHANGE |
| DRIVER_ARRIVED | Arrived at Pickup | You have arrived at the pickup location. Wait for the passenger. | TRIP_STATUS_CHANGE |
| USER_PICKED_UP | Passenger Picked Up! | The passenger has been picked up. Drive safely to the destination. | TRIP_STATUS_CHANGE |
| TRIP_COMPLETED | Trip Completed! | Trip completed successfully. You can now accept new trips. | TRIP_COMPLETED |
| TRIP_CANCELLED | Trip Cancelled | The trip has been cancelled. | TRIP_CANCELLED |
| NEW_TRIP_AVAILABLE | New Trip Available! | A new trip request is available in your area. Tap to view details. | NEW_TRIP_AVAILABLE |

## Setup and Configuration

### 1. Prisma Setup

The Prisma client has been generated and the database is in sync:
```bash
npx prisma generate
npx prisma db push
```

### 2. Flutter Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^19.2.1
```

### 3. Platform Configuration

**Android**: Uses default launcher icon for notifications
**iOS**: Requests notification permissions on initialization

### 4. Initialization

The notification service is initialized in `main.dart`:
```dart
// Initialize notification service
await NotificationService.initialize();
```

## Current Status

✅ **Fully Functional**
- **Local notifications** are working
- **Database storage** is implemented and working
- **Trip status monitoring** is integrated
- **New trip notifications** for drivers are working
- **Notification history** is available
- **Prisma client** is generated and working

## Usage Examples

### Sending a Notification

```dart
await NotificationService.sendNotification(
  userId: 'user123',
  type: 'DRIVER_ACCEPTED',
  title: 'Driver Accepted Your Trip!',
  message: 'A driver has accepted your trip request.',
  data: {'tripId': 'trip123'},
);
```

### Handling Trip Status Change

```dart
await NotificationService.handleTripStatusChangeForUser(
  trip: trip,
  previousStatus: 'USER_WAITING',
  newStatus: 'DRIVER_ACCEPTED',
);
```

### Showing Local Notification

```dart
await NotificationService.showLocalNotification(
  title: 'New Trip Available!',
  body: 'A new trip request is available in your area.',
  payload: jsonEncode({'tripId': 'trip123'}),
);
```

### Fetching Notifications

```dart
final notifications = await NotificationService.getUserNotifications(
  limit: 20,
  offset: 0,
  unreadOnly: false,
);
```

### Marking Notifications as Read

```dart
await NotificationService.markNotificationsAsRead(
  notificationIds: ['notification1', 'notification2'],
);
```

## Testing

1. **Local Notifications**: Test by changing trip status in the app
2. **Database Notifications**: Check the notifications screen to view stored notifications
3. **Server Notifications**: Check server logs for notification creation
4. **Notification History**: Navigate to notifications screen to view and manage notifications

## Troubleshooting

1. **Notifications not showing**: Check notification permissions on device
2. **Database errors**: Ensure Prisma client is generated (`npx prisma generate`)
3. **Permission issues**: Ensure notification permissions are granted on iOS/Android
4. **TypeScript errors**: Restart TypeScript server if Prisma types are not recognized

## Future Enhancements

1. **Push Notifications**: Implement Firebase Cloud Messaging for real-time notifications
2. **Notification Preferences**: Allow users to customize notification settings
3. **Rich Notifications**: Add images and actions to notifications
4. **Real-time Updates**: Use WebSockets for real-time notification delivery
5. **Notification Analytics**: Track notification engagement and effectiveness

## Current Limitations

1. **Real-time Updates**: Notifications are sent when status changes are detected, not in real-time
2. **Push Notifications**: Only local notifications are implemented; push notifications require additional setup

## Future Enhancements

1. **Push Notifications**: Implement Firebase Cloud Messaging for real-time notifications
2. **Notification Preferences**: Allow users to customize notification settings
3. **Rich Notifications**: Add images and actions to notifications
4. **Real-time Updates**: Use WebSockets for real-time notification delivery
5. **Notification History**: Implement proper notification history and management
6. **Real-time Updates**: Use WebSockets for real-time notification delivery

## Usage Examples

### Sending a Notification

```dart
await NotificationService.sendNotification(
  userId: 'user123',
  type: 'DRIVER_ACCEPTED',
  title: 'Driver Accepted Your Trip!',
  message: 'A driver has accepted your trip request.',
  data: {'tripId': 'trip123'},
);
```

### Handling Trip Status Change

```dart
await NotificationService.handleTripStatusChangeForUser(
  trip: trip,
  previousStatus: 'USER_WAITING',
  newStatus: 'DRIVER_ACCEPTED',
);
```

### Showing Local Notification

```dart
await NotificationService.showLocalNotification(
  title: 'New Trip Available!',
  body: 'A new trip request is available in your area.',
  payload: jsonEncode({'tripId': 'trip123'}),
);
```

## Testing

1. **Local Notifications**: Test by changing trip status in the app
2. **Server Notifications**: Check server logs for notification intents
3. **Notification Screen**: Navigate to notifications screen to view notification history

## Troubleshooting

1. **Notifications not showing**: Check notification permissions on device
2. **Server errors**: Check server logs for notification sending errors
3. **Prisma issues**: Currently using logging instead of database storage
4. **Permission issues**: Ensure notification permissions are granted on iOS/Android 
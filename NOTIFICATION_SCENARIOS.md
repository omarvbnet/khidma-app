# Notification Scenarios - Complete Implementation

## Overview
This document outlines all notification scenarios in the Waddiny taxi app, including what's implemented and how it works.

## ✅ **Implemented Notification Scenarios**

### 1. **Driver → User Notifications**

#### When Driver Accepts Trip
- **Trigger**: Trip status changes to `DRIVER_ACCEPTED`
- **User Notification**: "Driver Accepted Your Trip! A driver has accepted your trip request. They will be on their way soon."
- **Implementation**: 
  - Backend: `sendTripStatusNotification()` in `/api/flutter/driver/trips`
  - Flutter: `handleTripStatusChangeForUser()` in `notification_service.dart`

#### When Driver is On the Way
- **Trigger**: Trip status changes to `DRIVER_IN_WAY`
- **User Notification**: "Driver is on the Way! Your driver is heading to your pickup location."
- **Implementation**: Same as above

#### When Driver Arrives
- **Trigger**: Trip status changes to `DRIVER_ARRIVED`
- **User Notification**: "Driver Has Arrived! Your driver has arrived at your pickup location."
- **Implementation**: Same as above

#### When Trip Starts (User Picked Up)
- **Trigger**: Trip status changes to `USER_PICKED_UP`
- **User Notification**: "Trip Started! You have been picked up. Enjoy your ride!"
- **Implementation**: Same as above

#### When Trip is Completed
- **Trigger**: Trip status changes to `TRIP_COMPLETED`
- **User Notification**: "Trip Completed! Your trip has been completed successfully."
- **Implementation**: Same as above

#### When Trip is Cancelled
- **Trigger**: Trip status changes to `TRIP_CANCELLED`
- **User Notification**: "Trip Cancelled. Your trip has been cancelled."
- **Implementation**: Same as above

### 2. **Driver Status Change Notifications**

#### When Driver Accepts Trip
- **Trigger**: Trip status changes to `DRIVER_ACCEPTED`
- **Driver Notification**: "Trip Accepted! You have successfully accepted the trip. Head to the pickup location."
- **Implementation**: 
  - Backend: `sendTripStatusNotification()` in `/api/flutter/driver/trips`
  - Flutter: `handleTripStatusChangeForDriver()` in `notification_service.dart`

#### When Driver Starts Trip (In Way)
- **Trigger**: Trip status changes to `DRIVER_IN_WAY`
- **Driver Notification**: "Heading to Pickup. You are on your way to pick up the passenger."
- **Implementation**: Same as above

#### When Driver Arrives at Pickup
- **Trigger**: Trip status changes to `DRIVER_ARRIVED`
- **Driver Notification**: "Arrived at Pickup. You have arrived at the pickup location. Wait for the passenger."
- **Implementation**: Same as above

#### When User is Picked Up
- **Trigger**: Trip status changes to `USER_PICKED_UP`
- **Driver Notification**: "Passenger Picked Up! The passenger has been picked up. Drive safely to the destination."
- **Implementation**: Same as above

#### When Trip is Completed
- **Trigger**: Trip status changes to `TRIP_COMPLETED`
- **Driver Notification**: "Trip Completed! Trip completed successfully. You can now accept new trips."
- **Implementation**: Same as above

### 3. **New Trip Notifications to Drivers**

#### When User Creates New Trip
- **Trigger**: New trip is created via `/api/flutter/taxi-requests` POST
- **Driver Notification**: "New Trip Available! A new trip request is available in your area. Tap to view details."
- **Implementation**: 
  - Backend: `notifyAllActiveDriversAboutNewTrip()` called after trip creation
  - Flutter: `handleNewTripAvailableForDriver()` for local notifications

## 🔧 **Technical Implementation**

### Backend (Next.js)

#### 1. Notification Service (`src/lib/notification-service.ts`)
```typescript
// Main function for trip status notifications
export async function sendTripStatusNotification(trip, previousStatus, newStatus)

// Function for new trip notifications to specific driver
export async function sendNewTripNotification(trip, driverId)

// Function to notify all active drivers about new trip
export async function notifyAllActiveDriversAboutNewTrip(trip)

// Function to notify all drivers (including those on trips)
export async function notifyAllDriversAboutNewTrip(trip)
```

#### 2. Trip Status Updates (`src/app/api/flutter/driver/trips/route.ts`)
- Automatically calls `sendTripStatusNotification()` when trip status changes
- Sends notifications to both user and driver

#### 3. Trip Creation (`src/app/api/flutter/taxi-requests/route.ts`)
- Calls `notifyAllActiveDriversAboutNewTrip()` after successful trip creation
- Notifies all drivers who are not currently on active trips

### Flutter App

#### 1. Notification Service (`waddiny/lib/services/notification_service.dart`)
```dart
// User notifications for trip status changes
static Future<void> handleTripStatusChangeForUser({trip, previousStatus, newStatus})

// Driver notifications for trip status changes  
static Future<void> handleTripStatusChangeForDriver({trip, previousStatus, newStatus})

// New trip notifications for drivers
static Future<void> handleNewTripAvailableForDriver({trip, driverId})
```

#### 2. Integration Points
- **User Navigation Screen**: Calls `handleTripStatusChangeForUser()` on status changes
- **Driver Navigation Screen**: Calls `handleTripStatusChangeForDriver()` on status changes
- **Driver Home Screen**: Checks for new trips and calls `handleNewTripAvailableForDriver()`

## 📱 **Notification Flow**

### Trip Status Change Flow
1. Driver updates trip status via API
2. Backend validates status transition
3. Backend updates trip in database
4. Backend calls `sendTripStatusNotification()`
5. Backend creates notifications for both user and driver
6. Flutter app receives status update
7. Flutter app calls local notification functions
8. Local notifications are displayed

### New Trip Creation Flow
1. User creates new trip via API
2. Backend validates trip data
3. Backend creates trip in database
4. Backend calls `notifyAllActiveDriversAboutNewTrip()`
5. Backend finds all active drivers (not on trips)
6. Backend creates notifications for each active driver
7. Flutter app polls for new trips
8. Flutter app shows local notifications for new trips

## 🎯 **Key Features**

### 1. **Real-time Notifications**
- Both backend and local notifications ensure users get immediate updates
- Local notifications work even when app is in background

### 2. **Smart Driver Targeting**
- Only notifies active drivers (not currently on trips) about new trips
- Prevents spam notifications to busy drivers

### 3. **Comprehensive Coverage**
- Covers all major trip status changes
- Includes both user and driver perspectives
- Handles edge cases like cancellations

### 4. **Error Handling**
- Notification failures don't break trip operations
- Graceful fallbacks for permission issues
- Comprehensive logging for debugging

## 🔍 **Testing Scenarios**

### Test User Notifications
1. Create a trip as user
2. Have driver accept the trip
3. Verify user gets "Driver Accepted" notification
4. Have driver update status to "In Way"
5. Verify user gets "Driver is on the Way" notification
6. Continue through all status changes

### Test Driver Notifications
1. Login as driver
2. Accept a trip
3. Verify driver gets "Trip Accepted" notification
4. Update trip status to "In Way"
5. Verify driver gets "Heading to Pickup" notification
6. Continue through all status changes

### Test New Trip Notifications
1. Create a new trip as user
2. Verify all active drivers get "New Trip Available" notification
3. Check that drivers on active trips don't get notified

## 🚀 **Deployment Notes**

### Backend Deployment
- Ensure Prisma schema is up to date
- Verify notification endpoints are accessible
- Test notification creation in database

### Flutter Deployment
- Ensure notification permissions are properly configured
- Test on both iOS and Android devices
- Verify local notifications work in background

## 📊 **Monitoring**

### Key Metrics to Monitor
- Notification delivery success rate
- Number of active drivers notified per new trip
- Trip status change notification frequency
- User engagement with notifications

### Log Analysis
- Check console logs for notification success/failure
- Monitor database for notification creation
- Track notification read rates

## 🔧 **Configuration**

### Environment Variables
- `JWT_SECRET`: For authentication
- Database connection strings
- Notification service configurations

### iOS Configuration
- Notification permissions in Info.plist
- Background modes for notifications
- Push notification certificates

### Android Configuration
- Notification channels
- Permission handling
- Background execution settings 
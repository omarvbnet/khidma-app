import { prisma } from './prisma';
import { sendPushNotification, sendMulticastNotification } from './firebase-admin';

export interface NotificationData {
  tripId: string;
  previousStatus?: string;
  newStatus: string;
  pickupLocation: string;
  dropoffLocation: string;
  [key: string]: any;
}

// Helper function to get user's device token
async function getUserDeviceToken(userId: string): Promise<string | null> {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { deviceToken: true }
    });
    return user?.deviceToken || null;
  } catch (error) {
    console.error('Error getting user device token:', error);
    return null;
  }
}

// Helper function to send push notification with fallback
async function sendNotificationWithFallback(
  userId: string,
  title: string,
  message: string,
  data: any,
  type: string
) {
  try {
    // Create notification in database
    const notification = await prisma.notification.create({
      data: {
        userId,
        type: type as any,
        title,
        message,
        data,
      },
    });

    // Get user's device token
    const deviceToken = await getUserDeviceToken(userId);
    
    if (deviceToken) {
      try {
        // Send Firebase push notification
        await sendPushNotification({
          token: deviceToken,
          title,
          body: message,
          data: {
            ...data,
            notificationId: notification.id,
            type,
          },
        });
        
        console.log(`📱 Push notification sent to user ${userId}: ${title}`);
      } catch (firebaseError) {
        console.error(`❌ Firebase notification failed for user ${userId}:`, firebaseError);
        // Continue with database notification even if Firebase fails
      }
    } else {
      console.log(`⚠️ No device token found for user ${userId}, only database notification created`);
    }

    console.log(`📱 Notification sent to user ${userId}: ${title}`);
    return notification;
  } catch (error) {
    console.error('Error sending notification:', error);
    throw error;
  }
}

export async function sendTripStatusNotification(
  trip: any,
  previousStatus: string,
  newStatus: string
) {
  const notificationData: NotificationData = {
    tripId: trip.id,
    previousStatus,
    newStatus,
    pickupLocation: trip.pickupLocation,
    dropoffLocation: trip.dropoffLocation,
  };

  // Send notification to user
  if (trip.userId) {
    let userTitle = '';
    let userMessage = '';
    let userType = 'TRIP_STATUS_CHANGE';

    switch (newStatus) {
      case 'DRIVER_ACCEPTED':
        userTitle = 'Driver Accepted Your Trip!';
        userMessage = 'A driver has accepted your trip request. They will be on their way soon.';
        userType = 'DRIVER_ACCEPTED';
        break;
      
      case 'DRIVER_IN_WAY':
        userTitle = 'Driver is on the Way!';
        userMessage = 'Your driver is heading to your pickup location.';
        break;
      
      case 'DRIVER_ARRIVED':
        userTitle = 'Driver Has Arrived!';
        userMessage = 'Your driver has arrived at the pickup location.';
        userType = 'DRIVER_ARRIVED';
        break;
      
      case 'USER_PICKED_UP':
        userTitle = 'Trip Started!';
        userMessage = 'You have been picked up. Enjoy your ride!';
        userType = 'USER_PICKED_UP';
        break;
      
      case 'TRIP_COMPLETED':
        userTitle = 'Trip Completed!';
        userMessage = 'Your trip has been completed successfully. Thank you for using our service!';
        userType = 'TRIP_COMPLETED';
        break;
      
      case 'TRIP_CANCELLED':
        userTitle = 'Trip Cancelled';
        userMessage = 'Your trip has been cancelled.';
        userType = 'TRIP_CANCELLED';
        break;
      
      default:
        return; // Don't send notification for other statuses
    }

    try {
      await sendNotificationWithFallback(
        trip.userId,
        userTitle,
        userMessage,
        notificationData,
        userType
      );
    } catch (error) {
      console.error('Error sending notification to user:', error);
    }
  }

  // Send notification to driver
  if (trip.driverId) {
    let driverTitle = '';
    let driverMessage = '';
    let driverType = 'TRIP_STATUS_CHANGE';

    switch (newStatus) {
      case 'DRIVER_ACCEPTED':
        driverTitle = 'Trip Accepted!';
        driverMessage = 'You have successfully accepted the trip. Head to the pickup location.';
        break;
      
      case 'DRIVER_IN_WAY':
        driverTitle = 'Heading to Pickup';
        driverMessage = 'You are on your way to pick up the passenger.';
        break;
      
      case 'DRIVER_ARRIVED':
        driverTitle = 'Arrived at Pickup';
        driverMessage = 'You have arrived at the pickup location. Wait for the passenger.';
        break;
      
      case 'USER_PICKED_UP':
        driverTitle = 'Passenger Picked Up!';
        driverMessage = 'The passenger has been picked up. Drive safely to the destination.';
        break;
      
      case 'TRIP_COMPLETED':
        driverTitle = 'Trip Completed!';
        driverMessage = 'Trip completed successfully. You can now accept new trips.';
        driverType = 'TRIP_COMPLETED';
        break;
      
      case 'TRIP_CANCELLED':
        driverTitle = 'Trip Cancelled';
        driverMessage = 'The trip has been cancelled.';
        driverType = 'TRIP_CANCELLED';
        break;
      
      default:
        return; // Don't send notification for other statuses
    }

    try {
      await sendNotificationWithFallback(
        trip.driverId,
        driverTitle,
        driverMessage,
        notificationData,
        driverType
      );
    } catch (error) {
      console.error('Error sending notification to driver:', error);
    }
  }
}

export async function sendNewTripNotification(
  trip: any,
  driverId: string
) {
  const notificationData: NotificationData = {
    tripId: trip.id,
    newStatus: 'NEW_TRIP_AVAILABLE',
    pickupLocation: trip.pickupLocation,
    dropoffLocation: trip.dropoffLocation,
    fare: trip.price,
    distance: trip.distance,
    userFullName: trip.userFullName,
    userPhone: trip.userPhone,
  };

  const title = 'New Trip Available!';
  const message = 'A new trip request is available in your area. Tap to view details.';
  const type = 'NEW_TRIP_AVAILABLE';

  try {
    await sendNotificationWithFallback(
      driverId,
      title,
      message,
      notificationData,
      type
    );
  } catch (error) {
    console.error('Error sending new trip notification:', error);
  }
}

// Helper function to check if a driver is available for new trips
async function isDriverAvailable(driverId: string): Promise<boolean> {
  try {
    // Check if driver has any active trips
    const activeTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: driverId,
        status: {
          in: [
            'DRIVER_ACCEPTED',
            'DRIVER_IN_WAY', 
            'DRIVER_ARRIVED',
            'USER_PICKED_UP',
            'DRIVER_IN_PROGRESS'
          ]
        }
      }
    });

    // Driver is available if they have no active trips
    return activeTrips.length === 0;
  } catch (error) {
    console.error(`Error checking driver availability for ${driverId}:`, error);
    return false;
  }
}

// New function to notify all available drivers about a new trip
export async function notifyAvailableDriversAboutNewTrip(trip: any) {
  try {
    console.log('\n=== NOTIFYING AVAILABLE DRIVERS ABOUT NEW TRIP ===');
    console.log('Trip ID:', trip.id);
    console.log('Pickup:', trip.pickupLocation);
    console.log('Dropoff:', trip.dropoffLocation);
    console.log('Fare:', trip.price);

    // Get all active drivers
    const allActiveDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE', // Only active drivers
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allActiveDrivers.length} total active drivers`);

    // Filter to only available drivers (those without active trips)
    const availableDrivers = [];
    for (const driver of allActiveDrivers) {
      const isAvailable = await isDriverAvailable(driver.id);
      if (isAvailable) {
        availableDrivers.push(driver);
      }
    }

    console.log(`Found ${availableDrivers.length} available drivers to notify`);

    if (availableDrivers.length === 0) {
      console.log('No available drivers found');
      return;
    }

    // Prepare notification data
    const notificationData: NotificationData = {
      tripId: trip.id,
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: trip.pickupLocation,
      dropoffLocation: trip.dropoffLocation,
      fare: trip.price,
      distance: trip.distance,
      userFullName: trip.userFullName,
      userPhone: trip.userPhone,
    };

    const title = 'New Trip Available!';
    const message = 'A new trip request is available in your area. Tap to view details.';
    const type = 'NEW_TRIP_AVAILABLE';

    // Collect device tokens for batch notification
    const deviceTokens: string[] = [];
    const driversWithoutTokens: string[] = [];

    for (const driver of availableDrivers) {
      if (driver.deviceToken) {
        deviceTokens.push(driver.deviceToken);
      } else {
        driversWithoutTokens.push(driver.id);
      }
    }

    // Send batch push notification if we have device tokens
    if (deviceTokens.length > 0) {
      try {
        await sendMulticastNotification({
          tokens: deviceTokens,
          title,
          body: message,
          data: {
            ...notificationData,
            type,
          },
        });
        console.log(`✅ Batch push notification sent to ${deviceTokens.length} available drivers`);
      } catch (firebaseError) {
        console.error('❌ Batch Firebase notification failed:', firebaseError);
        // Fall back to individual notifications
        for (const driver of availableDrivers) {
          if (driver.deviceToken) {
            try {
              await sendNotificationWithFallback(
                driver.id,
                title,
                message,
                notificationData,
                type
              );
            } catch (error) {
              console.error(`❌ Failed to send notification to driver ${driver.id}:`, error);
            }
          }
        }
      }
    }

    // Send individual notifications for drivers without device tokens
    for (const driverId of driversWithoutTokens) {
      try {
        await sendNotificationWithFallback(
          driverId,
          title,
          message,
          notificationData,
          type
        );
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driverId}:`, error);
      }
    }

    console.log('✅ All available drivers notified about new trip');

  } catch (error) {
    console.error('❌ Error notifying available drivers about new trip:', error);
  }
}

// Alternative function to notify ALL drivers (including those on trips)
export async function notifyAllDriversAboutNewTrip(trip: any) {
  try {
    console.log('\n=== NOTIFYING ALL DRIVERS ABOUT NEW TRIP ===');
    console.log('Trip ID:', trip.id);
    console.log('Pickup:', trip.pickupLocation);
    console.log('Dropoff:', trip.dropoffLocation);
    console.log('Fare:', trip.price);

    // Get all drivers
    const allDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER'
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allDrivers.length} total drivers to notify`);

    // Prepare notification data
    const notificationData: NotificationData = {
      tripId: trip.id,
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: trip.pickupLocation,
      dropoffLocation: trip.dropoffLocation,
      fare: trip.price,
      distance: trip.distance,
      userFullName: trip.userFullName,
      userPhone: trip.userPhone,
    };

    const title = 'New Trip Available!';
    const message = 'A new trip request is available in your area. Tap to view details.';
    const type = 'NEW_TRIP_AVAILABLE';

    // Collect device tokens for batch notification
    const deviceTokens: string[] = [];
    const driversWithoutTokens: string[] = [];

    for (const driver of allDrivers) {
      if (driver.deviceToken) {
        deviceTokens.push(driver.deviceToken);
      } else {
        driversWithoutTokens.push(driver.id);
      }
    }

    // Send batch push notification if we have device tokens
    if (deviceTokens.length > 0) {
      try {
        await sendMulticastNotification({
          tokens: deviceTokens,
          title,
          body: message,
          data: {
            ...notificationData,
            type,
          },
        });
        console.log(`✅ Batch push notification sent to ${deviceTokens.length} drivers`);
      } catch (firebaseError) {
        console.error('❌ Batch Firebase notification failed:', firebaseError);
        // Fall back to individual notifications
        for (const driver of allDrivers) {
          if (driver.deviceToken) {
            try {
              await sendNotificationWithFallback(
                driver.id,
                title,
                message,
                notificationData,
                type
              );
            } catch (error) {
              console.error(`❌ Failed to send notification to driver ${driver.id}:`, error);
            }
          }
        }
      }
    }

    // Send individual notifications for drivers without device tokens
    for (const driverId of driversWithoutTokens) {
      try {
        await sendNotificationWithFallback(
          driverId,
          title,
          message,
          notificationData,
          type
        );
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driverId}:`, error);
      }
    }

    console.log('✅ All drivers notified about new trip');

  } catch (error) {
    console.error('❌ Error notifying all drivers about new trip:', error);
  }
} 
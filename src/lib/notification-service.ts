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

// Helper function to convert all data values to strings (FCM requirement)
function convertDataToStrings(data: Record<string, any>): Record<string, string> {
  const stringData: Record<string, string> = {};
  
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) {
      stringData[key] = '';
    } else if (typeof value === 'object') {
      stringData[key] = JSON.stringify(value);
    } else {
      stringData[key] = String(value);
    }
  }
  
  return stringData;
}

// Helper function to clean up invalid device token
async function cleanupInvalidDeviceToken(userId: string, error: any) {
  try {
    // Check if the error indicates an invalid token
    const errorMessage = error instanceof Error ? error.message : String(error);
    const isTokenError = errorMessage.includes('Requested entity was not found') ||
                        errorMessage.includes('Invalid registration token') ||
                        errorMessage.includes('Registration token is not valid');

    if (isTokenError) {
      console.log(`🧹 Cleaning up invalid device token for user ${userId}`);
      
      // Clear the device token from the database
      await prisma.user.update({
        where: { id: userId },
        data: { deviceToken: null }
      });
      
      console.log(`✅ Invalid device token cleared for user ${userId}`);
    }
  } catch (cleanupError) {
    console.error(`❌ Error cleaning up invalid device token for user ${userId}:`, cleanupError);
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
    // First, verify that the user exists
    const userExists = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true }
    });

    if (!userExists) {
      console.error(`❌ User not found for notification: ${userId}`);
      throw new Error(`User not found: ${userId}`);
    }

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
        // Convert all data values to strings for Firebase compatibility
        const stringData = convertDataToStrings({
          ...data,
          notificationId: notification.id,
          type,
        });
        
        console.log('📱 Converting notification data to strings:', {
          originalData: data,
          stringData: stringData,
        });

        // Send Firebase push notification
        await sendPushNotification({
          token: deviceToken,
          title,
          body: message,
          data: stringData,
        });
        
        console.log(`📱 Push notification sent to user ${userId}: ${title}`);
      } catch (firebaseError) {
        console.error(`❌ Firebase notification failed for user ${userId}:`, firebaseError);
        
        // Clean up invalid device token if needed
        await cleanupInvalidDeviceToken(userId, firebaseError);
        
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
  console.log('\n=== SENDING TRIP STATUS NOTIFICATION ===');
  console.log('Trip ID:', trip.id);
  console.log('Previous status:', previousStatus);
  console.log('New status:', newStatus);
  console.log('Trip data:', {
    userId: trip.userId,
    driverId: trip.driverId,
    driver: trip.driver ? { id: trip.driver.id, userId: trip.driver.userId } : null,
    user: trip.user ? { id: trip.user.id } : null
  });

  const notificationData: NotificationData = {
    tripId: trip.id,
    previousStatus,
    newStatus,
    pickupLocation: trip.pickupLocation,
    dropoffLocation: trip.dropoffLocation,
  };

  // Send notification to user
  if (trip.userId) {
    console.log('📱 Sending notification to user:', trip.userId);
    
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
        console.log('⚠️ No notification for user status:', newStatus);
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
      console.log('✅ User notification sent successfully');
    } catch (error) {
      console.error('❌ Error sending notification to user:', error);
    }
  } else {
    console.log('⚠️ No userId found in trip data');
  }

  // Send notification to driver
  if (trip.driverId) {
    console.log('📱 Sending notification to driver. Driver ID:', trip.driverId);
    
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
        console.log('⚠️ No notification for driver status:', newStatus);
        return; // Don't send notification for other statuses
    }

    try {
      // Get the driver's user ID from the driver profile
      const driverProfile = await prisma.driver.findUnique({
        where: { id: trip.driverId },
        select: { userId: true }
      });

      console.log('Driver profile lookup result:', driverProfile);

      if (driverProfile && driverProfile.userId) {
        console.log('📱 Sending notification to driver user ID:', driverProfile.userId);
        await sendNotificationWithFallback(
          driverProfile.userId,
          driverTitle,
          driverMessage,
          notificationData,
          driverType
        );
        console.log('✅ Driver notification sent successfully');
      } else {
        console.error('❌ Driver profile not found or missing userId:', trip.driverId);
      }
    } catch (error) {
      console.error('❌ Error sending notification to driver:', error);
    }
  } else {
    console.log('⚠️ No driverId found in trip data');
  }

  console.log('=== TRIP STATUS NOTIFICATION COMPLETED ===\n');
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
    console.log(`\n=== CHECKING AVAILABILITY FOR DRIVER ${driverId} ===`);
    
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

    console.log(`Driver ${driverId} has ${activeTrips.length} active trips:`);
    for (const trip of activeTrips) {
      console.log(`  - Trip ${trip.id}: ${trip.status} (${trip.pickupLocation} → ${trip.dropoffLocation})`);
    }

    // Driver is available if they have no active trips
    const isAvailable = activeTrips.length === 0;
    console.log(`Driver ${driverId} is ${isAvailable ? 'AVAILABLE' : 'BUSY'}`);
    
    return isAvailable;
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
    console.log('User Province:', trip.userProvince);

    // Get all active drivers in the same province as the user
    const allActiveDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE', // Only active drivers
        province: trip.userProvince, // Enable province filtering
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allActiveDrivers.length} total active drivers in province: ${trip.userProvince}`);

    // Log driver details for debugging
    for (const driver of allActiveDrivers) {
      console.log(`- Driver: ${driver.fullName} (${driver.id}) - Province: ${driver.province} - Status: ${driver.status} - Role: ${driver.role} - Has Token: ${!!driver.deviceToken}`);
    }

    // Also check if there are any users with the same province (for debugging)
    const allUsersInProvince = await prisma.user.findMany({
      where: {
        province: trip.userProvince,
      },
      select: {
        id: true,
        fullName: true,
        role: true,
        status: true,
        deviceToken: !!true,
      }
    });

    console.log(`\n🔍 DEBUG: All users in province ${trip.userProvince}:`);
    for (const user of allUsersInProvince) {
      console.log(`- User: ${user.fullName} (${user.id}) - Role: ${user.role} - Status: ${user.status} - Has Token: ${!!user.deviceToken}`);
    }

    // Test query to see if role filtering is working
    console.log(`\n🧪 TESTING ROLE FILTERING:`);
    const testDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
      },
      select: {
        id: true,
        fullName: true,
        role: true,
        status: true,
        province: true,
      }
    });
    console.log(`Found ${testDrivers.length} total users with role DRIVER:`);
    for (const driver of testDrivers) {
      console.log(`- Driver: ${driver.fullName} (${driver.id}) - Role: ${driver.role} - Status: ${driver.status} - Province: ${driver.province}`);
    }

    const testUsers = await prisma.user.findMany({
      where: {
        role: 'USER',
      },
      select: {
        id: true,
        fullName: true,
        role: true,
        status: true,
        province: true,
      }
    });
    console.log(`Found ${testUsers.length} total users with role USER:`);
    for (const user of testUsers) {
      console.log(`- User: ${user.fullName} (${user.id}) - Role: ${user.role} - Status: ${user.status} - Province: ${user.province}`);
    }

    // Filter to only available drivers (those without active trips)
    const availableDrivers = [];
    for (const driver of allActiveDrivers) {
      console.log(`\n--- Checking availability for ${driver.fullName} (${driver.id}) ---`);
      
      // Check if driver has active trips
      const isAvailable = await isDriverAvailable(driver.id);
      console.log(`Driver ${driver.fullName} (${driver.id}) - Available: ${isAvailable}`);
      
      // Allow drivers to receive notifications even if they have active trips
      // This ensures drivers can see new trips while on current trips
      if (isAvailable || driver.deviceToken) { // Include drivers with device tokens even if busy
        availableDrivers.push(driver);
        console.log(`✅ Added ${driver.fullName} to available drivers list (${isAvailable ? 'available' : 'busy but has device token'})`);
      } else {
        console.log(`❌ ${driver.fullName} is busy and has no device token, not adding to available list`);
      }
    }

    console.log(`Found ${availableDrivers.length} available drivers to notify in province: ${trip.userProvince}`);

    // If no available drivers found, log this information
    if (availableDrivers.length === 0) {
      console.log(`⚠️ No available drivers found`);
      console.log(`📊 Trip will not be visible to any drivers`);
      
      // Optionally, you could notify drivers in neighboring provinces or all drivers
      // For now, we'll just log and return without sending notifications
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
      userProvince: trip.userProvince, // Include province in notification data
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in ${trip.userProvince}. Tap to view details.`;
    const type = 'NEW_TRIP_AVAILABLE';

    // Collect device tokens for batch notification
    const deviceTokens: string[] = [];
    const driversWithoutTokens: string[] = [];

    for (const driver of availableDrivers) {
      if (driver.deviceToken) {
        deviceTokens.push(driver.deviceToken);
        console.log(`✅ Driver ${driver.fullName} has device token: ${driver.deviceToken.substring(0, 20)}...`);
      } else {
        driversWithoutTokens.push(driver.id);
        console.log(`⚠️ Driver ${driver.fullName} has no device token`);
      }
    }

    console.log(`Drivers with tokens: ${deviceTokens.length}`);
    console.log(`Drivers without tokens: ${driversWithoutTokens.length}`);

    // Send batch push notification if we have device tokens
    if (deviceTokens.length > 0) {
      try {
        // Convert all data values to strings for Firebase compatibility
        const stringData = convertDataToStrings({
          ...notificationData,
          type,
        });
        
        await sendMulticastNotification({
          tokens: deviceTokens,
          title,
          body: message,
          data: stringData,
        });
        console.log(`✅ Batch push notification sent to ${deviceTokens.length} drivers`);
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

    // Create database notifications for ALL drivers (with or without device tokens)
    console.log('Creating database notifications for all available drivers...');
    for (const driver of availableDrivers) {
      try {
        console.log(`Creating database notification for driver ${driver.fullName} (${driver.id})`);
        await sendNotificationWithFallback(
          driver.id,
          title,
          message,
          notificationData,
          type
        );
        console.log(`✅ Database notification created for driver ${driver.fullName}`);
      } catch (error) {
        console.error(`❌ Failed to create database notification for driver ${driver.id}:`, error);
      }
    }

    console.log(`✅ All ${availableDrivers.length} drivers notified about new trip`);

  } catch (error) {
    console.error('❌ Error notifying available drivers about new trip:', error);
    // Try to notify all drivers in the same province as a last resort
    try {
      console.log('🔄 Attempting to notify all drivers in same province as fallback...');
      await notifyAllDriversInProvinceAboutNewTrip(trip);
    } catch (fallbackError) {
      console.error('❌ Fallback notification also failed:', fallbackError);
    }
  }
}

// Alternative function to notify ALL drivers in the same province (including those on trips)
export async function notifyAllDriversInProvinceAboutNewTrip(trip: any) {
  try {
    console.log('\n=== NOTIFYING ALL DRIVERS IN PROVINCE ABOUT NEW TRIP ===');
    console.log('Trip ID:', trip.id);
    console.log('Pickup:', trip.pickupLocation);
    console.log('Dropoff:', trip.dropoffLocation);
    console.log('Fare:', trip.price);
    console.log('User Province:', trip.userProvince);

    // Get all drivers in the same province
    const allDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        province: trip.userProvince, // Only drivers in the same province
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allDrivers.length} total drivers in province: ${trip.userProvince} to notify`);

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
      userProvince: trip.userProvince,
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in ${trip.userProvince}. Tap to view details.`;
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

    console.log(`Drivers with tokens: ${deviceTokens.length}`);
    console.log(`Drivers without tokens: ${driversWithoutTokens.length}`);

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

    // Create database notifications for ALL drivers
    for (const driver of allDrivers) {
      try {
        await sendNotificationWithFallback(
          driver.id,
          title,
          message,
          notificationData,
          type
        );
      } catch (error) {
        console.error(`❌ Failed to create database notification for driver ${driver.id}:`, error);
      }
    }

    console.log(`✅ All ${allDrivers.length} drivers in ${trip.userProvince} notified about new trip`);

  } catch (error) {
    console.error('❌ Error notifying all drivers in province about new trip:', error);
  }
}

// Alternative function to notify ALL drivers (including those on trips) - updated to include province info
export async function notifyAllDriversAboutNewTrip(trip: any) {
  try {
    console.log('\n=== NOTIFYING ALL DRIVERS ABOUT NEW TRIP ===');
    console.log('Trip ID:', trip.id);
    console.log('Pickup:', trip.pickupLocation);
    console.log('Dropoff:', trip.dropoffLocation);
    console.log('Fare:', trip.price);
    console.log('User Province:', trip.userProvince);

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
      userProvince: trip.userProvince, // Include province info
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in ${trip.userProvince}. Tap to view details.`;
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

    // Create database notifications for ALL drivers
    for (const driver of allDrivers) {
      try {
        await sendNotificationWithFallback(
          driver.id,
          title,
          message,
          notificationData,
          type
        );
      } catch (error) {
        console.error(`❌ Failed to create database notification for driver ${driver.id}:`, error);
      }
    }

    console.log(`✅ All ${allDrivers.length} drivers notified about new trip`);

  } catch (error) {
    console.error('❌ Error notifying all drivers about new trip:', error);
  }
}

// Declare global type for periodic notification intervals
declare global {
  var periodicNotificationIntervals: Map<string, NodeJS.Timeout> | undefined;
}

// Function to send periodic notifications to available drivers
export async function startPeriodicNotificationsForTrip(trip: any) {
  try {
    console.log('\n=== STARTING PERIODIC NOTIFICATIONS FOR TRIP ===');
    console.log('Trip ID:', trip.id);
    console.log('User Province:', trip.userProvince);

    // Store the interval ID so we can stop it later
    const intervalId = setInterval(async () => {
      try {
        console.log(`\n🔄 Sending periodic notification for trip ${trip.id}...`);
        
        // Check if trip is still waiting for driver
        const currentTrip = await prisma.taxiRequest.findUnique({
          where: { id: trip.id },
          select: { status: true }
        });

        if (!currentTrip) {
          console.log(`❌ Trip ${trip.id} not found, stopping periodic notifications`);
          clearInterval(intervalId);
          return;
        }

        if (currentTrip.status !== 'USER_WAITING') {
          console.log(`✅ Trip ${trip.id} status changed to ${currentTrip.status}, stopping periodic notifications`);
          clearInterval(intervalId);
          return;
        }

        // Get all active drivers (province filtering enabled)
        const allActiveDrivers = await prisma.user.findMany({
          where: {
            role: 'DRIVER',
            status: 'ACTIVE',
            province: trip.userProvince, // Enable province filtering
          },
          include: {
            driver: true
          }
        });

        console.log(`Found ${allActiveDrivers.length} total active drivers in province: ${trip.userProvince}`);

        // Filter to only available drivers (those without active trips)
        const availableDrivers = [];
        for (const driver of allActiveDrivers) {
          const isAvailable = await isDriverAvailable(driver.id);
          if (isAvailable) {
            availableDrivers.push(driver);
          }
        }

        console.log(`Found ${availableDrivers.length} available drivers to notify in province: ${trip.userProvince}`);

        if (availableDrivers.length === 0) {
          console.log(`⚠️ No available drivers found for periodic notification`);
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
          userProvince: trip.userProvince,
        };

        const title = 'Trip Still Available!';
        const message = `A trip request is still waiting in ${trip.userProvince}. Tap to view details.`;
        const type = 'NEW_TRIP_AVAILABLE';

        // Collect device tokens for batch notification
        const deviceTokens: string[] = [];
        for (const driver of availableDrivers) {
          if (driver.deviceToken) {
            deviceTokens.push(driver.deviceToken);
          }
        }

        // Send iOS-compatible single messages instead of batch multicast
        if (deviceTokens.length > 0) {
          try {
            console.log(`Sending periodic iOS-compatible notifications to ${deviceTokens.length} drivers...`);
            
            // Import Firebase messaging for direct message sending
            const { getMessaging } = require('firebase-admin/messaging');
            const messaging = getMessaging();
            
            // Send individual messages to each driver for better iOS compatibility
            const sendPromises = deviceTokens.map(async (token) => {
              // Convert all data values to strings for Firebase compatibility
              const stringifiedData = {
                tripId: String(notificationData.tripId),
                newStatus: String(notificationData.newStatus),
                pickupLocation: String(notificationData.pickupLocation),
                dropoffLocation: String(notificationData.dropoffLocation),
                fare: String(notificationData.fare),
                distance: String(notificationData.distance),
                userFullName: String(notificationData.userFullName),
                userPhone: String(notificationData.userPhone),
                userProvince: String(notificationData.userProvince),
                type: String(type),
                isPeriodic: 'true',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                timestamp: new Date().toISOString(),
              };

              const pushMessage = {
                token: token,
                notification: {
                  title: title,
                  body: message,
                },
                data: stringifiedData,
                android: {
                  priority: 'high' as const,
                  notification: {
                    channelId: 'trip_notifications',
                    priority: 'high',
                    defaultSound: true,
                    defaultVibrateTimings: true,
                    icon: '@mipmap/ic_launcher',
                    color: '#2196F3',
                    sound: 'notification_sound',
                    vibrateTimingsMillis: [0, 500, 200, 500],
                    lightSettings: {
                      color: '#2196F3',
                      lightOnDurationMillis: 1000,
                      lightOffDurationMillis: 500,
                    },
                  },
                },
                apns: {
                  payload: {
                    aps: {
                      alert: {
                        title: title,
                        body: message,
                      },
                      sound: 'default',
                      badge: 1,
                      'content-available': 1,
                      'mutable-content': 1,
                      category: 'trip_notifications',
                      'thread-id': 'trip_notifications',
                    },
                    data: stringifiedData,
                  },
                  headers: {
                    'apns-priority': '10', // High priority for immediate delivery
                    'apns-push-type': 'alert', // Alert type for user-visible notifications
                  },
                },
              };
              
              return messaging.send(pushMessage);
            });
            
            const results = await Promise.allSettled(sendPromises);
            
            let successCount = 0;
            let failureCount = 0;
            
            results.forEach((result, index) => {
              if (result.status === 'fulfilled') {
                successCount++;
                console.log(`✅ Periodic notification sent to driver ${index + 1}: ${result.value}`);
              } else {
                failureCount++;
                console.error(`❌ Failed to send periodic notification to driver ${index + 1}:`, result.reason);
              }
            });
            
            console.log(`✅ Periodic iOS-compatible notifications sent: ${successCount} success, ${failureCount} failed`);
            
          } catch (firebaseError) {
            console.error('❌ Periodic iOS-compatible notification failed:', firebaseError);
            // Fall back to individual notifications using the old method
            console.log('Falling back to individual periodic notifications...');
            for (const driver of availableDrivers) {
              if (driver.deviceToken) {
                try {
                  await sendNotificationWithFallback(
                    driver.id,
                    title,
                    message,
                    {
                      ...notificationData,
                      isPeriodic: 'true',
                      timestamp: new Date().toISOString(),
                    },
                    type
                  );
                } catch (error) {
                  console.error(`❌ Failed to send periodic notification to driver ${driver.id}:`, error);
                }
              }
            }
          }
        }

        // Create database notifications for ALL drivers (with or without device tokens)
        for (const driver of availableDrivers) {
          try {
            await sendNotificationWithFallback(
              driver.id,
              title,
              message,
              {
                ...notificationData,
                isPeriodic: 'true',
                timestamp: new Date().toISOString(),
              },
              type
            );
          } catch (error) {
            console.error(`❌ Failed to create periodic database notification for driver ${driver.id}:`, error);
          }
        }

        console.log(`✅ Periodic notification sent to ${availableDrivers.length} drivers`);

      } catch (error) {
        console.error('❌ Error in periodic notification:', error);
      }
    }, 30000); // 30 seconds

    // Store the interval ID in a global map so we can stop it later
    if (!global.periodicNotificationIntervals) {
      global.periodicNotificationIntervals = new Map();
    }
    global.periodicNotificationIntervals.set(trip.id, intervalId);

    console.log(`✅ Periodic notifications started for trip ${trip.id} (every 30 seconds)`);

    // Stop periodic notifications after 10 minutes (20 notifications)
    setTimeout(() => {
      if (global.periodicNotificationIntervals?.has(trip.id)) {
        clearInterval(intervalId);
        global.periodicNotificationIntervals.delete(trip.id);
        console.log(`⏰ Periodic notifications stopped for trip ${trip.id} (10 minutes elapsed)`);
      }
    }, 600000); // 10 minutes

  } catch (error) {
    console.error('❌ Error starting periodic notifications:', error);
  }
}

// Function to stop periodic notifications for a specific trip
export async function stopPeriodicNotificationsForTrip(tripId: string) {
  try {
    if (global.periodicNotificationIntervals?.has(tripId)) {
      const intervalId = global.periodicNotificationIntervals.get(tripId);
      clearInterval(intervalId);
      global.periodicNotificationIntervals.delete(tripId);
      console.log(`✅ Periodic notifications stopped for trip ${tripId}`);
    }
  } catch (error) {
    console.error('❌ Error stopping periodic notifications:', error);
  }
} 
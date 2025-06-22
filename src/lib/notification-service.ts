import { prisma } from './prisma';

export interface NotificationData {
  tripId: string;
  previousStatus?: string;
  newStatus: string;
  pickupLocation: string;
  dropoffLocation: string;
  [key: string]: any;
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
      await prisma.notification.create({
        data: {
          userId: trip.userId,
          type: userType as any,
          title: userTitle,
          message: userMessage,
          data: notificationData,
        },
      });

      console.log(`📱 Notification sent to user ${trip.userId}: ${userTitle}`);
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
      await prisma.notification.create({
        data: {
          userId: trip.driverId,
          type: driverType as any,
          title: driverTitle,
          message: driverMessage,
          data: notificationData,
        },
      });

      console.log(`📱 Notification sent to driver ${trip.driverId}: ${driverTitle}`);
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
    await prisma.notification.create({
      data: {
        userId: driverId,
        type: type as any,
        title,
        message,
        data: notificationData,
      },
    });

    console.log(`📱 New trip notification sent to driver ${driverId}`);
  } catch (error) {
    console.error('Error sending new trip notification:', error);
  }
}

// New function to notify all active drivers about a new trip
export async function notifyAllActiveDriversAboutNewTrip(trip: any) {
  try {
    console.log('\n=== NOTIFYING ALL ACTIVE DRIVERS ABOUT NEW TRIP ===');
    console.log('Trip ID:', trip.id);
    console.log('Pickup:', trip.pickupLocation);
    console.log('Dropoff:', trip.dropoffLocation);
    console.log('Fare:', trip.price);

    // Get all active drivers (drivers who are not currently on a trip)
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        driver: {
          // Only get drivers who are not currently assigned to any active trips
          NOT: {
            taxiRequests: {
              some: {
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
            }
          }
        }
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${activeDrivers.length} active drivers to notify`);

    // Send notification to each active driver
    const notificationPromises = activeDrivers.map(async (driver) => {
      try {
        await sendNewTripNotification(trip, driver.id);
        console.log(`✅ Notification sent to driver: ${driver.driver?.fullName || driver.id}`);
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driver.id}:`, error);
      }
    });

    await Promise.all(notificationPromises);
    console.log('✅ All active drivers notified about new trip');

  } catch (error) {
    console.error('❌ Error notifying active drivers about new trip:', error);
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

    // Send notification to each driver
    const notificationPromises = allDrivers.map(async (driver) => {
      try {
        await sendNewTripNotification(trip, driver.id);
        console.log(`✅ Notification sent to driver: ${driver.driver?.fullName || driver.id}`);
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driver.id}:`, error);
      }
    });

    await Promise.all(notificationPromises);
    console.log('✅ All drivers notified about new trip');

  } catch (error) {
    console.error('❌ Error notifying all drivers about new trip:', error);
  }
} 
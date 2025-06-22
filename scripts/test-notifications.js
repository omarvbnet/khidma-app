const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testNotificationSystem() {
  console.log('\n=== COMPREHENSIVE NOTIFICATION SYSTEM TEST ===\n');

  try {
    // 1. Check all drivers
    console.log('1. CHECKING ALL DRIVERS...');
    const allDrivers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      include: { driver: true }
    });
    console.log(`   Total drivers: ${allDrivers.length}`);

    // 2. Check active drivers
    console.log('\n2. CHECKING ACTIVE DRIVERS...');
    const activeDrivers = allDrivers.filter(d => d.status === 'ACTIVE');
    console.log(`   Active drivers: ${activeDrivers.length}`);

    // 3. Check drivers with device tokens
    console.log('\n3. CHECKING DRIVERS WITH DEVICE TOKENS...');
    const driversWithTokens = activeDrivers.filter(d => d.deviceToken);
    console.log(`   Drivers with tokens: ${driversWithTokens.length}`);

    // 4. Check driver availability
    console.log('\n4. CHECKING DRIVER AVAILABILITY...');
    const availableDrivers = [];
    for (const driver of activeDrivers) {
      const activeTrips = await prisma.taxiRequest.findMany({
        where: {
          driverId: driver.id,
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
      
      const isAvailable = activeTrips.length === 0;
      if (isAvailable) {
        availableDrivers.push(driver);
      }
      
      console.log(`   ${driver.fullName}: ${isAvailable ? 'Available' : 'Busy'} (${activeTrips.length} active trips)`);
    }

    console.log(`   Available drivers: ${availableDrivers.length}`);

    // 5. Check recent trips
    console.log('\n5. CHECKING RECENT TRIPS...');
    const recentTrips = await prisma.taxiRequest.findMany({
      orderBy: { createdAt: 'desc' },
      take: 5,
      include: { user: true, driver: true }
    });
    
    console.log(`   Recent trips: ${recentTrips.length}`);
    recentTrips.forEach(trip => {
      console.log(`   - Trip ${trip.id}: ${trip.status} (User: ${trip.user?.fullName}, Driver: ${trip.driver?.fullName || 'None'})`);
    });

    // 6. Check notifications
    console.log('\n6. CHECKING RECENT NOTIFICATIONS...');
    const recentNotifications = await prisma.notification.findMany({
      orderBy: { createdAt: 'desc' },
      take: 10,
      include: { user: true }
    });
    
    console.log(`   Recent notifications: ${recentNotifications.length}`);
    recentNotifications.forEach(notification => {
      console.log(`   - ${notification.type}: ${notification.title} (User: ${notification.user?.fullName})`);
    });

    // 7. Summary
    console.log('\n=== SUMMARY ===');
    console.log(`Total drivers: ${allDrivers.length}`);
    console.log(`Active drivers: ${activeDrivers.length}`);
    console.log(`Drivers with device tokens: ${driversWithTokens.length}`);
    console.log(`Available drivers: ${availableDrivers.length}`);
    console.log(`Recent trips: ${recentTrips.length}`);
    console.log(`Recent notifications: ${recentNotifications.length}`);

    // 8. Recommendations
    console.log('\n=== RECOMMENDATIONS ===');
    if (activeDrivers.length === 0) {
      console.log('❌ No active drivers found. Drivers need to be set to ACTIVE status.');
    }
    
    if (driversWithTokens.length === 0) {
      console.log('❌ No drivers have device tokens. Drivers need to register their device tokens.');
    }
    
    if (availableDrivers.length === 0) {
      console.log('❌ No available drivers found. All drivers might be busy with trips.');
    }
    
    if (driversWithTokens.length > 0 && availableDrivers.length > 0) {
      console.log('✅ System appears to be properly configured for notifications.');
    }

  } catch (error) {
    console.error('Error testing notification system:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the test
testNotificationSystem(); 
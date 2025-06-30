const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testRoleBasedNotifications() {
  console.log('🧪 Testing Role-Based Notification System\n');

  try {
    // Get test users
    const users = await prisma.user.findMany({
      where: {
        deviceToken: { not: null },
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true,
        status: true,
        deviceToken: true,
        province: true,
      },
    });

    console.log('👥 Test users found:');
    users.forEach(user => {
      console.log(`  - ${user.fullName} (${user.id})`);
      console.log(`    Role: ${user.role}, Status: ${user.status}, Province: ${user.province}`);
      console.log(`    Token: ${user.deviceToken ? `${user.deviceToken.substring(0, 20)}...` : 'null'}`);
      console.log('');
    });

    if (users.length < 2) {
      console.log('❌ Need at least 2 users (one USER, one DRIVER) for testing');
      return;
    }

    // Find a USER and a DRIVER
    const testUser = users.find(u => u.role === 'USER' && u.status === 'ACTIVE');
    const testDriver = users.find(u => u.role === 'DRIVER' && u.status === 'ACTIVE');

    if (!testUser) {
      console.log('❌ No active USER found for testing');
      return;
    }

    if (!testDriver) {
      console.log('❌ No active DRIVER found for testing');
      return;
    }

    console.log('✅ Test users identified:');
    console.log(`  User: ${testUser.fullName} (${testUser.id})`);
    console.log(`  Driver: ${testDriver.fullName} (${testDriver.id})`);

    // Create a test trip
    console.log('\n🚗 Creating test trip...');
    const testTrip = await prisma.taxiRequest.create({
      data: {
        userId: testUser.id,
        pickupLocation: 'Test Pickup Location',
        dropoffLocation: 'Test Dropoff Location',
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        dropoffLat: 33.3152,
        dropoffLng: 44.3661,
        price: 5000,
        distance: 5.0,
        userFullName: testUser.fullName,
        userPhone: testUser.phoneNumber,
        userProvince: testUser.province,
        tripType: 'ECO',
        driverDeduction: 1000,
      },
    });

    console.log(`✅ Test trip created: ${testTrip.id}`);

    // Test 1: Simulate the role-based notification logic
    console.log('\n📱 Test 1: Simulating role-based notification logic...');
    
    // Get the trip details with user info
    const tripWithUser = await prisma.taxiRequest.findUnique({
      where: { id: testTrip.id },
      include: { user: true },
    });

    console.log('🚀 Trip details:', {
      tripId: tripWithUser.id,
      userId: tripWithUser.userId,
      userRole: tripWithUser.user.role,
      userProvince: tripWithUser.user.province,
    });

    // Verify the user is actually a USER (not a driver)
    if (tripWithUser.user.role !== 'USER') {
      console.log('❌ User is not a regular user, skipping notification');
      return;
    }

    // Get all active drivers in the user's province
    const drivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
        province: tripWithUser.user.province,
        deviceToken: { not: null },
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true,
        province: true,
        role: true,
        status: true,
      },
    });

    console.log(`🚗 Found ${drivers.length} active drivers in ${tripWithUser.user.province}:`);
    drivers.forEach(driver => {
      console.log(`  - ${driver.fullName} (${driver.id}) - Token: ${driver.deviceToken ? `${driver.deviceToken.substring(0, 20)}...` : 'null'}`);
    });

    if (drivers.length === 0) {
      console.log('❌ No active drivers found in province:', tripWithUser.user.province);
      return;
    }

    // Verify each driver's role before sending notification
    const validDrivers = drivers.filter(driver => {
      const isValid = driver.role === 'DRIVER' && driver.status === 'ACTIVE';
      if (!isValid) {
        console.log(`⚠️ Skipping driver ${driver.fullName} (${driver.id}): role=${driver.role}, status=${driver.status}`);
      }
      return isValid;
    });

    console.log(`✅ ${validDrivers.length} valid drivers to notify out of ${drivers.length} total`);

    if (validDrivers.length === 0) {
      console.log('❌ No valid drivers found after role verification');
      return;
    }

    // Test 2: Create notifications for valid drivers only
    console.log('\n📋 Test 2: Creating notifications for valid drivers...');
    
    let driversNotified = 0;
    for (const driver of validDrivers) {
      try {
        // Create notification in database
        await prisma.notification.create({
          data: {
            userId: driver.id,
            type: 'NEW_TRIP_AVAILABLE',
            title: 'New Trip Available',
            message: `New trip from ${tripWithUser.pickupLocation} to ${tripWithUser.dropoffLocation}`,
            data: {
              tripId: tripWithUser.id,
              pickupLocation: tripWithUser.pickupLocation,
              dropoffLocation: tripWithUser.dropoffLocation,
              price: tripWithUser.price,
              distance: tripWithUser.distance,
            },
          },
        });

        console.log(`📱 Notification created for driver ${driver.fullName} (${driver.id})`);
        driversNotified++;
      } catch (error) {
        console.error(`❌ Failed to create notification for driver ${driver.fullName}:`, error);
      }
    }

    console.log(`✅ Successfully created notifications for ${driversNotified} drivers`);

    // Test 3: Check if notifications were created for drivers only
    console.log('\n📋 Test 3: Checking notification database entries...');
    
    const notifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        data: {
          path: ['tripId'],
          equals: testTrip.id,
        },
      },
      include: {
        user: {
          select: {
            fullName: true,
            role: true,
          },
        },
      },
    });

    console.log(`📨 Found ${notifications.length} notifications for trip ${testTrip.id}:`);
    notifications.forEach(notification => {
      console.log(`  - ${notification.user.fullName} (${notification.user.role})`);
      console.log(`    Title: ${notification.title}`);
      console.log(`    Message: ${notification.message}`);
    });

    // Test 4: Verify only drivers received notifications
    const driverNotifications = notifications.filter(n => n.user.role === 'DRIVER');
    const userNotifications = notifications.filter(n => n.user.role === 'USER');

    console.log('\n🎯 Test 4: Role verification results:');
    console.log(`  - Drivers notified: ${driverNotifications.length}`);
    console.log(`  - Users notified: ${userNotifications.length}`);

    if (driverNotifications.length > 0 && userNotifications.length === 0) {
      console.log('✅ SUCCESS: Only drivers received notifications!');
    } else {
      console.log('❌ FAILURE: Users received driver notifications or drivers did not receive notifications');
    }

    // Test 5: Verify notification content
    console.log('\n📝 Test 5: Verifying notification content...');
    if (driverNotifications.length > 0) {
      const notification = driverNotifications[0];
      console.log('  - Title:', notification.title);
      console.log('  - Message:', notification.message);
      console.log('  - Data:', notification.data);
      
      if (notification.title === 'New Trip Available' && 
          notification.message.includes('Test Pickup Location') &&
          notification.message.includes('Test Dropoff Location')) {
        console.log('✅ SUCCESS: Notification content is correct!');
      } else {
        console.log('❌ FAILURE: Notification content is incorrect');
      }
    }

    // Test 6: Verify device token uniqueness
    console.log('\n🔑 Test 6: Verifying device token uniqueness...');
    const allUsersWithTokens = await prisma.user.findMany({
      where: {
        deviceToken: { not: null },
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true,
        role: true,
      },
    });

    const tokenCounts = {};
    allUsersWithTokens.forEach(user => {
      if (user.deviceToken) {
        tokenCounts[user.deviceToken] = (tokenCounts[user.deviceToken] || 0) + 1;
      }
    });

    const duplicateTokens = Object.entries(tokenCounts).filter(([token, count]) => count > 1);
    
    if (duplicateTokens.length === 0) {
      console.log('✅ SUCCESS: No duplicate device tokens found!');
    } else {
      console.log('❌ FAILURE: Found duplicate device tokens:');
      duplicateTokens.forEach(([token, count]) => {
        console.log(`  - Token ${token.substring(0, 20)}... used by ${count} users`);
      });
    }

    // Cleanup
    console.log('\n🧹 Cleaning up test data...');
    await prisma.notification.deleteMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        data: {
          path: ['tripId'],
          equals: testTrip.id,
        },
      },
    });
    await prisma.taxiRequest.delete({
      where: { id: testTrip.id },
    });
    console.log('✅ Test data cleaned up');

    console.log('\n🎉 Role-based notification system test completed!');

  } catch (error) {
    console.error('❌ Error testing role-based notifications:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the test
testRoleBasedNotifications(); 
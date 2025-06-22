import { PrismaClient } from '@prisma/client';
import fetch from 'node-fetch';

const prisma = new PrismaClient();

async function testTripCreation() {
  console.log('\n=== TESTING TRIP CREATION AND NOTIFICATION FLOW ===\n');

  try {
    // 1. Check if we have a test user
    console.log('1. CHECKING TEST USER...');
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' }
    });

    if (!testUser) {
      console.log('❌ No test user found. Please create a user first.');
      return;
    }

    console.log(`✅ Found test user: ${testUser.fullName} (${testUser.id})`);

    // 2. Check if we have active drivers
    console.log('\n2. CHECKING ACTIVE DRIVERS...');
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      }
    });

    console.log(`Found ${activeDrivers.length} active drivers:`);
    for (const driver of activeDrivers) {
      console.log(`   - ${driver.fullName} (${driver.id})`);
      console.log(`     Token: ${driver.deviceToken ? 'Present' : 'Missing'}`);
      console.log(`     Platform: ${driver.platform || 'Unknown'}`);
    }

    if (activeDrivers.length === 0) {
      console.log('❌ No active drivers found. Cannot test notifications.');
      return;
    }

    // 3. Create a test trip via API
    console.log('\n3. CREATING TEST TRIP VIA API...');
    
    const tripData = {
      pickupLocation: 'Test Pickup Location',
      dropoffLocation: 'Test Dropoff Location',
      pickupLat: 33.3152,
      pickupLng: 44.3661,
      dropoffLat: 33.3152,
      dropoffLng: 44.3661,
      price: 5000,
      distance: 5.0,
      tripType: 'ECO',
      driverDeduction: 500,
      userProvince: 'Baghdad',
      userPhone: testUser.phoneNumber,
      userFullName: testUser.fullName,
    };

    console.log('Trip data:', tripData);

    // Get user token (you'll need to implement proper authentication)
    // For now, we'll create the trip directly in the database
    console.log('\n4. CREATING TRIP IN DATABASE...');
    
    const testTrip = await prisma.taxiRequest.create({
      data: {
        ...tripData,
        userId: testUser.id,
        status: 'USER_WAITING'
      }
    });

    console.log(`✅ Trip created: ${testTrip.id}`);

    // 5. Test notification function directly
    console.log('\n5. TESTING NOTIFICATION FUNCTION...');
    
    // Import the notification function
    const { notifyAvailableDriversAboutNewTrip } = await import('../src/lib/notification-service.ts');
    
    try {
      await notifyAvailableDriversAboutNewTrip(testTrip);
      console.log('✅ Notification function completed');
    } catch (error) {
      console.log('❌ Notification function failed:', error.message);
    }

    // 6. Check if notifications were created in database
    console.log('\n6. CHECKING DATABASE NOTIFICATIONS...');
    
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 5 * 60 * 1000) // Last 5 minutes
        }
      },
      include: {
        user: true
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    console.log(`Found ${recentNotifications.length} recent notifications:`);
    for (const notification of recentNotifications) {
      console.log(`   - ${notification.title} for ${notification.user.fullName}`);
      console.log(`     Type: ${notification.type}`);
      console.log(`     Created: ${notification.createdAt}`);
    }

    // 7. Check Firebase environment variables
    console.log('\n7. CHECKING FIREBASE ENVIRONMENT...');
    
    const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
    const hasClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
    const hasPrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;

    console.log(`   FIREBASE_PROJECT_ID: ${hasProjectId ? '✅ Set' : '❌ Missing'}`);
    console.log(`   FIREBASE_CLIENT_EMAIL: ${hasClientEmail ? '✅ Set' : '❌ Missing'}`);
    console.log(`   FIREBASE_PRIVATE_KEY: ${hasPrivateKey ? '✅ Set' : '❌ Missing'}`);

    // 8. Test Firebase directly
    if (hasProjectId && hasClientEmail && hasPrivateKey) {
      console.log('\n8. TESTING FIREBASE DIRECTLY...');
      
      try {
        const { sendPushNotification } = await import('../src/lib/firebase-admin.ts');
        
        const testDriver = activeDrivers[0];
        if (testDriver.deviceToken) {
          console.log(`Testing with driver: ${testDriver.fullName}`);
          console.log(`Token: ${testDriver.deviceToken.substring(0, 30)}...`);
          
          await sendPushNotification({
            token: testDriver.deviceToken,
            title: 'Test Notification',
            body: 'This is a test notification from the diagnostic script',
            data: {
              test: 'true',
              timestamp: new Date().toISOString()
            }
          });
          
          console.log('✅ Firebase notification sent successfully');
        } else {
          console.log('❌ Test driver has no device token');
        }
      } catch (error) {
        console.log('❌ Firebase test failed:', error.message);
      }
    } else {
      console.log('❌ Cannot test Firebase - missing environment variables');
    }

    // 9. Clean up test trip
    console.log('\n9. CLEANING UP...');
    await prisma.taxiRequest.delete({
      where: { id: testTrip.id }
    });
    console.log('✅ Test trip deleted');

    // 10. Summary
    console.log('\n=== SUMMARY ===');
    console.log(`Test user: ${testUser.fullName}`);
    console.log(`Active drivers: ${activeDrivers.length}`);
    console.log(`Drivers with tokens: ${activeDrivers.filter(d => d.deviceToken).length}`);
    console.log(`Recent notifications: ${recentNotifications.length}`);
    console.log(`Firebase configured: ${hasProjectId && hasClientEmail && hasPrivateKey}`);

  } catch (error) {
    console.error('❌ Error during test:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the test
testTripCreation(); 
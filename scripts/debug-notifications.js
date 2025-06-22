const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function debugNotificationSystem() {
  console.log('\n=== NOTIFICATION SYSTEM DEBUG SCRIPT ===\n');

  try {
    // 1. Check Firebase environment variables
    console.log('1. CHECKING FIREBASE ENVIRONMENT...');
    const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
    const hasClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
    const hasPrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;
    
    console.log(`   FIREBASE_PROJECT_ID: ${hasProjectId ? 'SET' : 'NOT SET'}`);
    console.log(`   FIREBASE_CLIENT_EMAIL: ${hasClientEmail ? 'SET' : 'NOT SET'}`);
    console.log(`   FIREBASE_PRIVATE_KEY: ${hasPrivateKey ? 'SET' : 'NOT SET'}`);
    
    if (hasProjectId && hasClientEmail && hasPrivateKey) {
      console.log('   ✅ Firebase environment is configured');
    } else {
      console.log('   ❌ Firebase environment is NOT configured');
      console.log('   Please check your .env.local file or Vercel environment variables');
    }

    // 2. Check all drivers
    console.log('\n2. CHECKING ALL DRIVERS...');
    const allDrivers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      select: {
        id: true,
        fullName: true,
        status: true,
        deviceToken: true,
        platform: true
      }
    });
    
    console.log(`   Total drivers: ${allDrivers.length}`);
    
    for (const driver of allDrivers) {
      console.log(`   - ${driver.fullName} (${driver.id})`);
      console.log(`     Status: ${driver.status}`);
      console.log(`     Platform: ${driver.platform || 'unknown'}`);
      console.log(`     Device Token: ${driver.deviceToken ? 'YES' : 'NO'}`);
      if (driver.deviceToken) {
        console.log(`     Token Preview: ${driver.deviceToken.substring(0, 20)}...`);
      }
    }

    // 3. Check active drivers
    console.log('\n3. CHECKING ACTIVE DRIVERS...');
    const activeDrivers = allDrivers.filter(d => d.status === 'ACTIVE');
    console.log(`   Active drivers: ${activeDrivers.length}`);
    
    if (activeDrivers.length === 0) {
      console.log('   ❌ No active drivers found!');
      console.log('   This is likely the main issue.');
      console.log('   Drivers need to have status = "ACTIVE" to receive notifications.');
    } else {
      console.log('   ✅ Active drivers found');
    }

    // 4. Check drivers with device tokens
    console.log('\n4. CHECKING DRIVERS WITH DEVICE TOKENS...');
    const driversWithTokens = activeDrivers.filter(d => d.deviceToken);
    console.log(`   Active drivers with tokens: ${driversWithTokens.length}`);
    
    if (driversWithTokens.length === 0) {
      console.log('   ❌ No active drivers have device tokens!');
      console.log('   This could be the issue.');
      console.log('   Check if the Flutter app is properly sending device tokens to the backend.');
    } else {
      console.log('   ✅ Active drivers with tokens found');
    }

    // 5. Check driver availability
    console.log('\n5. CHECKING DRIVER AVAILABILITY...');
    const availableDrivers = [];
    const busyDrivers = [];
    
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
      
      if (activeTrips.length === 0) {
        availableDrivers.push(driver);
        console.log(`   ✅ ${driver.fullName} - Available (no active trips)`);
      } else {
        busyDrivers.push(driver);
        console.log(`   ⏳ ${driver.fullName} - Busy (${activeTrips.length} active trips)`);
      }
    }
    
    console.log(`\n   Available drivers: ${availableDrivers.length}`);
    console.log(`   Busy drivers: ${busyDrivers.length}`);

    // 6. Check recent trips
    console.log('\n6. CHECKING RECENT TRIPS...');
    const recentTrips = await prisma.taxiRequest.findMany({
      where: {
        createdAt: {
          gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 5
    });
    
    console.log(`   Recent trips (last 24h): ${recentTrips.length}`);
    for (const trip of recentTrips) {
      console.log(`   - Trip ${trip.id}: ${trip.status} (${trip.pickupLocation} → ${trip.dropoffLocation})`);
    }

    // 7. Check recent notifications
    console.log('\n7. CHECKING RECENT NOTIFICATIONS...');
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 10
    });
    
    console.log(`   Recent NEW_TRIP_AVAILABLE notifications: ${recentNotifications.length}`);
    for (const notification of recentNotifications) {
      console.log(`   - ${notification.user?.fullName} (${notification.user?.role}): ${notification.title}`);
    }

    // 8. Summary and recommendations
    console.log('\n=== SUMMARY AND RECOMMENDATIONS ===');
    
    if (activeDrivers.length === 0) {
      console.log('❌ MAIN ISSUE: No active drivers found');
      console.log('   SOLUTION: Update driver status to ACTIVE in the database');
      console.log('   SQL: UPDATE "User" SET status = \'ACTIVE\' WHERE role = \'DRIVER\';');
    } else if (driversWithTokens.length === 0) {
      console.log('❌ MAIN ISSUE: No active drivers have device tokens');
      console.log('   SOLUTION: Check Flutter app device token registration');
      console.log('   - Verify device token is being sent to /api/flutter/users/device-token');
      console.log('   - Check if notifications are enabled in the app');
    } else if (availableDrivers.length === 0) {
      console.log('❌ MAIN ISSUE: All active drivers are busy');
      console.log('   SOLUTION: Wait for drivers to complete their trips');
    } else if (!hasProjectId || !hasClientEmail || !hasPrivateKey) {
      console.log('❌ MAIN ISSUE: Firebase not configured');
      console.log('   SOLUTION: Set Firebase environment variables in Vercel');
    } else {
      console.log('✅ System appears to be configured correctly');
      console.log('   If notifications still not working, check:');
      console.log('   - Vercel deployment logs');
      console.log('   - Firebase console for delivery status');
      console.log('   - Flutter app notification permissions');
    }

    console.log('\n=== NEXT STEPS ===');
    console.log('1. Test the comprehensive debug endpoint:');
    console.log('   POST /api/flutter/notifications/debug-comprehensive');
    console.log('2. Check Vercel deployment logs for errors');
    console.log('3. Test with a real trip creation from the Flutter app');
    console.log('4. Verify Firebase project settings and APNs certificate');

  } catch (error) {
    console.error('❌ Debug script failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the debug script
debugNotificationSystem(); 
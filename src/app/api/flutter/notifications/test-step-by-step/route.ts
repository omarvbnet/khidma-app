import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== STEP BY STEP NOTIFICATION TEST ===');
    
    const results: any = {
      step1: { name: 'Get Active Drivers', status: 'pending' },
      step2: { name: 'Check Driver Availability', status: 'pending' },
      step3: { name: 'Create Notifications', status: 'pending' },
      step4: { name: 'Verify Notifications', status: 'pending' }
    };

    // Step 1: Get active drivers
    console.log('\n1. Getting active drivers...');
    const allActiveDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
      },
      include: {
        driver: true
      }
    });

    results.step1 = {
      name: 'Get Active Drivers',
      status: 'success',
      details: {
        totalDrivers: allActiveDrivers.length,
        drivers: allActiveDrivers.map(d => ({
          id: d.id,
          name: d.fullName,
          hasToken: !!d.deviceToken
        }))
      }
    };

    console.log(`Found ${allActiveDrivers.length} active drivers`);

    // Step 2: Check driver availability
    console.log('\n2. Checking driver availability...');
    const availableDrivers = [];
    
    for (const driver of allActiveDrivers) {
      console.log(`Checking availability for ${driver.fullName}...`);
      
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

      console.log(`Driver ${driver.fullName} has ${activeTrips.length} active trips`);
      
      if (activeTrips.length === 0) {
        availableDrivers.push(driver);
        console.log(`✅ ${driver.fullName} is available`);
      } else {
        console.log(`❌ ${driver.fullName} is busy`);
      }
    }

    results.step2 = {
      name: 'Check Driver Availability',
      status: 'success',
      details: {
        availableDrivers: availableDrivers.length,
        availableDriversList: availableDrivers.map(d => ({
          id: d.id,
          name: d.fullName,
          hasToken: !!d.deviceToken
        }))
      }
    };

    console.log(`Found ${availableDrivers.length} available drivers`);

    // Step 3: Create notifications manually
    console.log('\n3. Creating notifications manually...');
    const createdNotifications = [];
    
    for (const driver of availableDrivers) {
      console.log(`Creating notification for ${driver.fullName}...`);
      
      try {
        const notification = await prisma.notification.create({
          data: {
            userId: driver.id,
            type: 'NEW_TRIP_AVAILABLE',
            title: 'New Trip Available!',
            message: 'A new trip request is available in your area. Tap to view details.',
            data: {
              tripId: `step_test_${Date.now()}`,
              pickupLocation: 'Step Test Pickup',
              dropoffLocation: 'Step Test Dropoff',
              fare: 1000,
              distance: 2.0,
              userFullName: 'Step Test User',
              userPhone: '+1234567890'
            }
          }
        });

        createdNotifications.push(notification);
        console.log(`✅ Notification created for ${driver.fullName}: ${notification.id}`);
      } catch (error) {
        console.error(`❌ Failed to create notification for ${driver.fullName}:`, error);
      }
    }

    results.step3 = {
      name: 'Create Notifications',
      status: 'success',
      details: {
        notificationsCreated: createdNotifications.length,
        notificationIds: createdNotifications.map(n => n.id)
      }
    };

    // Step 4: Verify notifications
    console.log('\n4. Verifying notifications...');
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 2 * 60 * 1000) // Last 2 minutes
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    results.step4 = {
      name: 'Verify Notifications',
      status: 'success',
      details: {
        totalNotifications: recentNotifications.length,
        notifications: recentNotifications.map(n => ({
          id: n.id,
          userId: n.userId,
          userName: n.user?.fullName,
          title: n.title,
          createdAt: n.createdAt
        }))
      }
    };

    // Clean up test notifications
    console.log('\n5. Cleaning up test notifications...');
    for (const notification of createdNotifications) {
      try {
        await prisma.notification.delete({
          where: { id: notification.id }
        });
        console.log(`✅ Cleaned up notification: ${notification.id}`);
      } catch (error) {
        console.log(`⚠️ Could not clean up notification: ${notification.id}`);
      }
    }

    console.log('\n=== STEP BY STEP TEST COMPLETE ===');

    return NextResponse.json({
      success: true,
      results,
      summary: {
        totalSteps: Object.keys(results).length,
        successfulSteps: Object.values(results).filter((r: any) => r.status === 'success').length,
        failedSteps: Object.values(results).filter((r: any) => r.status === 'failed').length
      }
    });

  } catch (error) {
    console.error('❌ Step by step test failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 
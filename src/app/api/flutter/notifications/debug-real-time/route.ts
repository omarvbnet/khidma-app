import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== REAL-TIME TRIP CREATION DEBUG ===');
    
    // Get a test user
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
      },
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    console.log('Using test user:', testUser);

    // Step 1: Check system state before trip creation
    console.log('\n1. CHECKING SYSTEM STATE BEFORE TRIP CREATION...');
    
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true
      }
    });

    console.log(`Found ${activeDrivers.length} active drivers before trip creation`);
    for (const driver of activeDrivers) {
      console.log(`- ${driver.fullName} (${driver.id}) - Has Token: ${!!driver.deviceToken}`);
    }

    // Step 2: Create trip exactly like real flow
    console.log('\n2. CREATING TRIP...');
    
    const createData = {
      pickupLocation: 'Real-time Test Pickup',
      dropoffLocation: 'Real-time Test Dropoff',
      pickupLat: 33.3152,
      pickupLng: 44.3661,
      dropoffLat: 33.3152,
      dropoffLng: 44.3661,
      price: 5000,
      distance: 5.0,
      status: TaxiRequest_status.USER_WAITING,
      tripType: 'ECO',
      driverDeduction: 0,
      userPhone: testUser.phoneNumber,
      userFullName: testUser.fullName,
      userProvince: testUser.province,
      userId: testUser.id
    } as const;

    console.log('Creating trip with data:', createData);

    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('✅ Trip created successfully:', taxiRequest.id);

    // Step 3: Call notification function with detailed logging
    console.log('\n3. CALLING NOTIFICATION FUNCTION...');
    
    let notificationResult = 'failed';
    let notificationError = null;
    let notificationsCreated = 0;
    
    try {
      console.log('Starting notifyAvailableDriversAboutNewTrip...');
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      notificationResult = 'success';
      console.log('✅ Notification function completed successfully');
    } catch (error) {
      notificationError = error instanceof Error ? error.message : 'Unknown error';
      console.error('❌ Notification function failed:', error);
    }

    // Step 4: Check what notifications were actually created
    console.log('\n4. CHECKING CREATED NOTIFICATIONS...');
    
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

    notificationsCreated = recentNotifications.length;
    console.log(`Found ${notificationsCreated} recent NEW_TRIP_AVAILABLE notifications`);

    // Step 5: Check driver availability after trip creation
    console.log('\n5. CHECKING DRIVER AVAILABILITY AFTER TRIP CREATION...');
    
    const availableDriversAfter: typeof activeDrivers = [];
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
        availableDriversAfter.push(driver);
        console.log(`✅ ${driver.fullName} is available (no active trips)`);
      } else {
        console.log(`❌ ${driver.fullName} is busy (${activeTrips.length} active trips)`);
      }
    }

    // Step 6: Check Firebase environment
    console.log('\n6. CHECKING FIREBASE ENVIRONMENT...');
    
    const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
    const hasClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
    const hasPrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;
    
    console.log(`Firebase Project ID: ${hasProjectId ? 'SET' : 'NOT SET'}`);
    console.log(`Firebase Client Email: ${hasClientEmail ? 'SET' : 'NOT SET'}`);
    console.log(`Firebase Private Key: ${hasPrivateKey ? 'SET' : 'NOT SET'}`);

    // Clean up test trip
    console.log('\n7. CLEANING UP TEST TRIP...');
    await prisma.taxiRequest.delete({
      where: { id: taxiRequest.id }
    });
    console.log('✅ Test trip cleaned up');

    // Return comprehensive results
    return NextResponse.json({
      success: true,
      timestamp: new Date().toISOString(),
      tripCreation: {
        tripId: taxiRequest.id,
        status: taxiRequest.status,
        pickupLocation: taxiRequest.pickupLocation,
        dropoffLocation: taxiRequest.dropoffLocation
      },
      systemState: {
        activeDrivers: activeDrivers.length,
        availableDrivers: availableDriversAfter.length,
        driversWithTokens: activeDrivers.filter(d => d.deviceToken).length
      },
      notificationProcess: {
        result: notificationResult,
        error: notificationError,
        notificationsCreated: notificationsCreated
      },
      firebaseConfig: {
        hasProjectId,
        hasClientEmail,
        hasPrivateKey,
        isConfigured: hasProjectId && hasClientEmail && hasPrivateKey
      },
      drivers: activeDrivers.map(d => ({
        id: d.id,
        name: d.fullName,
        hasToken: !!d.deviceToken,
        isAvailable: availableDriversAfter.some(ad => ad.id === d.id)
      })),
      notifications: recentNotifications.map(n => ({
        id: n.id,
        userId: n.userId,
        userName: n.user?.fullName,
        title: n.title,
        message: n.message,
        createdAt: n.createdAt
      }))
    });

  } catch (error) {
    console.error('❌ Real-time debug failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Debug failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== CURRENT SYSTEM STATUS ===');
    
    // Get current system status
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true
      }
    });

    const availableDrivers: typeof activeDrivers = [];
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
      }
    }

    const hasFirebaseConfig = !!(process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY);

    return NextResponse.json({
      success: true,
      timestamp: new Date().toISOString(),
      systemStatus: {
        activeDrivers: activeDrivers.length,
        availableDrivers: availableDrivers.length,
        driversWithTokens: activeDrivers.filter(d => d.deviceToken).length,
        firebaseConfigured: hasFirebaseConfig,
        systemReady: activeDrivers.length > 0 && availableDrivers.length > 0 && hasFirebaseConfig
      },
      drivers: activeDrivers.map(d => ({
        id: d.id,
        name: d.fullName,
        hasToken: !!d.deviceToken,
        isAvailable: availableDrivers.some(ad => ad.id === d.id)
      }))
    });

  } catch (error) {
    console.error('❌ Status check failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Status check failed'
    }, { status: 500 });
  }
} 
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== DEBUGGING DATA STRUCTURE DIFFERENCES ===');
    
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

    // Create trip data exactly like the real flow
    const createData = {
      pickupLocation: 'Test Pickup Location',
      dropoffLocation: 'Test Dropoff Location',
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

    console.log('Creating taxi request with data:', createData);

    // Create taxi request
    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('Successfully created taxi request:', taxiRequest);

    // Analyze the trip object structure
    console.log('\n=== TRIP OBJECT ANALYSIS ===');
    console.log('Trip ID:', taxiRequest.id);
    console.log('Trip Type:', typeof taxiRequest);
    console.log('Trip Keys:', Object.keys(taxiRequest));
    
    // Check specific fields that the notification function uses
    const notificationFields = {
      id: taxiRequest.id,
      pickupLocation: taxiRequest.pickupLocation,
      dropoffLocation: taxiRequest.dropoffLocation,
      price: taxiRequest.price,
      distance: taxiRequest.distance,
      userFullName: taxiRequest.userFullName,
      userPhone: taxiRequest.userPhone
    };

    console.log('\n=== NOTIFICATION FIELDS ===');
    for (const [key, value] of Object.entries(notificationFields)) {
      console.log(`${key}: ${value} (${typeof value})`);
    }

    // Check if any fields are undefined or null
    const missingFields = Object.entries(notificationFields)
      .filter(([key, value]) => value === undefined || value === null)
      .map(([key]) => key);

    if (missingFields.length > 0) {
      console.log('\n❌ MISSING FIELDS:', missingFields);
    } else {
      console.log('\n✅ All notification fields are present');
    }

    // Test the notification function with this exact object
    console.log('\n=== TESTING NOTIFICATION FUNCTION ===');
    let notificationResult = 'success';
    let notificationError = null;
    
    try {
      const { notifyAvailableDriversAboutNewTrip } = await import('@/lib/notification-service');
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      console.log('✅ Notification function completed successfully');
    } catch (error) {
      notificationError = error instanceof Error ? error.message : 'Unknown error';
      console.error('❌ Notification function failed:', error);
      notificationResult = 'failed';
    }

    // Check if notifications were created
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

    // Clean up
    await prisma.taxiRequest.delete({
      where: { id: taxiRequest.id }
    });

    return NextResponse.json({
      success: true,
      tripAnalysis: {
        id: taxiRequest.id,
        type: typeof taxiRequest,
        keys: Object.keys(taxiRequest),
        notificationFields,
        missingFields
      },
      notificationResult,
      notificationError,
      notificationsCreated: recentNotifications.length,
      notificationDetails: recentNotifications.map(n => ({
        id: n.id,
        userId: n.userId,
        userName: n.user?.fullName,
        title: n.title,
        message: n.message
      }))
    });

  } catch (error) {
    console.error('❌ Data structure debug failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Debug failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== CHECKING RECENT TRIP STRUCTURES ===');
    
    // Get recent trips to analyze their structure
    const recentTrips = await prisma.taxiRequest.findMany({
      where: {
        createdAt: {
          gte: new Date(Date.now() - 60 * 60 * 1000) // Last hour
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 5
    });

    const tripAnalysis = recentTrips.map(trip => ({
      id: trip.id,
      status: trip.status,
      createdAt: trip.createdAt,
      hasRequiredFields: {
        id: !!trip.id,
        pickupLocation: !!trip.pickupLocation,
        dropoffLocation: !!trip.dropoffLocation,
        price: !!trip.price,
        distance: !!trip.distance,
        userFullName: !!trip.userFullName,
        userPhone: !!trip.userPhone
      },
      fieldTypes: {
        id: typeof trip.id,
        pickupLocation: typeof trip.pickupLocation,
        dropoffLocation: typeof trip.dropoffLocation,
        price: typeof trip.price,
        distance: typeof trip.distance,
        userFullName: typeof trip.userFullName,
        userPhone: typeof trip.userPhone
      }
    }));

    return NextResponse.json({
      success: true,
      recentTrips: tripAnalysis,
      totalTrips: recentTrips.length
    });

  } catch (error) {
    console.error('❌ Recent trips analysis failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Analysis failed'
    }, { status: 500 });
  }
} 
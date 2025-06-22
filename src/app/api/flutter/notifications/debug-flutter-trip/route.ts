import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { JwtPayload } from 'jsonwebtoken';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

// Middleware to verify JWT token
async function verifyToken(req: NextRequest) {
  const token = req.headers.get('authorization')?.split(' ')[1];
  if (!token) return null;

  try {
    const decoded = verify(token, process.env.JWT_SECRET!) as JwtPayload;
    return (decoded as any).userId;
  } catch (error) {
    return null;
  }
}

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== DEBUGGING FLUTTER TRIP CREATION ===');
    
    const userId = await verifyToken(req);
    if (!userId) {
      return NextResponse.json({
        success: false,
        error: 'Unauthorized'
      }, { status: 401 });
    }

    const body = await req.json();
    console.log('Flutter app sent this data:', JSON.stringify(body, null, 2));

    // Check what fields the Flutter app is sending
    const expectedFields = [
      'pickupLocation', 'dropoffLocation', 'price', 'distance',
      'pickupLat', 'pickupLng', 'dropoffLat', 'dropoffLng',
      'status', 'userId', 'userFullName', 'userPhone', 'tripType', 'driverDeduction', 'userProvince'
    ];

    const missingFields = expectedFields.filter(field => !(field in body));
    const extraFields = Object.keys(body).filter(field => !expectedFields.includes(field));

    console.log('Missing fields:', missingFields);
    console.log('Extra fields:', extraFields);

    // Get user details
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
      },
    });

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'User not found'
      }, { status: 404 });
    }

    // Create the trip with the exact data from Flutter
    const createData = {
      pickupLocation: body.pickupLocation || 'Test Pickup',
      dropoffLocation: body.dropoffLocation || 'Test Dropoff',
      pickupLat: Number(body.pickupLat) || 33.3152,
      pickupLng: Number(body.pickupLng) || 44.3661,
      dropoffLat: Number(body.dropoffLat) || 33.3152,
      dropoffLng: Number(body.dropoffLng) || 44.3661,
      price: Number(body.price) || 1000,
      distance: Number(body.distance) || 1.0,
      status: 'USER_WAITING',
      tripType: body.tripType || 'ECO',
      driverDeduction: Number(body.driverDeduction) || 0,
      userPhone: body.userPhone || user.phoneNumber,
      userFullName: body.userFullName || user.fullName,
      userProvince: body.userProvince || user.province,
      userId: user.id
    };

    console.log('Creating trip with data:', createData);

    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('✅ Trip created successfully:', taxiRequest.id);

    // Test notification
    console.log('\n=== TESTING NOTIFICATION ===');
    try {
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      console.log('✅ Notification sent successfully');
    } catch (error) {
      console.error('❌ Notification failed:', error);
    }

    // Check if notifications were created
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 1 * 60 * 1000) // Last 1 minute
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    console.log(`Found ${recentNotifications.length} recent notifications`);

    // Clean up
    await prisma.taxiRequest.delete({
      where: { id: taxiRequest.id }
    });

    return NextResponse.json({
      success: true,
      message: 'Flutter trip creation test completed',
      analysis: {
        missingFields,
        extraFields,
        fieldCount: Object.keys(body).length,
        expectedFieldCount: expectedFields.length
      },
      tripCreated: {
        id: taxiRequest.id,
        pickupLocation: taxiRequest.pickupLocation,
        dropoffLocation: taxiRequest.dropoffLocation,
        price: taxiRequest.price
      },
      notificationsCreated: recentNotifications.length,
      user: {
        id: user.id,
        name: user.fullName,
        phone: user.phoneNumber
      }
    });

  } catch (error) {
    console.error('❌ Flutter trip debug failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Debug failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== FLUTTER TRIP CREATION GUIDE ===');
    
    return NextResponse.json({
      success: true,
      message: 'Flutter trip creation debug endpoint',
      instructions: [
        'Send a POST request with the exact data your Flutter app sends',
        'Include Authorization: Bearer <token> header',
        'This will analyze the data and test trip creation + notifications',
        'The endpoint will show what fields are missing or extra'
      ],
      expectedFields: [
        'pickupLocation', 'dropoffLocation', 'price', 'distance',
        'pickupLat', 'pickupLng', 'dropoffLat', 'dropoffLng',
        'status', 'userId', 'userFullName', 'userPhone', 'tripType', 'driverDeduction', 'userProvince'
      ],
      exampleData: {
        pickupLocation: 'Baghdad Airport',
        dropoffLocation: 'Baghdad City Center',
        price: 5000,
        distance: 5.0,
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        dropoffLat: 33.3152,
        dropoffLng: 44.3661,
        status: 'USER_WAITING',
        tripType: 'ECO',
        driverDeduction: 500,
        userProvince: 'Baghdad'
      }
    });

  } catch (error) {
    console.error('❌ Guide failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Guide failed'
    }, { status: 500 });
  }
} 
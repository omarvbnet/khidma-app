import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { TaxiRequest, User, Driver, TaxiRequest_status, Prisma } from '@prisma/client';
import { JwtPayload } from 'jsonwebtoken';
import { notifyAvailableDriversAboutNewTrip, startPeriodicNotificationsForTrip, stopPeriodicNotificationsForTrip } from '@/lib/notification-service';

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

// Get user's taxi requests
export async function GET(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    // Get user role
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    if (!user) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const requests = (await prisma.taxiRequest.findMany({
      where: {
        OR: [
          { status: TaxiRequest_status.USER_WAITING },
          { status: TaxiRequest_status.DRIVER_ACCEPTED },
          { status: TaxiRequest_status.DRIVER_IN_WAY },
          { status: TaxiRequest_status.DRIVER_ARRIVED },
          { status: TaxiRequest_status.USER_PICKED_UP },
          { status: TaxiRequest_status.DRIVER_IN_PROGRESS },
        ],
        userId: userId,
      },
      include: {
        user: {
          select: {
            fullName: true,
            phoneNumber: true,
            province: true,
          }
        },
        driver: {
          select: {
            fullName: true,
            phoneNumber: true,
            carId: true,
            carType: true,
            licenseId: true,
            rate: true,
          }
        }
      }
    })) as any;

    const formattedRequests = requests.map((request: any) => {
      // Ensure coordinates are valid numbers
      const coordinates = {
        pickupLat: Number(request.pickupLat),
        pickupLng: Number(request.pickupLng),
        dropoffLat: Number(request.dropoffLat),
        dropoffLng: Number(request.dropoffLng)
      };

      // Validate coordinates
      if (Object.values(coordinates).some(isNaN) || 
          coordinates.pickupLat === 0 || coordinates.pickupLng === 0 ||
          coordinates.dropoffLat === 0 || coordinates.dropoffLng === 0) {
        console.error('Invalid coordinates in request:', request.id, coordinates);
        throw new Error('Invalid coordinates in request');
      }

      return {
        id: request.id,
        pickupLocation: request.pickupLocation || 'Baghdad',
        dropoffLocation: request.dropoffLocation || 'Baghdad',
        pickupLat: coordinates.pickupLat,
        pickupLng: coordinates.pickupLng,
        dropoffLat: coordinates.dropoffLat,
        dropoffLng: coordinates.dropoffLng,
        price: Number(request.price || 0),
        distance: Number(request.distance || 0),
        status: request.status,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
        userId: request.userId,
        userFullName: request.user?.fullName || 'Unknown',
        userPhone: request.user?.phoneNumber || 'Unknown',
        userProvince: request.user?.province || 'Baghdad',
        driverId: request.driverId,
        driverName: request.driver?.fullName || 'Unknown',
        carId: request.driver?.carId || 'Unknown',
        carType: request.driver?.carType || 'Unknown',
        driverRate: Number(request.driver?.rate || 0),
        tripType: request.tripType || 'ECO',
        driverDeduction: Number(request.driverDeduction || 0),
      };
    });

    return NextResponse.json({ requests: formattedRequests || [] });
  } catch (error) {
    console.error('Error fetching taxi requests:', error);
    return NextResponse.json(
      { requests: [] },
      { status: 500 }
    );
  }
}

// Create new taxi request
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await req.json();
    console.log('Received request body:', body);

    const {
      pickupLocation,
      dropoffLocation,
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
      price,
      distance,
      tripType,
      driverDeduction,
      userProvince,
      userPhone,
      userFullName,
    } = body;

    // Validate required fields
    if (!pickupLocation || !dropoffLocation || !price || !distance) {
      console.log('Missing required fields:', { pickupLocation, dropoffLocation, price, distance });
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Validate coordinates
    if (!pickupLat || !pickupLng || !dropoffLat || !dropoffLng) {
      console.log('Missing coordinate fields:', { pickupLat, pickupLng, dropoffLat, dropoffLng });
      return NextResponse.json(
        { error: 'Missing coordinate fields' },
        { status: 400 }
      );
    }

    // Validate coordinate values
    const coordinates = {
      pickupLat: Number(pickupLat),
      pickupLng: Number(pickupLng),
      dropoffLat: Number(dropoffLat),
      dropoffLng: Number(dropoffLng)
    };

    // Check if coordinates are valid numbers and not zero
    if (Object.values(coordinates).some(isNaN) ||
        coordinates.pickupLat === 0 || coordinates.pickupLng === 0 ||
        coordinates.dropoffLat === 0 || coordinates.dropoffLng === 0) {
      console.log('Invalid coordinate values:', coordinates);
      return NextResponse.json(
        { error: 'Invalid coordinate values: coordinates cannot be zero or NaN' },
        { status: 400 }
      );
    }

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
      console.log('User not found:', userId);
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    const createData = {
      pickupLocation,
      dropoffLocation,
      pickupLat: coordinates.pickupLat,
      pickupLng: coordinates.pickupLng,
      dropoffLat: coordinates.dropoffLat,
      dropoffLng: coordinates.dropoffLng,
      price: Number(price),
      distance: Number(distance),
      status: TaxiRequest_status.USER_WAITING,
      tripType: tripType || 'ECO',
      driverDeduction: Number(driverDeduction || 0),
      userPhone: userPhone || user.phoneNumber,
      userFullName: userFullName || user.fullName,
      userProvince: userProvince || user.province,
      userId: user.id
    } as const;

    console.log('Creating taxi request with data:', createData);

    // Create taxi request
    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('Successfully created taxi request:', taxiRequest);

    // Notify all available drivers about the new trip
    try {
      console.log('\n=== STARTING DRIVER NOTIFICATION PROCESS ===');
      console.log('Trip details for notification:', {
        id: taxiRequest.id,
        pickupLocation: taxiRequest.pickupLocation,
        dropoffLocation: taxiRequest.dropoffLocation,
        price: taxiRequest.price,
        userFullName: taxiRequest.userFullName,
        userPhone: taxiRequest.userPhone
      });
      
      // Add a small delay to ensure the trip is fully committed
      await new Promise(resolve => setTimeout(resolve, 100));
      
      console.log('Calling notifyAvailableDriversAboutNewTrip...');
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      console.log('✅ All available drivers notified about new trip');
      
      // Start periodic notifications every 30 seconds
      console.log('Starting periodic notifications...');
      await startPeriodicNotificationsForTrip(taxiRequest);
      console.log('✅ Periodic notifications started for new trip');
      
      // Verify notifications were created
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
      
      console.log(`✅ Verification: ${recentNotifications.length} notifications created for this trip`);
      
    } catch (notificationError) {
      console.error('❌ Error notifying drivers about new trip:', notificationError);
      console.error('Notification error details:', {
        message: notificationError instanceof Error ? notificationError.message : 'Unknown error',
        stack: notificationError instanceof Error ? notificationError.stack : 'No stack trace'
      });
      // Don't fail the request if notification fails
    }

    return NextResponse.json(taxiRequest, { status: 201 });
  } catch (error) {
    console.error('Error creating taxi request:', error);
    if (error instanceof Error) {
      console.error('Error details:', error.message);
      console.error('Error stack:', error.stack);
    }
    return NextResponse.json(
      { error: 'Failed to create taxi request', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
}

// Update taxi request status
export async function PATCH(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id, status } = await req.json();

    if (!id || !status) {
      return NextResponse.json(
        { error: 'Trip ID and status are required' },
        { status: 400 }
      );
    }

    const taxiRequest = await prisma.taxiRequest.findUnique({
      where: { id },
    });

    if (!taxiRequest || taxiRequest.userId !== userId) {
      return NextResponse.json(
        { error: 'Trip not found or unauthorized' },
        { status: 404 }
      );
    }

    const updatedRequest = await prisma.taxiRequest.update({
      where: { id },
      data: { status },
      include: {
        driver: {
          select: {
            id: true,
            fullName: true,
            phoneNumber: true,
            carId: true,
            carType: true,
            licenseId: true,
            rate: true,
          },
        },
      },
    });

    // Stop periodic notifications when a trip status changes from USER_WAITING
    if (status === TaxiRequest_status.DRIVER_ACCEPTED || status === TaxiRequest_status.DRIVER_IN_WAY ||
        status === TaxiRequest_status.DRIVER_ARRIVED || status === TaxiRequest_status.USER_PICKED_UP ||
        status === TaxiRequest_status.DRIVER_IN_PROGRESS) {
      await stopPeriodicNotificationsForTrip(id);
    }

    return NextResponse.json(updatedRequest);
  } catch (error) {
    console.error('Error updating taxi request status:', error);
    return NextResponse.json(
      { error: 'Failed to update taxi request status' },
      { status: 500 }
    );
  }
} 
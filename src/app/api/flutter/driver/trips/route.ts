import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { TaxiRequest_status, TaxiRequest, Prisma } from '@prisma/client';
import { sendTripStatusNotification } from '@/lib/notification-service';

// Middleware to verify JWT token
async function verifyToken(req: NextRequest) {
  const authHeader = req.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };
    return decoded.userId;
  } catch (error) {
    return null;
  }
}

// Get driver's trips
export async function GET(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: true
      }
    });

    if (!user || user.role !== 'DRIVER') {
      return NextResponse.json({ error: 'Driver not found' }, { status: 404 });
    }

    console.log('Driver ID:', userId);
    console.log('User role:', user?.role);
    console.log('Driver profile:', user?.driver);
    console.log('Driver province:', user?.province);

    // Get driver's province
    const driverProvince = user.province;
    
    if (!driverProvince) {
      console.log('❌ Driver has no province set');
      return NextResponse.json({ 
        error: 'Driver province not set. Please update your profile.' 
      }, { status: 400 });
    }

    // Get all trips for this driver and waiting trips from the same province
    const trips = await prisma.taxiRequest.findMany({
      where: { 
        OR: [
          // Driver's own trips (accepted trips)
          { driver: { userId: userId } },
          { driverId: user.driver?.id },
          // Waiting trips from users in the same province
          { 
            AND: [
              { status: TaxiRequest_status.USER_WAITING },
              { userProvince: driverProvince }
            ]
          }
        ]
      },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        status: true,
        driverId: true,
        createdAt: true,
        pickupLocation: true,
        dropoffLocation: true,
        price: true,
        distance: true,
        userId: true,
        userFullName: true,
        userPhone: true,
        userProvince: true,
        tripType: true,
        driverDeduction: true,
        driverPhone: true,
        driverName: true,
        carId: true,
        carType: true,
        licenseId: true,
        driverRate: true,
        dropoffLat: true,
        dropoffLng: true,
        pickupLat: true,
        pickupLng: true
      }
    });

    console.log('All trips found:', trips.map(t => ({ 
      id: t.id, 
      status: t.status,
      driverId: t.driverId,
      userProvince: t.userProvince,
      createdAt: t.createdAt
    })));

    // Separate waiting trips from driver's own trips
    const waitingTrips = trips.filter(trip => trip.status === TaxiRequest_status.USER_WAITING);
    const driverTrips = trips.filter(trip => trip.status !== TaxiRequest_status.USER_WAITING);

    console.log(`📊 Trip Summary for driver in ${driverProvince}:`);
    console.log(`- Total trips found: ${trips.length}`);
    console.log(`- Waiting trips in same province: ${waitingTrips.length}`);
    console.log(`- Driver's own trips: ${driverTrips.length}`);

    const responseData = {
      trips: trips.map(trip => ({
        id: trip.id,
        status: trip.status,
        pickupLocation: trip.pickupLocation,
        dropoffLocation: trip.dropoffLocation,
        price: trip.price,
        distance: trip.distance,
        createdAt: trip.createdAt,
        driverId: trip.driverId,
        userId: trip.userId,
        userFullName: trip.userFullName,
        userPhone: trip.userPhone,
        userProvince: trip.userProvince,
        tripType: trip.tripType,
        driverDeduction: trip.driverDeduction,
        driverPhone: trip.driverPhone,
        driverName: trip.driverName,
        carId: trip.carId,
        carType: trip.carType,
        licenseId: trip.licenseId,
        driverRate: trip.driverRate,
        dropoffLat: trip.dropoffLat,
        dropoffLng: trip.dropoffLng,
        pickupLat: trip.pickupLat,
        pickupLng: trip.pickupLng
      })),
      driverProvince: driverProvince,
      tripCounts: {
        total: trips.length,
        waiting: waitingTrips.length,
        driverOwn: driverTrips.length
      }
    };

    console.log('Response data:', JSON.stringify(responseData, null, 2));

    return NextResponse.json(responseData);
  } catch (error) {
    console.error('Error fetching driver trips:', error);
    return NextResponse.json(
      { error: 'Failed to fetch driver trips' },
      { status: 500 }
    );
  }
}

// Update trip status
export async function PUT(req: NextRequest) {
  console.log('\n=== TRIP STATUS UPDATE REQUEST ===');
  
  const userId = await verifyToken(req);
  if (!userId) {
    console.log('❌ Unauthorized - No valid token');
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  
  console.log('✅ Authenticated user ID:', userId);

  try {
    const body = await req.json();
    console.log('📝 Request body:', body);
    
    const { tripId, status } = body;

    if (!tripId || !status) {
      console.log('❌ Missing required fields:', { tripId, status });
      return NextResponse.json(
        { error: 'Trip ID and status are required' },
        { status: 400 }
      );
    }

    console.log('🎯 Updating trip:', tripId, 'to status:', status);

    // Get user to check role
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: true,
      },
    });

    if (!user || user.role !== 'DRIVER') {
      console.log('❌ User not found or not a driver:', { userId, role: user?.role });
      return NextResponse.json(
        { error: 'Driver not found' },
        { status: 404 }
      );
    }

    console.log('✅ Driver found:', user.driver?.id);

    const trip = await prisma.taxiRequest.findUnique({
      where: { id: tripId }
    });

    if (!trip) {
      console.log('❌ Trip not found:', tripId);
      return NextResponse.json(
        { error: 'Trip not found' },
        { status: 404 }
      );
    }

    console.log('✅ Trip found:', { 
      id: trip.id, 
      currentStatus: trip.status, 
      driverId: trip.driverId,
      requestedStatus: status 
    });

    // Validate status transitions
    const validTransitions: { [key: string]: string[] } = {
      'USER_WAITING': ['DRIVER_ACCEPTED', 'TRIP_CANCELLED'],
      'DRIVER_ACCEPTED': ['DRIVER_IN_WAY', 'TRIP_CANCELLED'],
      'DRIVER_IN_WAY': ['DRIVER_ARRIVED', 'TRIP_CANCELLED'],
      'DRIVER_ARRIVED': ['USER_PICKED_UP', 'TRIP_CANCELLED'],
      'USER_PICKED_UP': ['DRIVER_IN_PROGRESS', 'TRIP_CANCELLED'],
      'DRIVER_IN_PROGRESS': ['TRIP_COMPLETED', 'TRIP_CANCELLED'],
      'TRIP_COMPLETED': [],
      'TRIP_CANCELLED': [],
    };

    console.log('🔍 Valid transitions for', trip.status, ':', validTransitions[trip.status]);

    if (!validTransitions[trip.status]?.includes(status)) {
      console.log('❌ Invalid status transition:', {
        currentStatus: trip.status,
        newStatus: status,
        validTransitions: validTransitions[trip.status]
      });
      return NextResponse.json(
        { error: `Invalid status transition from ${trip.status} to ${status}` },
        { status: 400 }
      );
    }

    console.log('✅ Status transition is valid');

    const updateData: any = {
      status: status,
      updatedAt: new Date(),
    };

    // Set appropriate timestamps based on status
    if (status === 'DRIVER_ACCEPTED') {
      updateData.acceptedAt = new Date();
    } else if (status === 'TRIP_COMPLETED') {
      updateData.completedAt = new Date();
      console.log('📅 Setting completedAt timestamp');
    }

    // If accepting the trip, add driver information
    if (status === 'DRIVER_ACCEPTED') {
      updateData.driverId = user.driver?.id;
      updateData.driverName = user.driver?.fullName;
      updateData.driverPhone = user.driver?.phoneNumber;
      updateData.carId = user.driver?.carId;
      updateData.carType = user.driver?.carType;
      updateData.licenseId = user.driver?.licenseId;
      updateData.driverRate = user.driver?.rate;
    }

    console.log('💾 Update data:', updateData);

    const updatedTrip = await prisma.taxiRequest.update({
      where: { id: tripId },
      data: updateData,
      include: {
        user: true,
        driver: true,
      },
    });

    console.log('✅ Trip updated successfully:', {
      id: updatedTrip.id,
      status: updatedTrip.status,
      completedAt: updatedTrip.completedAt
    });

    // Send notifications based on status change
    try {
      await sendTripStatusNotification(updatedTrip, trip.status, status);
    } catch (notificationError) {
      console.error('❌ Error sending notification:', notificationError);
      // Don't fail the request if notification fails
    }

    return NextResponse.json({
      id: updatedTrip.id,
      status: updatedTrip.status,
      pickupLocation: updatedTrip.pickupLocation,
      dropoffLocation: updatedTrip.dropoffLocation,
      price: updatedTrip.price,
      distance: updatedTrip.distance,
      createdAt: updatedTrip.createdAt,
      acceptedAt: updatedTrip.acceptedAt,
      completedAt: updatedTrip.completedAt,
      user: updatedTrip.user,
      driver: updatedTrip.driver
    });
  } catch (error) {
    console.error('❌ Error updating trip status:', error);
    return NextResponse.json(
      { error: 'Failed to update trip status' },
      { status: 500 }
    );
  }
} 
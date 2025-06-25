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
      requestedStatus: status,
      price: trip.price,
      driverBudget: user.budget
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

    // Handle budget deduction when accepting trip
    if (status === 'DRIVER_ACCEPTED') {
      console.log('\n💰 PROCESSING BUDGET DEDUCTION ===');
      
      // Calculate 12% of trip price
      const deductionAmount = trip.price * 0.12;
      console.log('Trip price:', trip.price);
      console.log('Deduction amount (12%):', deductionAmount);
      console.log('Driver current budget:', user.budget);
      
      // Check if driver has sufficient budget
      if (user.budget < deductionAmount) {
        console.log('❌ Insufficient budget for trip acceptance');
        console.log('Required:', deductionAmount);
        console.log('Available:', user.budget);
        console.log('Shortfall:', deductionAmount - user.budget);
        
        return NextResponse.json(
          { 
            error: 'Insufficient budget to accept this trip',
            required: deductionAmount,
            available: user.budget,
            shortfall: deductionAmount - user.budget
          },
          { status: 400 }
        );
      }
      
      console.log('✅ Sufficient budget available');
    }

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

    // If accepting the trip, add driver information and handle budget deduction
    if (status === 'DRIVER_ACCEPTED') {
      const deductionAmount = trip.price * 0.12;
      
      updateData.driverId = user.driver?.id;
      updateData.driverName = user.driver?.fullName;
      updateData.driverPhone = user.driver?.phoneNumber;
      updateData.carId = user.driver?.carId;
      updateData.carType = user.driver?.carType;
      updateData.licenseId = user.driver?.licenseId;
      updateData.driverRate = user.driver?.rate;
      updateData.driverDeduction = deductionAmount;
      
      console.log('💰 Setting driver deduction:', deductionAmount);
    }

    console.log('💾 Update data:', updateData);

    // Use a transaction to ensure both trip update and budget deduction happen atomically
    const result = await prisma.$transaction(async (tx) => {
      // Update the trip
      const updatedTrip = await tx.taxiRequest.update({
        where: { id: tripId },
        data: updateData,
        include: {
          user: true,
          driver: true,
        },
      });

      // If accepting the trip, deduct from driver's budget
      if (status === 'DRIVER_ACCEPTED') {
        const deductionAmount = trip.price * 0.12;
        
        const updatedUser = await tx.user.update({
          where: { id: userId },
          data: {
            budget: {
              decrement: deductionAmount
            }
          }
        });
        
        console.log('✅ Budget deducted successfully');
        console.log('New budget balance:', updatedUser.budget);
        
        // Log the budget transaction
        await tx.userLog.create({
          data: {
            userId: userId,
            type: 'BUDGET_DEDUCTION',
            details: `Deduction of ${deductionAmount} for trip ${tripId}`,
            oldValue: user.budget.toString(),
            newValue: updatedUser.budget.toString(),
            changedById: userId, // Driver is changing their own budget
          }
        });
        
        console.log('✅ Budget transaction logged');
      }

      return updatedTrip;
    });

    console.log('✅ Trip updated successfully:', {
      id: result.id,
      status: result.status,
      completedAt: result.completedAt,
      driverDeduction: result.driverDeduction
    });

    // Send notifications based on status change
    try {
      await sendTripStatusNotification(result, trip.status, status);
    } catch (notificationError) {
      console.error('❌ Error sending notification:', notificationError);
      // Don't fail the request if notification fails
    }

    return NextResponse.json({
      id: result.id,
      status: result.status,
      pickupLocation: result.pickupLocation,
      dropoffLocation: result.dropoffLocation,
      price: result.price,
      distance: result.distance,
      createdAt: result.createdAt,
      acceptedAt: result.acceptedAt,
      completedAt: result.completedAt,
      driverDeduction: result.driverDeduction,
      user: result.user,
      driver: result.driver
    });
  } catch (error) {
    console.error('❌ Error updating trip status:', error);
    return NextResponse.json(
      { error: 'Failed to update trip status' },
      { status: 500 }
    );
  }
} 
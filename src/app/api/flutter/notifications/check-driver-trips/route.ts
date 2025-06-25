import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== CHECKING DRIVER TRIPS ===');

    const { deviceToken } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');

    // Find the driver with this device token
    const driver = await prisma.user.findFirst({
      where: {
        role: 'DRIVER',
        deviceToken: deviceToken
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
        status: true,
        deviceToken: true
      }
    });

    if (!driver) {
      return NextResponse.json(
        { error: 'Driver with this device token not found' },
        { status: 404 }
      );
    }

    console.log('Found driver:', driver.fullName, 'in province:', driver.province);

    // Check all trips for this driver
    const allTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: driver.id
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    console.log(`Driver has ${allTrips.length} total trips`);

    // Check active trips (the ones that make driver unavailable)
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
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    console.log(`Driver has ${activeTrips.length} active trips`);

    return NextResponse.json({
      message: 'Driver trips check completed',
      driver: {
        id: driver.id,
        fullName: driver.fullName,
        phoneNumber: driver.phoneNumber,
        province: driver.province,
        status: driver.status,
        hasDeviceToken: !!driver.deviceToken
      },
      trips: {
        total: allTrips.length,
        active: activeTrips.length,
        isAvailable: activeTrips.length === 0,
        allTrips: allTrips.map(trip => ({
          id: trip.id,
          status: trip.status,
          pickupLocation: trip.pickupLocation,
          dropoffLocation: trip.dropoffLocation,
          createdAt: trip.createdAt,
          updatedAt: trip.updatedAt
        })),
        activeTrips: activeTrips.map(trip => ({
          id: trip.id,
          status: trip.status,
          pickupLocation: trip.pickupLocation,
          dropoffLocation: trip.dropoffLocation,
          createdAt: trip.createdAt,
          updatedAt: trip.updatedAt
        }))
      }
    });

  } catch (error) {
    console.error('Error checking driver trips:', error);
    return NextResponse.json(
      { error: 'Failed to check driver trips' },
      { status: 500 }
    );
  }
} 
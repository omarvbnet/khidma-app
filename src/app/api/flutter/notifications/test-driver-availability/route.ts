import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== TESTING DRIVER AVAILABILITY DIRECTLY ===');
    
    // Get the driver
    const driver = await prisma.user.findFirst({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        status: true,
        deviceToken: true
      }
    });

    if (!driver) {
      return NextResponse.json({
        success: false,
        error: 'No active driver found'
      });
    }

    console.log(`Testing availability for driver: ${driver.fullName} (${driver.id})`);

    // Check all trips for this driver
    const allTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: driver.id
      },
      select: {
        id: true,
        status: true,
        pickupLocation: true,
        dropoffLocation: true,
        createdAt: true
      },
      orderBy: { createdAt: 'desc' }
    });

    console.log(`Driver has ${allTrips.length} total trips`);

    // Check active trips (the ones that make driver busy)
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
      select: {
        id: true,
        status: true,
        pickupLocation: true,
        dropoffLocation: true,
        createdAt: true
      }
    });

    console.log(`Driver has ${activeTrips.length} active trips`);

    // Check waiting trips (should not make driver busy)
    const waitingTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: driver.id,
        status: 'USER_WAITING'
      },
      select: {
        id: true,
        status: true,
        pickupLocation: true,
        dropoffLocation: true,
        createdAt: true
      }
    });

    console.log(`Driver has ${waitingTrips.length} waiting trips`);

    const isAvailable = activeTrips.length === 0;

    return NextResponse.json({
      success: true,
      driver: {
        id: driver.id,
        name: driver.fullName,
        status: driver.status,
        hasToken: !!driver.deviceToken
      },
      availability: {
        isAvailable,
        totalTrips: allTrips.length,
        activeTrips: activeTrips.length,
        waitingTrips: waitingTrips.length
      },
      allTrips: allTrips.map(t => ({
        id: t.id,
        status: t.status,
        pickupLocation: t.pickupLocation,
        dropoffLocation: t.dropoffLocation,
        createdAt: t.createdAt
      })),
      activeTrips: activeTrips.map(t => ({
        id: t.id,
        status: t.status,
        pickupLocation: t.pickupLocation,
        dropoffLocation: t.dropoffLocation,
        createdAt: t.createdAt
      })),
      waitingTrips: waitingTrips.map(t => ({
        id: t.id,
        status: t.status,
        pickupLocation: t.pickupLocation,
        dropoffLocation: t.dropoffLocation,
        createdAt: t.createdAt
      }))
    });

  } catch (error) {
    console.error('❌ Driver availability test failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 
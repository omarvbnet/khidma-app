import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

// Helper function to check if a driver is available for new trips
async function isDriverAvailable(driverId: string): Promise<boolean> {
  try {
    // Check if driver has any active trips
    const activeTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: driverId,
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

    // Driver is available if they have no active trips
    return activeTrips.length === 0;
  } catch (error) {
    console.error(`Error checking driver availability for ${driverId}:`, error);
    return false;
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== TESTING DRIVER AVAILABILITY ===');

    // Get all active drivers
    const allActiveDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allActiveDrivers.length} total active drivers`);

    // Check availability for each driver
    const driverStatus = [];
    for (const driver of allActiveDrivers) {
      const isAvailable = await isDriverAvailable(driver.id);
      
      // Get driver's current trips
      const currentTrips = await prisma.taxiRequest.findMany({
        where: {
          driverId: driver.id,
        },
        orderBy: {
          createdAt: 'desc'
        },
        take: 5
      });

      driverStatus.push({
        id: driver.id,
        name: driver.fullName,
        phone: driver.phoneNumber,
        status: driver.status,
        isAvailable,
        hasDeviceToken: !!driver.deviceToken,
        currentTrips: currentTrips.map(trip => ({
          id: trip.id,
          status: trip.status,
          createdAt: trip.createdAt
        }))
      });
    }

    const availableDrivers = driverStatus.filter(d => d.isAvailable);
    const unavailableDrivers = driverStatus.filter(d => !d.isAvailable);

    console.log(`Available drivers: ${availableDrivers.length}`);
    console.log(`Unavailable drivers: ${unavailableDrivers.length}`);

    return NextResponse.json({
      totalDrivers: allActiveDrivers.length,
      availableDrivers: availableDrivers.length,
      unavailableDrivers: unavailableDrivers.length,
      driverDetails: driverStatus
    });

  } catch (error) {
    console.error('Error testing driver availability:', error);
    return NextResponse.json(
      { error: 'Failed to test driver availability' },
      { status: 500 }
    );
  }
} 
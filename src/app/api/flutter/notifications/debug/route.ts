import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== DEBUGGING DRIVER NOTIFICATION SYSTEM ===');

    // Get all drivers
    const allDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER'
      },
      include: {
        driver: true
      }
    });

    console.log(`Total drivers in system: ${allDrivers.length}`);

    // Get active drivers
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      include: {
        driver: true
      }
    });

    console.log(`Active drivers: ${activeDrivers.length}`);

    // Check each driver's current trips
    const driverStatus = [];
    for (const driver of allDrivers) {
      const currentTrips = await prisma.taxiRequest.findMany({
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

      const isAvailable = currentTrips.length === 0;

      driverStatus.push({
        id: driver.id,
        name: driver.fullName,
        phone: driver.phoneNumber,
        status: driver.status,
        isActive: driver.status === 'ACTIVE',
        isAvailable,
        hasDeviceToken: !!driver.deviceToken,
        deviceTokenPreview: driver.deviceToken ? `${driver.deviceToken.substring(0, 20)}...` : 'None',
        activeTrips: currentTrips.length,
        currentTrips: currentTrips.map(trip => ({
          id: trip.id,
          status: trip.status,
          createdAt: trip.createdAt
        }))
      });
    }

    // Get recent taxi requests
    const recentRequests = await prisma.taxiRequest.findMany({
      where: {
        status: 'USER_WAITING'
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 5
    });

    // Get recent notifications
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE'
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 10
    });

    const summary = {
      totalDrivers: allDrivers.length,
      activeDrivers: activeDrivers.length,
      availableDrivers: driverStatus.filter(d => d.isActive && d.isAvailable).length,
      driversWithTokens: driverStatus.filter(d => d.hasDeviceToken).length,
      recentWaitingRequests: recentRequests.length,
      recentNotificationsCount: recentNotifications.length,
      driverDetails: driverStatus,
      recentRequests: recentRequests.map(req => ({
        id: req.id,
        status: req.status,
        pickup: req.pickupLocation,
        dropoff: req.dropoffLocation,
        createdAt: req.createdAt
      })),
      recentNotifications: recentNotifications.map(notif => ({
        id: notif.id,
        userId: notif.userId,
        title: notif.title,
        createdAt: notif.createdAt
      }))
    };

    console.log('Debug summary:', summary);

    return NextResponse.json(summary);

  } catch (error) {
    console.error('Error in debug endpoint:', error);
    return NextResponse.json(
      { error: 'Failed to get debug information' },
      { status: 500 }
    );
  }
} 
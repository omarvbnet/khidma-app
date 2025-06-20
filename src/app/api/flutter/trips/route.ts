import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

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

export async function GET(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!user) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const trips = await prisma.taxiRequest.findMany({
      where: {
        OR: [
          { userId: userId },
          { driverId: userId }
        ]
      },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            fullName: true,
            phoneNumber: true,
          }
        },
        driver: {
          select: {
            fullName: true,
            phoneNumber: true,
            carType: true,
          }
        }
      }
    });

    return NextResponse.json({
      trips: trips.map(trip => ({
        id: trip.id,
        status: trip.status,
        pickupLocation: trip.pickupLocation,
        dropoffLocation: trip.dropoffLocation,
        price: trip.price,
        distance: trip.distance,
        createdAt: trip.createdAt,
        user: trip.user,
        driver: trip.driver
      }))
    });
  } catch (error) {
    console.error('Error fetching trips:', error);
    return NextResponse.json(
      { error: 'Failed to fetch trips' },
      { status: 500 }
    );
  }
} 
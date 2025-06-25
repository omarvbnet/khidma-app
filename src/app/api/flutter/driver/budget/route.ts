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

// Get driver's current budget
export async function GET(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        budget: true,
        role: true,
      }
    });

    if (!user || user.role !== 'DRIVER') {
      return NextResponse.json({ error: 'Driver not found' }, { status: 404 });
    }

    return NextResponse.json({
      budget: user.budget,
      driverName: user.fullName,
      currency: 'IQD' // Iraqi Dinar
    });
  } catch (error) {
    console.error('Error fetching driver budget:', error);
    return NextResponse.json(
      { error: 'Failed to fetch driver budget' },
      { status: 500 }
    );
  }
}

// Check if driver can afford a specific trip
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { tripId } = await req.json();

    if (!tripId) {
      return NextResponse.json(
        { error: 'Trip ID is required' },
        { status: 400 }
      );
    }

    // Get driver's budget
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        budget: true,
        role: true,
      }
    });

    if (!user || user.role !== 'DRIVER') {
      return NextResponse.json({ error: 'Driver not found' }, { status: 404 });
    }

    // Get trip details
    const trip = await prisma.taxiRequest.findUnique({
      where: { id: tripId },
      select: {
        id: true,
        price: true,
        status: true,
        pickupLocation: true,
        dropoffLocation: true,
      }
    });

    if (!trip) {
      return NextResponse.json({ error: 'Trip not found' }, { status: 404 });
    }

    if (trip.status !== 'USER_WAITING') {
      return NextResponse.json(
        { error: 'Trip is not available for acceptance' },
        { status: 400 }
      );
    }

    // Calculate deduction (12% of trip price)
    const deductionAmount = trip.price * 0.12;
    const canAfford = user.budget >= deductionAmount;

    return NextResponse.json({
      canAfford,
      currentBudget: user.budget,
      tripPrice: trip.price,
      deductionAmount,
      shortfall: canAfford ? 0 : deductionAmount - user.budget,
      tripDetails: {
        id: trip.id,
        pickupLocation: trip.pickupLocation,
        dropoffLocation: trip.dropoffLocation,
        price: trip.price
      },
      currency: 'IQD'
    });
  } catch (error) {
    console.error('Error checking trip affordability:', error);
    return NextResponse.json(
      { error: 'Failed to check trip affordability' },
      { status: 500 }
    );
  }
} 
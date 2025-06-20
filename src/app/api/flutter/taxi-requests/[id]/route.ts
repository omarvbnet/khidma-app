import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { TaxiRequest_status } from '@prisma/client';
import { auth } from '@/lib/auth';

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

export async function GET(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    const userId = await verifyToken(request);
    if (!userId) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const { id } = await context.params;
    const taxiRequest = await prisma.taxiRequest.findUnique({
      where: { id },
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

    if (!taxiRequest) {
      return NextResponse.json(
        { error: 'Taxi request not found' },
        { status: 404 }
      );
    }

    // Validate coordinates
    if (!taxiRequest.dropoffLat || !taxiRequest.dropoffLng || 
        taxiRequest.dropoffLat === 0 || taxiRequest.dropoffLng === 0) {
      return NextResponse.json(
        { error: 'Invalid dropoff coordinates' },
        { status: 400 }
      );
    }

    if (!taxiRequest.pickupLat || !taxiRequest.pickupLng || 
        taxiRequest.pickupLat === 0 || taxiRequest.pickupLng === 0) {
      return NextResponse.json(
        { error: 'Invalid pickup coordinates' },
        { status: 400 }
      );
    }

    return NextResponse.json(taxiRequest);
  } catch (error) {
    console.error('Error fetching taxi request:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { status } = await req.json();

    if (!status) {
      return NextResponse.json(
        { error: 'Status is required' },
        { status: 400 }
      );
    }

    // Validate status is a valid TaxiRequest_status
    if (!Object.values(TaxiRequest_status).includes(status as TaxiRequest_status)) {
      return NextResponse.json(
        { error: 'Invalid status value' },
        { status: 400 }
      );
    }

    const taxiRequest = await prisma.taxiRequest.findUnique({
      where: { id },
    });

    if (!taxiRequest) {
      return NextResponse.json(
        { error: 'Taxi request not found' },
        { status: 404 }
      );
    }

    const updatedRequest = await prisma.taxiRequest.update({
      where: { id },
      data: { 
        status: status as TaxiRequest_status,
        updatedAt: new Date()
      },
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

    console.log('Trip updated successfully:', updatedRequest.id);
    return NextResponse.json(updatedRequest);
  } catch (error) {
    console.error('Error updating taxi request status:', error);
    return NextResponse.json(
      { error: 'Failed to update taxi request status' },
      { status: 500 }
    );
  }
} 
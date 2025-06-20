import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { driverId } = await request.json();
    if (!driverId) {
      return NextResponse.json(
        { error: 'Driver ID is required' },
        { status: 400 }
      );
    }

    const driver = await prisma.driver.findUnique({
      where: { id: driverId },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        carId: true,
        carType: true,
        licenseId: true,
        rate: true,
      },
    });

    if (!driver) {
      return NextResponse.json({ error: 'Driver not found' }, { status: 404 });
    }

    const taxiRequest = await prisma.taxiRequest.update({
      where: { id },
      data: {
        driverId: driver.id,
        driverName: driver.fullName,
        driverPhone: driver.phoneNumber,
        carId: driver.carId,
        carType: driver.carType,
        licenseId: driver.licenseId,
        driverRate: driver.rate,
        status: 'DRIVER_ACCEPTED',
      },
    });

    return NextResponse.json(taxiRequest);
  } catch (error) {
    console.error('Error assigning driver:', error);
    return NextResponse.json(
      { error: 'Failed to assign driver' },
      { status: 500 }
    );
  }
} 
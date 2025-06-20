import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verifyToken } from '@/lib/jwt';

export async function GET(req: Request) {
  try {
    const userId = await verifyToken(req as any);
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Get user with driver profile
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: true,
      },
    });

    if (!user) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    if (!user.driver) {
      return NextResponse.json({ error: 'Driver profile not found' }, { status: 404 });
    }

    // Return driver profile with field names matching the client model
    return NextResponse.json({
      id: user.driver.id,
      name: user.driver.fullName,
      phone: user.driver.phoneNumber,
      status: user.status,
      role: user.role,
      budget: 0, // Default value
      province: user.province,
      carId: user.driver.carId,
      carNumber: user.driver.carId, // Using carId as carNumber
      carType: user.driver.carType,
      licenseId: user.driver.licenseId,
      rate: user.driver.rate,
      totalTrips: 0, // Default value
      createdAt: user.driver.createdAt,
    });
  } catch (error) {
    console.error('Error getting driver profile:', error);
    return NextResponse.json(
      { error: 'Failed to get driver profile' },
      { status: 500 }
    );
  }
}

export async function PATCH(req: Request) {
  try {
    const userId = await verifyToken(req as any);
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await req.json();
    const { name, phone, carId, carType, licenseId, rate } = body;

    // Get user with driver profile
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: true,
      },
    });

    if (!user) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    if (!user.driver) {
      return NextResponse.json({ error: 'Driver profile not found' }, { status: 404 });
    }

    // Update driver profile
    const updatedDriver = await prisma.driver.update({
      where: { id: user.driver.id },
      data: {
        fullName: name || user.driver.fullName,
        phoneNumber: phone || user.driver.phoneNumber,
        carId: carId || user.driver.carId,
        carType: carType || user.driver.carType,
        licenseId: licenseId || user.driver.licenseId,
        rate: rate || user.driver.rate,
      },
    });

    // Return updated driver profile with field names matching the client model
    return NextResponse.json({
      id: updatedDriver.id,
      name: updatedDriver.fullName,
      phone: updatedDriver.phoneNumber,
      status: user.status,
      role: user.role,
      budget: 0, // Default value
      province: user.province,
      carId: updatedDriver.carId,
      carNumber: updatedDriver.carId, // Using carId as carNumber
      carType: updatedDriver.carType,
      licenseId: updatedDriver.licenseId,
      rate: updatedDriver.rate,
      totalTrips: 0, // Default value
      createdAt: updatedDriver.createdAt,
    });
  } catch (error) {
    console.error('Error updating driver profile:', error);
    return NextResponse.json(
      { error: 'Failed to update driver profile' },
      { status: 500 }
    );
  }
} 
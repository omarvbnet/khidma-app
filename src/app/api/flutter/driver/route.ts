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

// Get driver profile
export async function GET(req: NextRequest) {
  try {
    const token = req.headers.get('Authorization')?.split(' ')[1];

    if (!token) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        driver: true,
      },
    });

    if (!user || !user.driver) {
      return NextResponse.json(
        { error: 'Driver not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      id: user.driver.id,
      fullName: user.driver.fullName,
      phoneNumber: user.driver.phoneNumber,
      carId: user.driver.carId,
      carType: user.driver.carType,
      licenseId: user.driver.licenseId,
      rate: user.driver.rate,
      status: user.status,
    });
  } catch (error) {
    console.error('Error in driver profile route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// Register as a driver
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { licenseId, carId, carType } = await req.json();

    if (!licenseId || !carId || !carType) {
      return NextResponse.json(
        { error: 'License ID, Car ID, and Car Type are required' },
        { status: 400 }
      );
    }

    // Check if user is already a driver
    const existingUser = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!existingUser) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    if (existingUser.role === 'DRIVER') {
      return NextResponse.json(
        { error: 'User is already registered as a driver' },
        { status: 400 }
      );
    }

    // Update user to driver
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        role: 'DRIVER',
        status: 'ACTIVE',
        driver: {
          create: {
            licenseId,
            carId,
            carType,
            fullName: existingUser.fullName,
            phoneNumber: existingUser.phoneNumber,
            rate: 0,
          }
        }
      },
      include: {
        driver: true,
      }
    }) as any;

    return NextResponse.json({
      id: user.id,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      province: user.province,
      licenseId: user.driver?.licenseId,
      carNumber: user.driver?.carId,
      carType: user.driver?.carType,
      carImage: user.driver?.carImage,
      driverImage: user.driver?.driverImage,
      licenseImage: user.driver?.licenseImage,
      status: user.status,
      rate: user.driver?.rate,
    });
  } catch (error) {
    console.error('Error registering driver:', error);
    return NextResponse.json(
      { error: 'Failed to register driver' },
      { status: 500 }
    );
  }
}

// Update driver profile
export async function PUT(req: NextRequest) {
  try {
    const token = req.headers.get('Authorization')?.split(' ')[1];

    if (!token) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };

    const { fullName, carId, carType, licenseId, rate } = await req.json();

    const user = await prisma.user.update({
      where: { id: decoded.userId },
      data: {
        driver: {
          update: {
            fullName: fullName || undefined,
            carId: carId || undefined,
            carType: carType || undefined,
            licenseId: licenseId || undefined,
            rate: rate || undefined,
          },
        },
      },
      include: {
        driver: true,
      },
    });

    if (!user.driver) {
      return NextResponse.json(
        { error: 'Driver not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      id: user.driver.id,
      fullName: user.driver.fullName,
      phoneNumber: user.driver.phoneNumber,
      carId: user.driver.carId,
      carType: user.driver.carType,
      licenseId: user.driver.licenseId,
      rate: user.driver.rate,
      status: user.status,
    });
  } catch (error) {
    console.error('Error in driver profile update route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
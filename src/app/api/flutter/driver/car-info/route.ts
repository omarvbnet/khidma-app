import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';

const prisma = new PrismaClient();

export async function GET(req: NextRequest) {
  try {
    // Get the JWT from the Authorization header
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('No authorization header or invalid format');
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    const token = authHeader.replace('Bearer ', '');
    let payload: any;
    try {
      payload = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
      console.log('Token payload:', payload);
    } catch (e) {
      console.log('Token verification failed:', e);
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }
    const userId = payload.userId;
    console.log('Looking up driver for user ID:', userId);

    // Find the driver record for this user
    const driver = await prisma.driver.findUnique({
      where: { userId },
      select: {
        id: true,
        carId: true,
        carType: true,
        licenseId: true,
        carImage: true,
        licenseImage: true,
        driverImage: true,
        rate: true,
        user: {
          select: {
            fullName: true,
            phoneNumber: true,
            email: true,
            province: true,
          },
        },
      },
    });

    console.log('Found driver:', driver);

    if (!driver) {
      console.log('No driver found for user ID:', userId);
      // Create a default driver record
      const newDriver = await prisma.driver.create({
        data: {
          userId,
          carId: 'N/A',
          carType: 'N/A',
          licenseId: 'N/A',
          rate: 0,
        },
        select: {
          id: true,
          carId: true,
          carType: true,
          licenseId: true,
          carImage: true,
          licenseImage: true,
          driverImage: true,
          rate: true,
          user: {
            select: {
              fullName: true,
              phoneNumber: true,
              email: true,
              province: true,
            },
          },
        },
      });
      console.log('Created default driver record:', newDriver);
      return NextResponse.json({ carInfo: newDriver });
    }

    // Format the response
    const carInfo = {
      id: driver.id,
      carId: driver.carId,
      carType: driver.carType,
      licenseId: driver.licenseId,
      carImage: driver.carImage,
      licenseImage: driver.licenseImage,
      driverImage: driver.driverImage,
      rate: driver.rate,
      driverName: driver.user.fullName,
      phoneNumber: driver.user.phoneNumber,
      email: driver.user.email,
      province: driver.user.province,
    };

    console.log('Sending car info:', carInfo);
    return NextResponse.json({ carInfo });
  } catch (error) {
    console.error('Car info error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
} 
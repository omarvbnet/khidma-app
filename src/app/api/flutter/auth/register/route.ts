import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Role, Prisma, User, Driver, UserStatus } from '@prisma/client';

export async function POST(req: Request) {
  try {
    const { phoneNumber, password, fullName, province = 'Baghdad', role = 'USER', carId, carType, licenseId, deviceToken, platform, appVersion, language } = await req.json();

    console.log('📱 Flutter registration attempt:', {
      phoneNumber,
      role,
      language,
      deviceToken: deviceToken ? `${deviceToken.substring(0, 20)}...` : 'not provided',
      platform,
      appVersion,
    });

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { phoneNumber },
    });

    if (existingUser) {
      return NextResponse.json(
        { error: 'User already exists' },
        { status: 400 }
      );
    }

    // Validate role
    if (!Object.values(Role).includes(role as Role)) {
      return NextResponse.json(
        { error: 'Invalid role. Must be one of: USER, DRIVER, ADMIN' },
        { status: 400 }
      );
    }

    // Validate driver fields if role is DRIVER
    if (role === 'DRIVER' && (!carId || !carType || !licenseId)) {
      return NextResponse.json(
        { error: 'Driver must provide carId, carType, and licenseId' },
        { status: 400 }
      );
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user with driver data if role is DRIVER
    const createUserData = {
        phoneNumber,
        password: hashedPassword,
        fullName,
        province,
      status: 'ACTIVE' as UserStatus,
      role: role as Role,
      deviceToken: deviceToken || null,
      platform: platform || null,
      appVersion: appVersion || null,
      language: language || null,
      driver: role === 'DRIVER' ? {
        create: {
          carId,
          carType,
          licenseId,
          rate: 0,
          fullName,
          phoneNumber,
        }
      } : undefined
    };

    const user = await prisma.user.create({
      data: createUserData,
      include: {
        driver: true,
      } as any,
    }) as unknown as User & { driver: Driver | null };

    console.log('✅ User registered successfully with device info');

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    // Return user data without sensitive information
    const responseData = {
        id: user.id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        province: user.province,
      role: user.role,
        status: user.status,
      ...(user.driver && {
        carId: user.driver.carId,
        carType: user.driver.carType,
        licenseId: user.driver.licenseId,
      }),
    };

    return NextResponse.json({
      user: responseData,
      token,
    });
  } catch (error) {
    console.error('Registration error:', error);
    return NextResponse.json(
      { error: 'Failed to register user' },
      { status: 500 }
    );
  }
} 
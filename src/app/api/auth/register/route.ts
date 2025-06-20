import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { hashPassword } from '@/lib/auth';
import { signJwtAccessToken } from '@/lib/jwt';
import { Role } from '@prisma/client';

export async function POST(request: NextRequest) {
  console.log('Registration endpoint hit');
  try {
    const body = await request.json();
    console.log('Request body:', body);
    
    const {
      fullName,
      phoneNumber,
      password,
      role,
      province,
      // Driver specific fields
      carId,
      carType,
      licenseId,
    } = body;

    if (!fullName || !phoneNumber || !password || !role) {
      console.log('Missing required fields');
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Validate role
    if (!Object.values(Role).includes(role as Role)) {
      console.log('Invalid role:', role);
      return NextResponse.json(
        { error: 'Invalid role. Must be one of: USER, DRIVER, ADMIN' },
        { status: 400 }
      );
    }

    // Check if user already exists
    console.log('Checking for existing user with phone:', phoneNumber);
    const existingUser = await prisma.user.findFirst({
      where: { phoneNumber: phoneNumber },
    });

    if (existingUser) {
      console.log('User already exists');
      return NextResponse.json(
        { error: 'User with this phone number already exists' },
        { status: 400 }
      );
    }

    // Validate driver fields if role is DRIVER
    if (role === 'DRIVER' && (!carId || !carType || !licenseId)) {
      console.log('Missing driver fields');
      return NextResponse.json(
        { error: 'Driver must provide carId, carType, and licenseId' },
        { status: 400 }
      );
    }

    // Hash password
    console.log('Hashing password');
    const hashedPassword = await hashPassword(password);

    // Create user with driver data if role is DRIVER
    console.log('Creating user');
    const user = await prisma.user.create({
      data: {
        fullName,
        phoneNumber,
        password: hashedPassword,
        role: role as Role,
        status: 'ACTIVE',
        province,
        ...(role === 'DRIVER' && {
          driver: {
            create: {
              fullName,
              phoneNumber,
              carId,
              carType,
              licenseId,
              rate: 0,
            },
          },
        }),
      },
      include: {
        driver: true,
      },
    });

    console.log('User created successfully:', user.id);
    const { password: _, ...userWithoutPassword } = user;
    const accessToken = signJwtAccessToken(userWithoutPassword);

    return NextResponse.json({
      user: userWithoutPassword,
      accessToken,
    });
  } catch (error) {
    console.error('Registration error:', error);
    return NextResponse.json(
      { error: 'Internal server error', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 
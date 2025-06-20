import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { comparePassword } from '@/lib/auth';
import { signJwtAccessToken } from '@/lib/jwt';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { phoneNumber, password } = body;

    console.log('Login attempt with phone:', phoneNumber);

    if (!phoneNumber || !password) {
      console.log('Missing phone number or password');
      return NextResponse.json(
        { error: 'Phone number and password are required' },
        { status: 400 }
      );
    }

    const user = await prisma.user.findUnique({
      where: { phoneNumber },
      include: {
        driver: true,
      },
    });

    console.log('User found:', user ? 'Yes' : 'No');

    if (!user) {
      return NextResponse.json(
        { error: 'Invalid phone number or password' },
        { status: 401 }
      );
    }

    const isPasswordValid = await comparePassword(password, user.password);
    console.log('Password valid:', isPasswordValid);

    if (!isPasswordValid) {
      return NextResponse.json(
        { error: 'Invalid phone number or password' },
        { status: 401 }
      );
    }

    const { password: _, ...userWithoutPassword } = user;
    const accessToken = signJwtAccessToken(userWithoutPassword);

    // Create response with user data
    const response = NextResponse.json({
      user: userWithoutPassword,
      accessToken,
    });

    // Set session cookie
    response.cookies.set('session', JSON.stringify(userWithoutPassword), {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24, // 1 day
    });

    return response;
  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { JwtPayload } from 'jsonwebtoken';

// Middleware to verify JWT token
async function verifyToken(req: NextRequest) {
  const token = req.headers.get('authorization')?.split(' ')[1];
  if (!token) return null;

  try {
    const decoded = verify(token, process.env.JWT_SECRET!) as JwtPayload;
    return (decoded as any).userId;
  } catch (error) {
    return null;
  }
}

export async function POST(request: NextRequest) {
  try {
    const userId = await verifyToken(request);
    if (!userId) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { deviceToken, platform, appVersion } = body;

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('📱 Flutter: Registering device token:', {
      userId,
      deviceToken: deviceToken.substring(0, 20) + '...',
      platform,
      appVersion,
    });

    // Update user with device token
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        deviceToken,
        platform: platform || 'unknown',
        appVersion: appVersion || '1.0.0',
        updatedAt: new Date(),
      },
    });

    console.log('✅ Flutter: Device token registered successfully for user:', updatedUser.id);

    return NextResponse.json({
      success: true,
      message: 'Device token registered successfully',
      userId: updatedUser.id,
    });

  } catch (error) {
    console.error('❌ Flutter: Error registering device token:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const userId = await verifyToken(request);
    if (!userId) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // Get user's device token
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        deviceToken: true,
        platform: true,
        appVersion: true,
      },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      deviceToken: user.deviceToken,
      platform: user.platform,
      appVersion: user.appVersion,
    });

  } catch (error) {
    console.error('❌ Flutter: Error getting device token:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
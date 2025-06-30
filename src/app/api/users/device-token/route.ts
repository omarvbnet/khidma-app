import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verifyJwtAccessToken } from '@/lib/jwt';

export async function POST(request: NextRequest) {
  try {
    // Get authorization header
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const decoded = verifyJwtAccessToken(token) as any;
    
    if (!decoded || !decoded.userId) {
      return NextResponse.json(
        { error: 'Invalid token' },
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

    console.log('📱 Registering device token:', {
      userId: decoded.userId,
      deviceToken,
      platform,
      appVersion,
    });

    // Get user details to verify role
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        fullName: true,
        role: true,
        status: true,
        deviceToken: true,
      },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    console.log('👤 User details:', {
      id: user.id,
      fullName: user.fullName,
      role: user.role,
      status: user.status,
      hasExistingToken: !!user.deviceToken,
    });

    // Clear any existing device tokens for this device token (prevent conflicts)
    if (deviceToken) {
      await prisma.user.updateMany({
        where: {
          deviceToken: deviceToken,
          id: { not: decoded.userId }, // Don't update the current user
        },
        data: {
          deviceToken: null,
          platform: null,
          appVersion: null,
        },
      });
      console.log('🧹 Cleared device token from other users');
    }

    // Update user with device token
    const updatedUser = await prisma.user.update({
      where: { id: decoded.userId },
      data: {
        deviceToken,
        platform: platform || 'unknown',
        appVersion: appVersion || '1.0.0',
        updatedAt: new Date(),
      },
    });

    console.log('✅ Device token registered successfully for user:', {
      id: updatedUser.id,
      fullName: updatedUser.fullName,
      role: updatedUser.role,
      deviceToken: deviceToken ? `${deviceToken.substring(0, 20)}...` : 'null',
    });

    return NextResponse.json({
      success: true,
      message: 'Device token registered successfully',
      userId: updatedUser.id,
    });

  } catch (error) {
    console.error('❌ Error registering device token:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    // Get authorization header
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const decoded = verifyJwtAccessToken(token) as any;
    
    if (!decoded || !decoded.userId) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }

    // Get user's device token
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
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
    console.error('❌ Error getting device token:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
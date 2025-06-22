import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { JwtPayload } from 'jsonwebtoken';

// Middleware to verify JWT token with detailed logging
async function verifyToken(req: NextRequest) {
  console.log('\n🔐 VERIFYING JWT TOKEN');
  
  const authHeader = req.headers.get('authorization');
  console.log('Authorization header:', authHeader ? 'Present' : 'Missing');
  
  if (!authHeader) {
    console.log('❌ No authorization header found');
    return null;
  }
  
  if (!authHeader.startsWith('Bearer ')) {
    console.log('❌ Authorization header does not start with "Bearer "');
    return null;
  }
  
  const token = authHeader.substring(7);
  console.log('Token preview:', token.substring(0, 20) + '...');
  
  if (!process.env.JWT_SECRET) {
    console.log('❌ JWT_SECRET environment variable is not set');
    return null;
  }
  
  try {
    const decoded = verify(token, process.env.JWT_SECRET) as JwtPayload;
    console.log('✅ Token verified successfully');
    console.log('Decoded payload:', { userId: decoded.userId, role: decoded.role });
    return (decoded as any).userId;
  } catch (error) {
    console.log('❌ Token verification failed:', error);
    return null;
  }
}

export async function POST(request: NextRequest) {
  try {
    console.log('\n📱 FLUTTER DEVICE TOKEN REGISTRATION');
    console.log('Request headers:', Object.fromEntries(request.headers.entries()));
    
    const userId = await verifyToken(request);
    if (!userId) {
      console.log('❌ Token verification failed - returning 401');
      return NextResponse.json(
        { 
          error: 'Unauthorized',
          details: 'Invalid or missing authentication token'
        },
        { status: 401 }
      );
    }

    const body = await request.json();
    console.log('Request body:', body);
    
    const { deviceToken, platform, appVersion } = body;

    if (!deviceToken) {
      console.log('❌ Device token is missing from request body');
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('📱 Registering device token:', {
      userId,
      deviceToken: deviceToken.substring(0, 20) + '...',
      platform,
      appVersion,
    });

    // Check if user exists first
    const existingUser = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, fullName: true, role: true, deviceToken: true }
    });

    if (!existingUser) {
      console.log('❌ User not found:', userId);
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    console.log('Found user:', existingUser.fullName, 'Role:', existingUser.role);
    console.log('Current device token:', existingUser.deviceToken ? 'Present' : 'Missing');

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

    console.log('✅ Device token registered successfully for user:', updatedUser.id);

    return NextResponse.json({
      success: true,
      message: 'Device token registered successfully',
      userId: updatedUser.id,
      user: {
        id: updatedUser.id,
        fullName: updatedUser.fullName,
        role: updatedUser.role,
        hasToken: !!updatedUser.deviceToken
      }
    });

  } catch (error) {
    console.error('❌ Flutter: Error registering device token:', error);
    return NextResponse.json(
      { 
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    console.log('\n📱 FLUTTER GET DEVICE TOKEN');
    
    const userId = await verifyToken(request);
    if (!userId) {
      console.log('❌ Token verification failed - returning 401');
      return NextResponse.json(
        { 
          error: 'Unauthorized',
          details: 'Invalid or missing authentication token'
        },
        { status: 401 }
      );
    }

    // Get user's device token
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        deviceToken: true,
        platform: true,
        appVersion: true,
      },
    });

    if (!user) {
      console.log('❌ User not found:', userId);
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    console.log('✅ Retrieved device token for user:', user.fullName);

    return NextResponse.json({
      success: true,
      deviceToken: user.deviceToken,
      platform: user.platform,
      appVersion: user.appVersion,
      hasToken: !!user.deviceToken
    });

  } catch (error) {
    console.error('❌ Flutter: Error getting device token:', error);
    return NextResponse.json(
      { 
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
} 
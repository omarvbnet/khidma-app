import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING DEVICE TOKEN REGISTRATION ===');
    
    const body = await req.json();
    const { userId, deviceToken, platform } = body;

    if (!userId || !deviceToken) {
      return NextResponse.json({
        success: false,
        error: 'userId and deviceToken are required'
      }, { status: 400 });
    }

    console.log('Testing token registration for user:', userId);
    console.log('Token preview:', deviceToken.substring(0, 20) + '...');
    console.log('Platform:', platform);

    // Check if user exists
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, fullName: true, role: true, deviceToken: true }
    });

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'User not found'
      }, { status: 404 });
    }

    console.log('Found user:', user.fullName, 'Role:', user.role);
    console.log('Current device token:', user.deviceToken ? 'Present' : 'Missing');

    // Update device token
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        deviceToken,
        platform: platform || 'test',
        updatedAt: new Date()
      },
      select: { id: true, fullName: true, deviceToken: true, platform: true }
    });

    console.log('✅ Device token updated successfully');
    console.log('New token preview:', updatedUser.deviceToken?.substring(0, 20) + '...');

    return NextResponse.json({
      success: true,
      message: 'Device token registration test successful',
      user: {
        id: updatedUser.id,
        name: updatedUser.fullName,
        hasToken: !!updatedUser.deviceToken,
        platform: updatedUser.platform
      }
    });

  } catch (error) {
    console.error('❌ Token registration test failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== CHECKING DEVICE TOKEN STATUS ===');
    
    // Get all users with device tokens
    const usersWithTokens = await prisma.user.findMany({
      where: {
        deviceToken: { not: null }
      },
      select: {
        id: true,
        fullName: true,
        role: true,
        deviceToken: true,
        platform: true,
        updatedAt: true
      },
      orderBy: { updatedAt: 'desc' }
    });

    console.log(`Found ${usersWithTokens.length} users with device tokens`);

    return NextResponse.json({
      success: true,
      totalUsersWithTokens: usersWithTokens.length,
      users: usersWithTokens.map(user => ({
        id: user.id,
        name: user.fullName,
        role: user.role,
        hasToken: !!user.deviceToken,
        tokenPreview: user.deviceToken ? user.deviceToken.substring(0, 20) + '...' : null,
        platform: user.platform,
        lastUpdated: user.updatedAt
      }))
    });

  } catch (error) {
    console.error('❌ Token status check failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Status check failed'
    }, { status: 500 });
  }
} 
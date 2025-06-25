import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== LISTING ALL DEVICE TOKENS ===');

    // Get all users with device tokens
    const usersWithTokens = await prisma.user.findMany({
      where: {
        deviceToken: {
          not: null
        }
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true,
        province: true,
        status: true,
        deviceToken: true,
        createdAt: true,
        updatedAt: true
      },
      orderBy: {
        updatedAt: 'desc'
      }
    });

    console.log(`Found ${usersWithTokens.length} users with device tokens`);

    return NextResponse.json({
      message: 'Device tokens listed successfully',
      totalUsers: usersWithTokens.length,
      users: usersWithTokens.map(user => ({
        id: user.id,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        role: user.role,
        province: user.province,
        status: user.status,
        deviceToken: user.deviceToken ? user.deviceToken.substring(0, 20) + '...' : null,
        fullDeviceToken: user.deviceToken,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }))
    });

  } catch (error) {
    console.error('Error listing device tokens:', error);
    return NextResponse.json(
      { error: 'Failed to list device tokens' },
      { status: 500 }
    );
  }
} 
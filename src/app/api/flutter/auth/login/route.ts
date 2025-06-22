import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sign } from 'jsonwebtoken';
import bcrypt from 'bcrypt';

export async function POST(req: NextRequest) {
  try {
    const { phoneNumber, password, deviceToken, platform, appVersion } = await req.json();

    console.log('📱 Flutter login attempt:', {
      phoneNumber,
      deviceToken: deviceToken ? `${deviceToken.substring(0, 20)}...` : 'not provided',
      platform,
      appVersion,
    });

    const user = await prisma.user.findUnique({
      where: { phoneNumber },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }

    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }

    // Update user with device information if provided
    if (deviceToken || platform || appVersion) {
      console.log('📱 Updating device information for user:', user.id);
      
      await prisma.user.update({
        where: { id: user.id },
        data: {
          deviceToken: deviceToken || user.deviceToken,
          platform: platform || user.platform,
          appVersion: appVersion || user.appVersion,
          updatedAt: new Date(),
        },
      });

      console.log('✅ Device information updated successfully');
    }

    const token = sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    return NextResponse.json({
      token,
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        province: user.province,
        role: user.role,
        status: user.status,
      },
    });
  } catch (error) {
    console.error('Error in login route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
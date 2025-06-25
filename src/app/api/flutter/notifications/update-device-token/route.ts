import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== UPDATING DEVICE TOKEN ===');

    const { driverId, newDeviceToken } = await req.json();

    if (!driverId || !newDeviceToken) {
      return NextResponse.json(
        { error: 'Driver ID and new device token are required' },
        { status: 400 }
      );
    }

    console.log('Driver ID:', driverId);
    console.log('New Device Token:', newDeviceToken.substring(0, 20) + '...');

    // Update the driver's device token
    const updatedDriver = await prisma.user.update({
      where: {
        id: driverId,
        role: 'DRIVER'
      },
      data: {
        deviceToken: newDeviceToken,
        updatedAt: new Date()
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true,
        province: true,
        status: true,
        deviceToken: true,
        updatedAt: true
      }
    });

    console.log('✅ Device token updated successfully for driver:', updatedDriver.fullName);

    return NextResponse.json({
      message: 'Device token updated successfully',
      driver: {
        id: updatedDriver.id,
        fullName: updatedDriver.fullName,
        phoneNumber: updatedDriver.phoneNumber,
        role: updatedDriver.role,
        province: updatedDriver.province,
        status: updatedDriver.status,
        deviceToken: updatedDriver.deviceToken ? updatedDriver.deviceToken.substring(0, 20) + '...' : null,
        updatedAt: updatedDriver.updatedAt
      }
    });

  } catch (error) {
    console.error('Error updating device token:', error);
    return NextResponse.json(
      { error: 'Failed to update device token' },
      { status: 500 }
    );
  }
} 
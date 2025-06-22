import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { pickupLocation, dropoffLocation, price, distance } = body;

    // Create a mock trip for testing
    const mockTrip = {
      id: `test_${Date.now()}`,
      pickupLocation: pickupLocation || 'Test Pickup Location',
      dropoffLocation: dropoffLocation || 'Test Dropoff Location',
      price: price || 25.0,
      distance: distance || 5.0,
      userFullName: 'Test User',
      userPhone: '+1234567890',
    };

    console.log('\n=== SENDING TEST NOTIFICATION ===');
    console.log('Mock trip:', mockTrip);

    // Send notifications to available drivers
    await notifyAvailableDriversAboutNewTrip(mockTrip);

    return NextResponse.json({
      success: true,
      message: 'Test notification sent to available drivers',
      mockTrip
    });

  } catch (error) {
    console.error('Error sending test notification:', error);
    return NextResponse.json(
      { error: 'Failed to send test notification' },
      { status: 500 }
    );
  }
} 
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== DEBUGGING NOTIFICATION PAYLOAD ===');
    
    // Get a test user
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
      },
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    // Get the driver to see their device token
    const driver = await prisma.user.findFirst({
      where: { 
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true,
        province: true
      }
    });

    if (!driver) {
      return NextResponse.json({ error: 'No active driver found' }, { status: 404 });
    }

    console.log('Driver details:', {
      id: driver.id,
      name: driver.fullName,
      hasToken: !!driver.deviceToken,
      tokenPreview: driver.deviceToken ? `${driver.deviceToken.substring(0, 20)}...` : 'None',
      province: driver.province
    });

    // Create a test trip
    const createData = {
      pickupLocation: 'Debug Test Pickup',
      dropoffLocation: 'Debug Test Dropoff',
      pickupLat: 33.3152,
      pickupLng: 44.3661,
      dropoffLat: 33.3152,
      dropoffLng: 44.3661,
      price: 5000,
      distance: 5.0,
      status: TaxiRequest_status.USER_WAITING,
      tripType: 'ECO',
      driverDeduction: 0,
      userPhone: testUser.phoneNumber,
      userFullName: testUser.fullName,
      userProvince: testUser.province,
      userId: testUser.id
    } as const;

    console.log('Creating test trip with data:', createData);

    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('✅ Test trip created:', taxiRequest.id);

    // Call the notification function and capture the exact payload
    console.log('\n=== CALLING NOTIFICATION FUNCTION ===');
    
    // Mock the sendMulticastNotification function to capture the payload
    const originalSendMulticastNotification = require('@/lib/firebase-admin').sendMulticastNotification;
    
    let capturedPayload: any = null;
    
    // Temporarily replace the function to capture the payload
    require('@/lib/firebase-admin').sendMulticastNotification = async (payload: any) => {
      capturedPayload = payload;
      console.log('📨 CAPTURED NOTIFICATION PAYLOAD:');
      console.log('Title:', payload.title);
      console.log('Body:', payload.body);
      console.log('Data:', payload.data);
      console.log('Tokens count:', payload.tokens?.length || 0);
      
      // Call the original function
      return await originalSendMulticastNotification(payload);
    };

    try {
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      console.log('✅ Notification function completed');
    } catch (error) {
      console.error('❌ Notification function failed:', error);
    }

    // Restore the original function
    require('@/lib/firebase-admin').sendMulticastNotification = originalSendMulticastNotification;

    // Clean up the test trip
    await prisma.taxiRequest.delete({
      where: { id: taxiRequest.id }
    });

    console.log('✅ Test trip cleaned up');

    return NextResponse.json({
      success: true,
      message: 'Notification payload debug completed',
      driver: {
        id: driver.id,
        name: driver.fullName,
        hasToken: !!driver.deviceToken,
        tokenPreview: driver.deviceToken ? `${driver.deviceToken.substring(0, 20)}...` : 'None',
        province: driver.province
      },
      testTrip: {
        id: taxiRequest.id,
        pickupLocation: taxiRequest.pickupLocation,
        dropoffLocation: taxiRequest.dropoffLocation,
        price: taxiRequest.price,
        userProvince: taxiRequest.userProvince
      },
      capturedPayload: capturedPayload ? {
        title: capturedPayload.title,
        body: capturedPayload.body,
        data: capturedPayload.data,
        tokensCount: capturedPayload.tokens?.length || 0
      } : null,
      expectedBackgroundHandlerDetection: capturedPayload ? {
        hasNotificationObject: true,
        notificationTitle: capturedPayload.title,
        notificationBody: capturedPayload.body,
        dataType: capturedPayload.data?.type,
        shouldDetectAsTrip: capturedPayload.title?.toLowerCase().includes('trip') || 
                           capturedPayload.body?.toLowerCase().includes('trip') ||
                           capturedPayload.data?.type === 'NEW_TRIP_AVAILABLE'
      } : null
    });

  } catch (error) {
    console.error('❌ Error in notification payload debug:', error);
    return NextResponse.json({
      success: false,
      error: 'Debug failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 
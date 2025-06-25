import { NextRequest, NextResponse } from 'next/server';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING FIREBASE NOTIFICATION ===');

    const { deviceToken } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');

    // Simple test notification
    const result = await sendMulticastNotification({
      tokens: [deviceToken],
      title: 'Firebase Test',
      body: 'This is a Firebase test notification',
      data: {
        type: 'FIREBASE_TEST',
        timestamp: new Date().toISOString(),
      },
    });

    console.log('Firebase notification result:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
      notificationResponses: result?.notificationResponse?.responses,
      dataResponses: result?.dataResponse?.responses
    });

    return NextResponse.json({
      message: 'Firebase test completed',
      success: (result?.notificationResponse?.successCount || 0) + (result?.dataResponse?.successCount || 0) > 0,
      notificationSuccessCount: result?.notificationResponse?.successCount || 0,
      notificationFailureCount: result?.notificationResponse?.failureCount || 0,
      dataSuccessCount: result?.dataResponse?.successCount || 0,
      dataFailureCount: result?.dataResponse?.failureCount || 0,
      notificationResponses: result?.notificationResponse?.responses || [],
      dataResponses: result?.dataResponse?.responses || []
    });

  } catch (error) {
    console.error('Firebase test failed:', error);
    return NextResponse.json(
      { 
        error: 'Firebase test failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
} 
import { NextRequest, NextResponse } from 'next/server';
import { sendPushNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING BACKGROUND HANDLER TRIGGER ===');

    const { deviceToken } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');

    // Send a simple notification that should ALWAYS trigger the background handler
    const result = await sendPushNotification({
      token: deviceToken,
      title: 'Background Handler Test',
      body: 'This should trigger the background handler. Check Flutter logs.',
      data: {
        type: 'BACKGROUND_HANDLER_TEST',
        timestamp: new Date().toISOString(),
        testId: 'simple-trigger-test',
        message: 'If you see this in Flutter logs, the background handler is working',
      },
    });

    console.log('✅ Background handler trigger test sent');
    console.log('Result:', result);

    return NextResponse.json({
      success: true,
      message: 'Background handler trigger test completed',
      result,
      instructions: [
        '1. Put the Flutter app in background or closed state',
        '2. Send this notification',
        '3. Check Flutter logs for "BACKGROUND MESSAGE RECEIVED IN MAIN"',
        '4. If you see the log, the background handler is working',
        '5. If you don\'t see the log, there\'s an iOS/Firebase configuration issue'
      ]
    });

  } catch (error) {
    console.error('❌ Error in background handler trigger test:', error);
    return NextResponse.json(
      { error: 'Failed to test background handler trigger' },
      { status: 500 }
    );
  }
} 
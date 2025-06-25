import { NextResponse } from 'next/server';
import twilio from 'twilio';
import { otpStore, logOTPStore, cleanupExpiredOTPs } from '@/lib/otp-store';

// Initialize Twilio client
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Helper function to format phone number for Twilio
function formatPhoneForTwilio(phoneNumber: string): string {
  // Remove any non-numeric characters except +
  let cleaned = phoneNumber.replaceAll(/[^\d+]/g, '');
  
  // If it doesn't start with +, add it
  if (!cleaned.startsWith('+')) {
    cleaned = '+' + cleaned;
  }
  
  console.log('Original phone number:', phoneNumber);
  console.log('Formatted for Twilio:', cleaned);
  
  return cleaned;
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { phoneNumber } = body;

    console.log('=== OTP SEND REQUEST ===');
    console.log('Phone number received:', phoneNumber);
    
    // Clean up expired OTPs first
    cleanupExpiredOTPs();
    logOTPStore();

    if (!phoneNumber) {
      return NextResponse.json(
        { error: 'Phone number is required' },
        { status: 400 }
      );
    }

    // Generate a 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP with 5-minute expiration
    otpStore.set(phoneNumber, {
      code: otp,
      expires: Date.now() + 5 * 60 * 1000, // 5 minutes
    });

    console.log('OTP generated and stored:', otp);
    console.log('OTP store after storing:');
    logOTPStore();

    // In development, just return the OTP
    if (process.env.NODE_ENV === 'development') {
      console.log(`OTP for ${phoneNumber}: ${otp}`);
      return NextResponse.json({ 
        success: true,
        message: 'OTP sent successfully',
        otp // Only include OTP in development
      });
    }

    // In production, send OTP via Twilio
    try {
      const formattedPhone = formatPhoneForTwilio(phoneNumber);
      
      await twilioClient.messages.create({
        body: `Your Waddiny verification code is: ${otp}`,
        to: formattedPhone,
        from: process.env.TWILIO_PHONE_NUMBER,
      });

      return NextResponse.json({ 
        success: true,
        message: 'OTP sent successfully'
      });
    } catch (twilioError) {
      console.error('Twilio error:', twilioError);
      return NextResponse.json(
        { error: 'Failed to send OTP' },
        { status: 500 }
      );
    }
  } catch (error) {
    console.error('OTP send error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
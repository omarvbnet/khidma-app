import { NextResponse } from 'next/server';
import { otpStore, logOTPStore, cleanupExpiredOTPs } from '@/lib/otp-store';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { phoneNumber, otp } = body;

    console.log('=== OTP VERIFY REQUEST ===');
    console.log('Phone number received:', phoneNumber);
    console.log('OTP received:', otp);
    
    // Clean up expired OTPs first
    cleanupExpiredOTPs();
    console.log('OTP store before verification:');
    logOTPStore();

    if (!phoneNumber || !otp) {
      return NextResponse.json(
        { error: 'Phone number and OTP are required' },
        { status: 400 }
      );
    }

    // Get stored OTP
    const storedOTP = otpStore.get(phoneNumber);
    console.log('Stored OTP for this number:', storedOTP);

    if (!storedOTP) {
      console.log('No OTP found for phone number:', phoneNumber);
      console.log('Available phone numbers:', Array.from(otpStore.keys()));
      return NextResponse.json(
        { error: 'No OTP found for this phone number' },
        { status: 400 }
      );
    }

    // Check if OTP has expired
    if (Date.now() > storedOTP.expires) {
      console.log('OTP has expired');
      otpStore.delete(phoneNumber);
      return NextResponse.json(
        { error: 'OTP has expired' },
        { status: 400 }
      );
    }

    // Verify OTP
    console.log('Comparing OTPs - Received:', otp, 'Stored:', storedOTP.code);
    if (storedOTP.code !== otp) {
      console.log('OTP mismatch');
      return NextResponse.json(
        { error: 'Invalid OTP' },
        { status: 400 }
      );
    }

    // Clear the OTP after successful verification
    otpStore.delete(phoneNumber);
    console.log('OTP verified successfully and cleared');
    console.log('OTP store after verification:');
    logOTPStore();

    return NextResponse.json({
      success: true,
      message: 'OTP verified successfully'
    });
  } catch (error) {
    console.error('OTP verification error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
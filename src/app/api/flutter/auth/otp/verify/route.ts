import { NextResponse } from 'next/server';
import { otpStore, logOTPStore, cleanupExpiredOTPs } from '@/lib/otp-store';
import { prisma } from '@/lib/prisma';
import { sign } from 'jsonwebtoken';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { phoneNumber, otp, deviceToken, platform, appVersion, isRegistration = false } = body;

    console.log('=== OTP VERIFY REQUEST ===');
    console.log('Phone number received:', phoneNumber);
    console.log('OTP received:', otp);
    console.log('Is registration:', isRegistration);
    console.log('Device info:', {
      deviceToken: deviceToken ? `${deviceToken.substring(0, 20)}...` : 'not provided',
      platform,
      appVersion,
    });
    
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

    // Find user
    const user = await prisma.user.findUnique({
      where: { phoneNumber },
    });

    if (isRegistration) {
      // For registration, we don't expect the user to exist yet
      if (user) {
        return NextResponse.json(
          { error: 'User already exists with this phone number' },
          { status: 400 }
        );
      }
      
      // Return success for registration OTP verification
      return NextResponse.json({
        success: true,
        message: 'OTP verified successfully for registration',
        verified: true
      });
    } else {
      // For login, user must exist
      if (!user) {
        return NextResponse.json(
          { error: 'User not found. Please register first.' },
          { status: 404 }
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

      // Generate JWT token
      const token = sign(
        { userId: user.id, role: user.role },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '7d' }
      );

      console.log('✅ Login successful for user:', user.id);

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
    }
  } catch (error) {
    console.error('OTP verification error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
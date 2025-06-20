import { NextRequest, NextResponse } from 'next/server';
import twilio from 'twilio';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Initialize Twilio client
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// In-memory store for OTP codes (in production, use Redis or similar)
const otpStore = new Map<string, { code: string; expiresAt: number }>();

// Generate a 6-digit OTP
function generateOTP(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send OTP via Twilio
async function sendOTP(phoneNumber: string, otp: string): Promise<void> {
  try {
    await twilioClient.messages.create({
      body: `Your Khidma verification code is: ${otp}`,
      to: phoneNumber,
      from: process.env.TWILIO_PHONE_NUMBER,
    });
  } catch (error) {
    console.error('Error sending OTP:', error);
    throw new Error('Failed to send OTP');
  }
}

// POST /api/auth/otp/send
export async function POST(request: NextRequest) {
  try {
    const { phoneNumber } = await request.json();

    if (!phoneNumber) {
      return NextResponse.json(
        { error: 'Phone number is required' },
        { status: 400 }
      );
    }

    // Check if phone number is already registered
    const existingUser = await prisma.user.findFirst({
      where: {
        phoneNumber: {
          equals: phoneNumber
        }
      }
    });

    if (existingUser) {
      return NextResponse.json(
        { error: 'Phone number is already registered' },
        { status: 400 }
      );
    }

    // Generate and store OTP
    const otp = generateOTP();
    const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes
    otpStore.set(phoneNumber, { code: otp, expiresAt });

    // Send OTP
    await sendOTP(phoneNumber, otp);

    return NextResponse.json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Error in send OTP:', error);
    return NextResponse.json(
      { error: 'Failed to send OTP' },
      { status: 500 }
    );
  }
}

// PUT /api/auth/otp/verify
export async function PUT(request: NextRequest) {
  try {
    const { phoneNumber, otp } = await request.json();

    if (!phoneNumber || !otp) {
      return NextResponse.json(
        { error: 'Phone number and OTP are required' },
        { status: 400 }
      );
    }

    const storedOTP = otpStore.get(phoneNumber);

    if (!storedOTP) {
      return NextResponse.json(
        { error: 'OTP not found or expired' },
        { status: 400 }
      );
    }

    if (Date.now() > storedOTP.expiresAt) {
      otpStore.delete(phoneNumber);
      return NextResponse.json(
        { error: 'OTP has expired' },
        { status: 400 }
      );
    }

    if (storedOTP.code !== otp) {
      return NextResponse.json(
        { error: 'Invalid OTP' },
        { status: 400 }
      );
    }

    // Clear the OTP after successful verification
    otpStore.delete(phoneNumber);

    return NextResponse.json({ message: 'OTP verified successfully' });
  } catch (error) {
    console.error('Error in verify OTP:', error);
    return NextResponse.json(
      { error: 'Failed to verify OTP' },
      { status: 500 }
    );
  }
} 
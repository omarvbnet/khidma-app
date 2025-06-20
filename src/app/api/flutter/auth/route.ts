import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sign } from 'jsonwebtoken';
import bcrypt from 'bcrypt';

export async function POST(req: NextRequest) {
  try {
    const { phoneNumber, verificationCode, fullName, province, role } = await req.json();

    // Here you would verify the phone number and code with Firebase
    // For now, we'll just create/update the user

    let user = await prisma.user.findUnique({
      where: { phoneNumber },
    });

    if (!user) {
      const hashedPassword = await bcrypt.hash(verificationCode, 10);
      user = await prisma.user.create({
        data: {
          phoneNumber,
          password: hashedPassword,
          fullName: fullName || `User ${phoneNumber}`,
          province: province || 'Unknown',
          role: role || 'USER',
        },
      });
    }

    // Generate JWT token
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
    console.error('Error in auth route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
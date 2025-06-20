import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sign } from 'jsonwebtoken';
import bcrypt from 'bcrypt';

export async function POST(req: NextRequest) {
  try {
    const { phoneNumber, password } = await req.json();

    const user = await prisma.user.findUnique({
      where: { phoneNumber },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }

    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }

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
    console.error('Error in login route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
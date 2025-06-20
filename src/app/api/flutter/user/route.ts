import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

// Middleware to verify JWT token
async function verifyToken(req: NextRequest) {
  const authHeader = req.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };
    return decoded.userId;
  } catch (error) {
    return null;
  }
}

// Get user profile
export async function GET(req: NextRequest) {
  try {
    const token = req.headers.get('Authorization')?.split(' ')[1];

    if (!token) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
  }

    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      id: user.id,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
      province: user.province,
      role: user.role,
      status: user.status,
    });
  } catch (error) {
    console.error('Error in user profile route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// Update user profile
export async function PUT(req: NextRequest) {
  try {
    const token = req.headers.get('Authorization')?.split(' ')[1];

    if (!token) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
  }

    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };

    const { fullName, province } = await req.json();

    const user = await prisma.user.update({
      where: { id: decoded.userId },
      data: {
        fullName: fullName || undefined,
        province: province || undefined,
      },
    });

    return NextResponse.json({
      id: user.id,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
      province: user.province,
      role: user.role,
      status: user.status,
    });
  } catch (error) {
    console.error('Error in user profile update route:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
} 
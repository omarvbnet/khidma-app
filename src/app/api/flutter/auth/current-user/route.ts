import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import jwt from 'jsonwebtoken';

export async function GET(req: NextRequest) {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'No token provided' },
        { status: 401 }
      );
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return NextResponse.json(
        { error: 'No token provided' },
        { status: 401 }
      );
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };
    if (!decoded.userId) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }

    console.log('Fetching user with ID:', decoded.userId);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
        role: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      console.log('User not found for ID:', decoded.userId);
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    console.log('User found:', user.id);
    return NextResponse.json({
      user: {
        id: user.id,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        role: user.role,
        status: user.status,
        province: user.province,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      }
    });
  } catch (error) {
    console.error('Error fetching current user:', error);
    if (error instanceof jwt.JsonWebTokenError) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { error: 'Internal server error', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 
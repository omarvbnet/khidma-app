import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'No token provided' }, { status: 401 });
    }

    const token = authHeader.split(' ')[1];
    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };

    console.log('🔍 DEBUG: Checking budget for user ID:', decoded.userId);

    // Get user with all fields
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        driver: true,
      }
    });

    if (!user) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    console.log('🔍 DEBUG: Full user data from DB:', JSON.stringify(user, null, 2));

    return NextResponse.json({
      message: 'Budget debug info',
      user: {
        id: user.id,
        fullName: user.fullName,
        role: user.role,
        budget: user.budget,
        budgetType: typeof user.budget,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
      driver: user.driver ? {
        id: user.driver.id,
        fullName: user.driver.fullName,
      } : null,
      databaseInfo: {
        budgetField: user.budget,
        budgetIsNull: user.budget === null,
        budgetIsZero: user.budget === 0,
        budgetIsNumber: typeof user.budget === 'number',
      }
    });
  } catch (error) {
    console.error('❌ DEBUG: Error in budget debug endpoint:', error);
    return NextResponse.json(
      { error: 'Debug endpoint error', details: error },
      { status: 500 }
    );
  }
} 
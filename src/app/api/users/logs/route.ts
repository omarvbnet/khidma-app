import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');
    const userId = searchParams.get('userId');
    const phone = searchParams.get('phone');

    const where: any = {
      type: {
        in: ['STATUS_CHANGE', 'BUDGET_UPDATE']
      }
    };

    if (startDate && endDate) {
      where.createdAt = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      };
    }

    if (userId) {
      where.userId = userId;
    }

    if (phone) {
      where.user = {
        phoneNumber: {
          contains: phone,
        },
      };
    }

    const logs = await prisma.userLog.findMany({
      where,
      include: {
        user: {
          select: {
            fullName: true,
            phoneNumber: true,
          },
        },
        changedBy: {
          select: {
            fullName: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return NextResponse.json(logs);
  } catch (error) {
    console.error('Error fetching user logs:', error);
    return NextResponse.json(
      { error: 'Failed to fetch user logs' },
      { status: 500 }
    );
  }
} 
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
        phone: {
          contains: phone,
        },
      };
    }

    const logs = await prisma.userLog.findMany({
      where,
      include: {
        user: {
          select: {
            name: true,
            email: true,
            phone: true,
          },
        },
        changedBy: {
          select: {
            name: true,
            email: true,
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
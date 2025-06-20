import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  try {
    const topUsers = await prisma.user.findMany({
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        _count: {
          select: {
            taxiRequests: true,
          },
        },
      },
      orderBy: {
        taxiRequests: {
          _count: 'desc',
        },
      },
      take: 10,
    });

    const formattedUsers = topUsers.map(user => ({
      id: user.id,
      name: user.fullName,
      phone: user.phoneNumber,
      requestCount: user._count.taxiRequests,
    }));

    return NextResponse.json(formattedUsers);
  } catch (error) {
    console.error('Error fetching top users:', error);
    return NextResponse.json(
      { error: 'Failed to fetch top users' },
      { status: 500 }
    );
  }
} 
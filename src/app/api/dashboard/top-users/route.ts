import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  try {
    const topUsers = await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
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
      name: user.name,
      email: user.email,
      phone: user.phone,
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
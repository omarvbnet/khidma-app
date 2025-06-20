import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { Role, UserStatus } from '@prisma/client';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const from = searchParams.get('from');
    const to = searchParams.get('to');
    const phone = searchParams.get('phone');

    const where: any = {
      role: 'DRIVER' as Role,
      status: 'PENDING' as UserStatus,
      ...(phone ? {
        phoneNumber: {
          contains: phone,
          mode: 'insensitive',
        },
      } : {}),
      ...(from && to ? {
        createdAt: {
          gte: new Date(from),
          lte: new Date(to),
        },
      } : {}),
    };

    const requests = await prisma.user.findMany({
      where,
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        status: true,
        role: true,
        province: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return NextResponse.json(requests);
  } catch (error) {
    console.error('Error fetching driver requests:', error);
    return NextResponse.json(
      { error: 'Failed to fetch driver requests' },
      { status: 500 }
    );
  }
} 
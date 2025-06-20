import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const from = searchParams.get('from');
    const to = searchParams.get('to');
    const phone = searchParams.get('phone');

    const where: any = {};

    if (from && to) {
      where.createdAt = {
        gte: new Date(from),
        lte: new Date(to),
      };
    }

    if (phone) {
      where.phoneNumber = {
        contains: phone,
      };
    }

    const users = await prisma.user.findMany({
      where,
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true,
        status: true,
        province: true,
        budget: true,
        _count: {
          select: {
            taxiRequests: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    const formattedUsers = users.map(user => ({
      ...user,
      totalRequests: user._count.taxiRequests,
      _count: undefined,
    }));

    return NextResponse.json(formattedUsers);
  } catch (error) {
    console.error('Error fetching users:', error);
    return NextResponse.json(
      { error: 'Failed to fetch users' },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  const { fullName, phoneNumber, password, role, status, province, budget } = await req.json();
  if (!fullName || !phoneNumber || !password) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }
  const user = await prisma.user.create({
    data: {
      fullName,
      phoneNumber,
      password, // Note: In production, hash the password before saving
      role: role || 'USER',
      status: status || 'ACTIVE',
      province: province || '',
      budget: budget || 0,
    },
  });
  return NextResponse.json(user);
} 
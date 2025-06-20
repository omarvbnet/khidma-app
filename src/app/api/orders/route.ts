import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { OrderStatus } from '@prisma/client';

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const query = searchParams.get('query') || '';
  const status = searchParams.get('status') || '';
  const startDate = searchParams.get('startDate') || '';
  const endDate = searchParams.get('endDate') || '';

  try {
    const where: any = {};

    if (query) {
      where.OR = [
        { user: { name: { contains: query, mode: 'insensitive' } } },
        { user: { email: { contains: query, mode: 'insensitive' } } },
        { id: { contains: query, mode: 'insensitive' } },
      ];
    }

    if (status) {
      where.status = status;
    }

    if (startDate && endDate) {
      where.createdAt = {
        gte: new Date(startDate),
        lte: new Date(endDate + 'T23:59:59.999Z'),
      };
    } else if (startDate) {
      where.createdAt = {
        gte: new Date(startDate),
      };
    } else if (endDate) {
      where.createdAt = {
        lte: new Date(endDate + 'T23:59:59.999Z'),
      };
    }

    const orders = await prisma.order.findMany({
      where,
      include: {
        user: {
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

    return NextResponse.json(orders);
  } catch (error) {
    console.error('Error fetching orders:', error);
    return NextResponse.json(
      { error: 'Failed to fetch orders' },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  const { userId, status, total } = await req.json();
  if (!userId || !total) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }
  const order = await prisma.order.create({
    data: {
      userId,
      status: status || 'PENDING',
      total,
    },
  });
  return NextResponse.json(order);
} 
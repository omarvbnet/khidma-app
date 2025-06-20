import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';

export async function GET() {
  try {
    const count = await prisma.taxiRequest.count({
      where: {
        status: TaxiRequest_status.USER_WAITING,
      },
    });

    return NextResponse.json({ count });
  } catch (error) {
    console.error('Error fetching pending taxi requests count:', error);
    return NextResponse.json({ error: 'Failed to fetch count' }, { status: 500 });
  }
} 
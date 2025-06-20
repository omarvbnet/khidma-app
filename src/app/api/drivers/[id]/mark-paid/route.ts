import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const driver = await prisma.user.findUnique({ where: { id: params.id } });
    if (!driver) {
      return NextResponse.json({ error: 'Driver not found' }, { status: 404 });
    }

    await prisma.taxiRequest.updateMany({
      where: {
        driverId: params.id,
        paymentStatus: 'UNPAID',
      },
      data: {
        paymentStatus: 'PAID',
      },
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error marking trips as paid:', error);
    return NextResponse.json(
      { error: 'Failed to mark trips as paid' },
      { status: 500 }
    );
  }
} 
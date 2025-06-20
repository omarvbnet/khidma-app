import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const taxiRequest = await prisma.taxiRequest.findUnique({
    where: { id },
    include: {
      user: {
        select: {
          fullName: true,
          phoneNumber: true,
          province: true,
        },
      },
    },
  });

  if (!taxiRequest) {
    return NextResponse.json({ error: 'Taxi request not found' }, { status: 404 });
  }

  return NextResponse.json(taxiRequest);
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { status } = await req.json();

    if (!status) {
      return NextResponse.json(
        { error: 'Status is required' },
        { status: 400 }
      );
    }

    const taxiRequest = await prisma.taxiRequest.findUnique({
      where: { id },
    });

    if (!taxiRequest) {
      return NextResponse.json(
        { error: 'Taxi request not found' },
        { status: 404 }
      );
    }

    const updatedRequest = await prisma.taxiRequest.update({
      where: { id },
      data: { status },
      include: {
        user: {
          select: {
            fullName: true,
            phoneNumber: true,
            province: true,
          },
        },
      },
    });

    return NextResponse.json(updatedRequest);
  } catch (error) {
    console.error('Error updating taxi request status:', error);
    return NextResponse.json(
      { error: 'Failed to update taxi request status' },
      { status: 500 }
    );
  }
} 
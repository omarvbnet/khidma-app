import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function PATCH(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const { status } = await request.json();

    const driver = await prisma.user.update({
      where: {
        id: params.id,
        role: 'DRIVER',
      },
      data: {
        status,
      },
    });

    return NextResponse.json(driver);
  } catch (error) {
    console.error('Error updating driver status:', error);
    return NextResponse.json(
      { error: 'Failed to update driver status' },
      { status: 500 }
    );
  }
} 
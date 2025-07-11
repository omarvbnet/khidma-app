import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { rate } = await request.json();

    const driver = await prisma.driver.update({
      where: {
        userId: id,
      },
      data: {
        rate,
      },
    });

    return NextResponse.json(driver);
  } catch (error) {
    console.error('Error updating driver rate:', error);
    return NextResponse.json(
      { error: 'Failed to update driver rate' },
      { status: 500 }
    );
  }
} 
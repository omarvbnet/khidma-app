import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const driverRequest = await prisma.user.findUnique({
      where: { id: params.id },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        status: true,
        role: true,
        province: true,
        createdAt: true,
      },
    });

    if (!driverRequest) {
      return NextResponse.json(
        { error: 'Driver request not found' },
        { status: 404 }
      );
    }

    return NextResponse.json(driverRequest);
  } catch (error) {
    console.error('Error fetching driver request:', error);
    return NextResponse.json(
      { error: 'Failed to fetch driver request' },
      { status: 500 }
    );
  }
}

export async function PATCH(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json();
    const { status } = body;

    const updatedRequest = await prisma.user.update({
      where: { id: params.id },
      data: { status },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        status: true,
        role: true,
        province: true,
        createdAt: true,
      },
    });

    return NextResponse.json(updatedRequest);
  } catch (error) {
    console.error('Error updating driver request:', error);
    return NextResponse.json(
      { error: 'Failed to update driver request' },
      { status: 500 }
    );
  }
} 
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { parse } from 'cookie';

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Get session from cookie
    const cookie = request.headers.get('cookie');
    if (!cookie) {
      return NextResponse.json(
        { error: 'Unauthorized - No session' },
        { status: 401 }
      );
    }

    const cookies = parse(cookie);
    if (!cookies.session) {
      return NextResponse.json(
        { error: 'Unauthorized - No session' },
        { status: 401 }
      );
    }

    const session = JSON.parse(cookies.session);
    if (!session?.id) {
      return NextResponse.json(
        { error: 'Unauthorized - Invalid session' },
        { status: 401 }
      );
    }

    const { budget } = await request.json();

    if (typeof budget !== 'number' || isNaN(budget)) {
      return NextResponse.json(
        { error: 'Invalid budget value' },
        { status: 400 }
      );
    }

    // Get current user data
    const currentUser = await prisma.user.findUnique({
      where: { id: params.id },
      select: { budget: true }
    });

    if (!currentUser) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    const updatedUser = await prisma.user.update({
      where: { id: params.id },
      data: { budget },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        status: true,
        province: true,
        budget: true,
        createdAt: true,
      },
    });

    // Create log entry
    await prisma.userLog.create({
      data: {
        userId: params.id,
        type: 'BUDGET_UPDATE',
        details: `User budget updated from ${currentUser.budget} to ${budget}`,
        oldValue: currentUser.budget.toString(),
        newValue: budget.toString(),
        changedById: session.id,
      },
    });

    return NextResponse.json(updatedUser);
  } catch (error) {
    console.error('Error updating user budget:', error);
    return NextResponse.json(
      { error: 'Failed to update user budget' },
      { status: 500 }
    );
  }
} 
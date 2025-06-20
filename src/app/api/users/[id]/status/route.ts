import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { parse } from 'cookie';
import { UserStatus } from '@prisma/client';

interface SessionUser {
  id: string;
  name?: string | null;
  email?: string | null;
  role: string;
}

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    // Get session from cookie
    const cookie = request.headers.get('cookie');
    if (!cookie) {
      console.log('No cookie found');
      return NextResponse.json(
        { error: 'Unauthorized - No session' },
        { status: 401 }
      );
    }

    const cookies = parse(cookie);
    if (!cookies.session) {
      console.log('No session cookie found');
      return NextResponse.json(
        { error: 'Unauthorized - No session' },
        { status: 401 }
      );
    }

    const session = JSON.parse(cookies.session);
    console.log('Session:', session);

    if (!session?.role) {
      console.log('No role in session');
      return NextResponse.json(
        { error: 'Unauthorized - Invalid session' },
        { status: 401 }
      );
    }

    // Check if user is authenticated and is an admin
    if (session.role !== 'ADMIN') {
      console.log('User is not an admin. Current role:', session.role);
      return NextResponse.json(
        { error: 'Unauthorized - Admin access required' },
        { status: 401 }
      );
    }

    const { status } = await request.json();
    console.log('Updating status for user:', id, 'to:', status);

    // Validate status
    if (!Object.values(UserStatus).includes(status as UserStatus)) {
      console.log('Invalid status value:', status, 'Valid values:', Object.values(UserStatus));
      return NextResponse.json(
        { error: 'Invalid status value' },
        { status: 400 }
      );
    }

    // Get current user data
    const currentUser = await prisma.user.findUnique({
      where: { id },
      select: { status: true }
    });

    if (!currentUser) {
      console.log('User not found:', id);
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    console.log('Current user status:', currentUser.status);

    // Update user status
    const updatedUser = await prisma.user.update({
      where: { id },
      data: { status: status as UserStatus },
      select: {
        id: true,
        fullName: true,
        status: true,
        role: true
      }
    });

    console.log('User updated successfully:', updatedUser);

    // Create log entry
    await prisma.userLog.create({
      data: {
        userId: id,
        type: 'STATUS_CHANGE',
        details: `User status changed from ${currentUser.status} to ${status}`,
        oldValue: currentUser.status,
        newValue: status,
        changedById: session.id,
      },
    });

    return NextResponse.json(updatedUser);
  } catch (error) {
    console.error('Error updating user status:', error);
    if (error instanceof Error) {
      console.error('Error details:', {
        message: error.message,
        stack: error.stack,
        name: error.name
      });
    }
    return NextResponse.json(
      { error: 'Failed to update user status' },
      { status: 500 }
    );
  }
} 
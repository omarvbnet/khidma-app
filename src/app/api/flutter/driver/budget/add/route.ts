import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

// Middleware to verify JWT token
async function verifyToken(req: NextRequest) {
  const authHeader = req.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };
    return decoded.userId;
  } catch (error) {
    return null;
  }
}

// Add budget to driver (for testing purposes)
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { amount } = await req.json();

    if (!amount || typeof amount !== 'number' || amount <= 0) {
      return NextResponse.json(
        { error: 'Valid amount is required' },
        { status: 400 }
      );
    }

    // Get user to check role
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        budget: true,
        role: true,
      }
    });

    if (!user || user.role !== 'DRIVER') {
      return NextResponse.json({ error: 'Driver not found' }, { status: 404 });
    }

    // Update budget
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        budget: {
          increment: amount
        }
      }
    });

    // Log the budget transaction
    await prisma.userLog.create({
      data: {
        userId: userId,
        type: 'BUDGET_ADDED',
        details: `Added ${amount} IQD to budget for testing`,
        oldValue: user.budget.toString(),
        newValue: updatedUser.budget.toString(),
        changedById: userId, // Driver is changing their own budget
      }
    });

    return NextResponse.json({
      message: 'Budget added successfully',
      previousBudget: user.budget,
      addedAmount: amount,
      newBudget: updatedUser.budget,
      driverName: updatedUser.fullName
    });
  } catch (error) {
    console.error('Error adding budget:', error);
    return NextResponse.json(
      { error: 'Failed to add budget' },
      { status: 500 }
    );
  }
} 
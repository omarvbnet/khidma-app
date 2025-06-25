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

// Test endpoint to debug budget issues
export async function GET(req: NextRequest) {
  console.log('\n=== BUDGET TEST ENDPOINT ===');
  
  const userId = await verifyToken(req);
  if (!userId) {
    console.log('❌ Unauthorized - No valid token');
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  console.log('✅ Authenticated user ID:', userId);

  try {
    // Get user with all details
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: true,
      }
    });

    console.log('🔍 Full user data:', JSON.stringify(user, null, 2));

    if (!user) {
      console.log('❌ User not found');
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    if (user.role !== 'DRIVER') {
      console.log('❌ User is not a driver:', user.role);
      return NextResponse.json({ error: 'User is not a driver' }, { status: 400 });
    }

    // Add some test budget if it's 0
    let updatedBudget = user.budget;
    if (user.budget === 0) {
      console.log('💰 Adding test budget of 5000 IQD');
      const updatedUser = await prisma.user.update({
        where: { id: userId },
        data: {
          budget: 5000
        }
      });
      updatedBudget = updatedUser.budget;
      
      // Log the transaction
      await prisma.userLog.create({
        data: {
          userId: userId,
          type: 'BUDGET_TEST_ADDED',
          details: 'Added 5000 IQD test budget',
          oldValue: user.budget.toString(),
          newValue: updatedUser.budget.toString(),
          changedById: userId,
        }
      });
    }

    return NextResponse.json({
      message: 'Budget test completed',
      user: {
        id: user.id,
        fullName: user.fullName,
        role: user.role,
        originalBudget: user.budget,
        currentBudget: updatedBudget,
        province: user.province,
        status: user.status,
      },
      driver: user.driver ? {
        id: user.driver.id,
        fullName: user.driver.fullName,
        phoneNumber: user.driver.phoneNumber,
        carType: user.driver.carType,
        rate: user.driver.rate,
      } : null,
      testBudgetAdded: user.budget === 0,
      currency: 'IQD'
    });
  } catch (error) {
    console.error('❌ Error in budget test:', error);
    return NextResponse.json(
      { error: 'Failed to test budget', details: error },
      { status: 500 }
    );
  }
} 
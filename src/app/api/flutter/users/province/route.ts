import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

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

export async function PATCH(request: NextRequest) {
  const userId = await verifyToken(request);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { province } = await request.json();

    if (!province) {
      return NextResponse.json(
        { error: 'Province is required' },
        { status: 400 }
      );
    }

    const user = await prisma.user.update({
      where: { id: userId },
      data: { province },
    });

    return NextResponse.json(user);
  } catch (error) {
    console.error('Error updating province:', error);
    return NextResponse.json(
      { error: 'Failed to update province' },
      { status: 500 }
    );
  }
} 
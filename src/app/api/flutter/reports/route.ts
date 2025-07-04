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

// Get user's reports
export async function GET(req: NextRequest) {
  try {
    const userId = await verifyToken(req);
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const reports = await prisma.report.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        type: true,
        title: true,
        description: true,
        status: true,
        priority: true,
        category: true,
        createdAt: true,
        updatedAt: true,
        resolvedAt: true,
      },
    });

    return NextResponse.json({ reports });
  } catch (error) {
    console.error('Error fetching reports:', error);
    return NextResponse.json(
      { error: 'Failed to fetch reports' },
      { status: 500 }
    );
  }
}

// Create a new report
export async function POST(req: NextRequest) {
  try {
    const userId = await verifyToken(req);
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { type, title, description, priority, category, attachments } = await req.json();

    if (!type || !title || !description) {
      return NextResponse.json(
        { error: 'Type, title, and description are required' },
        { status: 400 }
      );
    }

    const report = await prisma.report.create({
      data: {
        userId,
        type,
        title,
        description,
        priority: priority || 'MEDIUM',
        category,
        attachments: attachments ? JSON.parse(JSON.stringify(attachments)) : null,
      },
      select: {
        id: true,
        type: true,
        title: true,
        description: true,
        status: true,
        priority: true,
        category: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    // Log the report creation
    await prisma.userLog.create({
      data: {
        userId,
        type: 'REPORT_CREATED',
        details: `Report created: ${title}`,
        changedById: userId,
      },
    });

    return NextResponse.json({ 
      message: 'Report created successfully',
      report 
    });
  } catch (error) {
    console.error('Error creating report:', error);
    return NextResponse.json(
      { error: 'Failed to create report' },
      { status: 500 }
    );
  }
} 
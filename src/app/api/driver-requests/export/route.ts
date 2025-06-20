import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { Role, UserStatus } from '@prisma/client';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const from = searchParams.get('from');
    const to = searchParams.get('to');
    const phone = searchParams.get('phone');

    const where = {
      role: 'DRIVER' as Role,
      status: 'PENDING' as UserStatus,
      ...(phone ? {
        phone: {
          contains: phone,
          mode: 'insensitive',
        },
      } : {}),
      ...(from && to ? {
        createdAt: {
          gte: new Date(from),
          lte: new Date(to),
        },
      } : {}),
    };

    const users = await prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        status: true,
        role: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Convert to CSV
    const headers = [
      'ID',
      'Name',
      'Email',
      'Phone',
      'Status',
      'Role',
      'Created At',
    ];

    const rows = users.map((user) => [
      user.id,
      user.name,
      user.email,
      user.phone || '',
      user.status,
      user.role,
      user.createdAt.toISOString(),
    ]);

    const csv = [
      headers.join(','),
      ...rows.map((row) => row.join(',')),
    ].join('\n');

    return new NextResponse(csv, {
      headers: {
        'Content-Type': 'text/csv',
        'Content-Disposition': 'attachment; filename="driver-requests.csv"',
      },
    });
  } catch (error) {
    console.error('Error exporting driver requests:', error);
    return NextResponse.json(
      { error: 'Failed to export driver requests' },
      { status: 500 }
    );
  }
} 
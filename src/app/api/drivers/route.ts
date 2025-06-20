import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest, User } from '@prisma/client';

type DriverWithTrips = User & {
  taxiRequests: {
    paymentStatus: 'PAID' | 'UNPAID';
    licenseId: string | null;
    driverId: string | null;
  }[];
};

export async function GET() {
  try {
    const drivers = await prisma.user.findMany({
      where: {
        role: "DRIVER",
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        status: true,
        role: true,
        province: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return NextResponse.json(drivers);
  } catch (error) {
    console.error("Error fetching drivers:", error);
    return NextResponse.json(
      { error: "Failed to fetch drivers" },
      { status: 500 }
    );
  }
} 
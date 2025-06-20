import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const query = searchParams.get('query') || '';
  const status = searchParams.get('status') || '';
  const tripType = searchParams.get('tripType') || '';
  const startDate = searchParams.get('startDate') || '';
  const endDate = searchParams.get('endDate') || '';

  try {
    const where: any = {};

    if (query) {
      where.OR = [
        { id: { contains: query } },
        { userId: { contains: query } },
        { driverId: { contains: query } },
        { user: { fullName: { contains: query } } },
        { user: { phoneNumber: { contains: query } } },
        { pickupLocation: { contains: query } },
        { dropoffLocation: { contains: query } },
        { userFullName: { contains: query } },
        { userPhone: { contains: query } },
      ];
    }

    if (status) {
      where.status = status;
    }

    if (tripType) {
      where.tripType = tripType;
    }

    if (startDate && endDate) {
      where.createdAt = {
        gte: new Date(startDate),
        lte: new Date(endDate + 'T23:59:59.999Z'),
      };
    } else if (startDate) {
      where.createdAt = {
        gte: new Date(startDate),
      };
    } else if (endDate) {
      where.createdAt = {
        lte: new Date(endDate + 'T23:59:59.999Z'),
      };
    }

    const [taxiRequests, totalCount] = await Promise.all([
      prisma.taxiRequest.findMany({
        where,
        include: {
          user: {
            select: {
              fullName: true,
              phoneNumber: true,
              province: true,
              _count: {
                select: {
                  taxiRequests: true
                }
              }
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      }),
      prisma.taxiRequest.count({ where })
    ]);

    const formattedRequests = taxiRequests.map((request) => ({
      id: request.id,
      userId: request.userId,
      driverName: request.driverName,
      userName: request.userFullName,
      userPhone: request.userPhone,
      province: request.userProvince,
      pickup: request.pickupLocation,
      destination: request.dropoffLocation,
      status: request.status,
      tripType: request.tripType,
      createdAt: request.createdAt,
      totalRequests: request.user._count.taxiRequests,
      price: request.price,
      distance: request.distance
    }));

    return NextResponse.json({
      requests: formattedRequests,
      totalCount
    });
  } catch (error) {
    console.error('Error fetching taxi requests:', error);
    return NextResponse.json(
      { error: 'Failed to fetch taxi requests' },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  const { 
    userId, 
    status, 
    pickupLocation, 
    dropoffLocation, 
    price = 0, 
    distance = 0,
    userFullName,
    userPhone,
    userProvince,
    pickupLat = 0,
    pickupLng = 0,
    dropoffLat = 0,
    dropoffLng = 0
  } = await req.json();
  
  if (!userId || !pickupLocation || !dropoffLocation || !userFullName || !userPhone || !userProvince) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }
  
  const taxiRequest = await prisma.taxiRequest.create({
    data: {
      userId,
      status: status || 'USER_WAITING',
      pickupLocation,
      dropoffLocation,
      price,
      distance,
      userFullName,
      userPhone,
      userProvince,
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    },
  });
  return NextResponse.json(taxiRequest);
} 
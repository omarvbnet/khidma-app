import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

interface ProvinceStats {
  [key: string]: {
    users: number;
    drivers: number;
    orders: number;
    requests: number;
  };
}

export async function GET() {
  try {
    // Get total counts
    const [totalUsers, totalDrivers, totalOrders, totalRequests] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { role: 'DRIVER' } }),
      prisma.order.count(),
      prisma.taxiRequest.count(),
    ]);

    // Get province-wise statistics
    const users = await prisma.user.groupBy({
      by: ['province'],
      _count: {
        _all: true,
      },
    });

    const drivers = await prisma.user.groupBy({
      by: ['province'],
      where: { role: 'DRIVER' },
      _count: {
        _all: true,
      },
    });

    // Get orders with user province data
    const ordersWithUsers = await prisma.order.findMany({
      include: {
        user: {
          select: {
            province: true,
          },
        },
      },
    });

    const requests = await prisma.taxiRequest.findMany({
      include: {
        user: {
          select: {
            province: true,
          },
        },
      },
    });

    // Combine province statistics
    const provinceStats: ProvinceStats = {};
    const orderProvinces = ordersWithUsers.map(o => o.user.province).filter(Boolean) as string[];
    const requestProvinces = requests.map(r => r.user.province).filter(Boolean) as string[];
    const provinces = new Set([
      ...users.map((u) => u.province).filter(Boolean) as string[],
      ...drivers.map((d) => d.province).filter(Boolean) as string[],
      ...orderProvinces,
      ...requestProvinces,
    ]);

    provinces.forEach(province => {
      if (!province) return;
      provinceStats[province] = {
        users: users.find((u) => u.province === province)?._count._all || 0,
        drivers: drivers.find((d) => d.province === province)?._count._all || 0,
        orders: orderProvinces.filter(p => p === province).length,
        requests: requestProvinces.filter(p => p === province).length,
      };
    });

    // Get trends for the last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const [requestTrends, userTrends, orderTrends] = await Promise.all([
      prisma.taxiRequest.groupBy({
        by: ['createdAt'],
        where: {
          createdAt: {
            gte: sevenDaysAgo,
          },
        },
        _count: {
          _all: true,
        },
        orderBy: {
          createdAt: 'asc',
        },
      }),
      prisma.user.groupBy({
        by: ['createdAt'],
        where: {
          createdAt: {
            gte: sevenDaysAgo,
          },
        },
        _count: {
          _all: true,
        },
        orderBy: {
          createdAt: 'asc',
        },
      }),
      prisma.order.groupBy({
        by: ['createdAt'],
        where: {
          createdAt: {
            gte: sevenDaysAgo,
          },
        },
        _count: {
          _all: true,
        },
        orderBy: {
          createdAt: 'asc',
        },
      }),
    ]);

    const formatTrends = (trends: any[]) => trends.map(trend => ({
      date: trend.createdAt.toISOString().split('T')[0],
      count: trend._count._all,
    }));

    return NextResponse.json({
      totalUsers,
      totalDrivers,
      totalOrders,
      totalRequests,
      provinceStats,
      requestTrends: formatTrends(requestTrends),
      userTrends: formatTrends(userTrends),
      orderTrends: formatTrends(orderTrends),
    });
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard stats' },
      { status: 500 }
    );
  }
} 
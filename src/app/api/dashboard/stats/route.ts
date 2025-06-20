import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  try {
    // Get basic stats
    const [totalUsers, totalDrivers, totalOrders, totalRequests] = await Promise.all([
      prisma.user.count({ where: { role: 'USER' } }),
      prisma.user.count({ where: { role: 'DRIVER' } }),
      prisma.order.count(),
      prisma.taxiRequest.count(),
    ]);

    // Get recent trends (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const [recentUsers, recentDrivers, recentOrders, recentRequests] = await Promise.all([
      prisma.user.count({
        where: {
          role: 'USER',
          createdAt: { gte: sevenDaysAgo }
        }
      }),
      prisma.user.count({
        where: {
          role: 'DRIVER',
          createdAt: { gte: sevenDaysAgo }
        }
      }),
      prisma.order.count({
        where: {
          createdAt: { gte: sevenDaysAgo }
        }
      }),
      prisma.taxiRequest.count({
        where: {
          createdAt: { gte: sevenDaysAgo }
        }
      }),
    ]);

    // Get top 10 users by request count
    const topUsers = await prisma.user.findMany({
      where: { role: 'USER' },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
        _count: {
          select: {
            taxiRequests: true
          }
        }
      },
      orderBy: {
        taxiRequests: {
          _count: 'desc'
        }
      },
      take: 10
    });

    // Get all users and requests for province statistics
    const [allUsers, allRequests] = await Promise.all([
      prisma.user.findMany({
        select: {
          role: true,
          province: true
        }
      }),
      prisma.taxiRequest.findMany({
        select: {
          userProvince: true
        }
      })
    ]);

    // Calculate province statistics
    const provinceMap = new Map();
    
    // Process users
    allUsers.forEach(user => {
      if (user.province) {
        if (!provinceMap.has(user.province)) {
          provinceMap.set(user.province, {
            province: user.province,
            totalUsers: 0,
            totalDrivers: 0,
            totalRequests: 0
          });
        }
        
        const stats = provinceMap.get(user.province);
        if (user.role === 'USER') {
          stats.totalUsers++;
        } else if (user.role === 'DRIVER') {
          stats.totalDrivers++;
        }
      }
    });

    // Process requests
    allRequests.forEach(request => {
      if (request.userProvince && provinceMap.has(request.userProvince)) {
        provinceMap.get(request.userProvince).totalRequests++;
      }
    });

    const provinceData = Array.from(provinceMap.values());

    // Get daily trends for the last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const dailyTrends = await prisma.taxiRequest.findMany({
      where: {
        createdAt: { gte: thirtyDaysAgo }
      },
      select: {
        createdAt: true
      },
      orderBy: {
        createdAt: 'asc'
      }
    });

    // Group by date
    const trendsMap = new Map();
    dailyTrends.forEach(trend => {
      const date = trend.createdAt.toISOString().split('T')[0];
      trendsMap.set(date, (trendsMap.get(date) || 0) + 1);
    });

    const trendsData = Array.from(trendsMap.entries()).map(([date, count]) => ({
      date,
      count
    }));

    return NextResponse.json({
      stats: {
        totalUsers,
        totalDrivers,
        totalOrders,
        totalRequests,
        recentUsers,
        recentDrivers,
        recentOrders,
        recentRequests
      },
      topUsers: topUsers.map(user => ({
        id: user.id,
        name: user.fullName,
        phone: user.phoneNumber,
        province: user.province,
        requestCount: user._count.taxiRequests
      })),
      provinces: provinceData,
      trends: trendsData
    });
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard statistics' },
      { status: 500 }
    );
  }
} 
"use client";
import { useEffect, useState } from 'react';
import { useTheme } from '@/contexts/ThemeContext';
import { Overview } from '@/components/ui/overview-chart';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { TrendingUp, TrendingDown, Users, Car, Package, MapPin } from 'lucide-react';

interface DashboardStats {
  totalUsers: number;
  totalDrivers: number;
  totalOrders: number;
  totalRequests: number;
  recentUsers: number;
  recentDrivers: number;
  recentOrders: number;
  recentRequests: number;
}

interface TopUser {
  id: string;
  name: string;
  phone: string;
  province: string;
  requestCount: number;
}

interface ProvinceData {
  province: string;
  totalUsers: number;
  totalDrivers: number;
  totalRequests: number;
}

interface TrendData {
  date: string;
  count: number;
}

interface DashboardData {
  stats: DashboardStats;
  topUsers: TopUser[];
  provinces: ProvinceData[];
  trends: TrendData[];
}

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { theme } = useTheme();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('/api/dashboard/stats');
        if (!response.ok) {
          throw new Error('Failed to fetch dashboard data');
        }
        const dashboardData = await response.json();
        setData(dashboardData);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const getTrendIcon = (current: number, previous: number) => {
    if (current > previous) {
      return <TrendingUp className="h-4 w-4 text-green-600" />;
    } else if (current < previous) {
      return <TrendingDown className="h-4 w-4 text-red-600" />;
    }
    return null;
  };

  const getTrendColor = (current: number, previous: number) => {
    if (current > previous) return 'text-green-600';
    if (current < previous) return 'text-red-600';
    return 'text-gray-600';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-40">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-destructive/10 border border-destructive text-destructive px-4 py-3 rounded mb-6">
        {error}
      </div>
    );
  }

  if (!data) return null;

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Dashboard Overview</h1>
        <p className="text-muted-foreground mt-2">
          Monitor your taxi booking service performance and user activity
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total Users
            </CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">{data.stats.totalUsers}</div>
            <div className="flex items-center space-x-2 text-xs text-muted-foreground">
              {getTrendIcon(data.stats.recentUsers, 0)}
              <span className={getTrendColor(data.stats.recentUsers, 0)}>
                +{data.stats.recentUsers} this week
              </span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total Drivers
            </CardTitle>
            <Car className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">{data.stats.totalDrivers}</div>
            <div className="flex items-center space-x-2 text-xs text-muted-foreground">
              {getTrendIcon(data.stats.recentDrivers, 0)}
              <span className={getTrendColor(data.stats.recentDrivers, 0)}>
                +{data.stats.recentDrivers} this week
              </span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total Orders
            </CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">{data.stats.totalOrders}</div>
            <div className="flex items-center space-x-2 text-xs text-muted-foreground">
              {getTrendIcon(data.stats.recentOrders, 0)}
              <span className={getTrendColor(data.stats.recentOrders, 0)}>
                +{data.stats.recentOrders} this week
              </span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total Requests
            </CardTitle>
            <MapPin className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">{data.stats.totalRequests}</div>
            <div className="flex items-center space-x-2 text-xs text-muted-foreground">
              {getTrendIcon(data.stats.recentRequests, 0)}
              <span className={getTrendColor(data.stats.recentRequests, 0)}>
                +{data.stats.recentRequests} this week
              </span>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Trends Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Taxi Requests Trend</CardTitle>
            <CardDescription>
              Daily taxi request activity over the last 30 days
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Overview data={data.trends} />
          </CardContent>
        </Card>

        {/* Top Users */}
        <Card>
          <CardHeader>
            <CardTitle>Top 10 Users</CardTitle>
            <CardDescription>
              Users with the most taxi requests
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {data.topUsers.map((user, index) => (
                <div key={user.id} className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="flex items-center justify-center w-8 h-8 rounded-full bg-primary/10 text-primary font-semibold">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{user.name}</p>
                      <p className="text-sm text-muted-foreground">{user.phone}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <Badge variant="secondary">{user.requestCount} requests</Badge>
                    <p className="text-xs text-muted-foreground mt-1">{user.province}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Province Statistics */}
      <Card>
        <CardHeader>
          <CardTitle>Province Statistics</CardTitle>
          <CardDescription>
            Distribution of users, drivers, and requests by province
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {data.provinces.map((province) => (
              <div key={province.province} className="p-4 border rounded-lg bg-card">
                <h3 className="font-semibold text-foreground mb-3">{province.province}</h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Users:</span>
                    <span className="font-medium">{province.totalUsers}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Drivers:</span>
                    <span className="font-medium">{province.totalDrivers}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Requests:</span>
                    <span className="font-medium">{province.totalRequests}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
} 
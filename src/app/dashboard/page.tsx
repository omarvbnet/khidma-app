"use client";
import { useEffect, useState } from 'react';
import Navigation from '@/components/Navigation';

interface DashboardStats {
  totalUsers: number;
  totalDrivers: number;
  totalOrders: number;
  totalRequests: number;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await fetch('/api/dashboard/stats');
        if (!response.ok) {
          throw new Error('Failed to fetch dashboard stats');
        }
        const data = await response.json();
        setStats(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  return (
    <div>
      <Navigation />
      <main className="p-8">
        <h1 className="text-3xl font-bold mb-6">Dashboard Overview</h1>
        
        {loading && (
          <div className="flex items-center justify-center h-40">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        )}

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-6">
            {error}
          </div>
        )}

        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div className="bg-white p-6 rounded shadow">
              <div className="text-gray-500">Total Users</div>
              <div className="text-2xl font-bold text-blue-600">{stats.totalUsers}</div>
            </div>
            <div className="bg-white p-6 rounded shadow">
              <div className="text-gray-500">Total Drivers</div>
              <div className="text-2xl font-bold text-green-600">{stats.totalDrivers}</div>
            </div>
            <div className="bg-white p-6 rounded shadow">
              <div className="text-gray-500">Total Orders</div>
              <div className="text-2xl font-bold text-purple-600">{stats.totalOrders}</div>
            </div>
            <div className="bg-white p-6 rounded shadow">
              <div className="text-gray-500">Total Taxi Requests</div>
              <div className="text-2xl font-bold text-orange-600">{stats.totalRequests}</div>
            </div>
          </div>
        )}

        {/* Placeholder for charts/statistics */}
        <div className="bg-white p-6 rounded shadow">
          <div className="text-gray-500 mb-2">Statistics</div>
          <div className="h-40 flex items-center justify-center text-gray-400">[Charts coming soon]</div>
        </div>
      </main>
    </div>
  );
} 
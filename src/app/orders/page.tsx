"use client";
import { useState, useEffect, Suspense } from 'react';
import Link from 'next/link';
import { Search } from '@/components/ui/Search';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { useSearchParams } from 'next/navigation';
import { PlusIcon, ArrowDownTrayIcon } from '@heroicons/react/24/outline';

interface Order {
  id: string;
  userId: string;
  status: string;
  total: number;
  createdAt: string;
  user?: {
    name: string;
    email: string;
  };
}

const orderStatusOptions = [
  { label: 'Pending', value: 'PENDING' },
  { label: 'Confirmed', value: 'CONFIRMED' },
  { label: 'Completed', value: 'COMPLETED' },
  { label: 'Cancelled', value: 'CANCELLED' },
];

function OrdersContent() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const searchParams = useSearchParams();
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  useEffect(() => {
    fetchOrders();
  }, [searchParams, startDate, endDate]);

  const fetchOrders = async () => {
    const query = searchParams.get('query') || '';
    const status = searchParams.get('status') || '';
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/orders?query=${query}&status=${status}&startDate=${startDate}&endDate=${endDate}`);
      const data = await res.json();
      
      // Ensure data is an array
      if (Array.isArray(data)) {
        setOrders(data);
      } else if (data.error) {
        setError(data.error);
        setOrders([]);
      } else {
        console.error('Unexpected data format:', data);
        setError('Unexpected data format received');
        setOrders([]);
      }
    } catch (error) {
      console.error('Error fetching orders:', error);
      setError('Failed to fetch orders');
      setOrders([]);
    }
    setLoading(false);
  };

  const handleExport = () => {
    const headers = ['Order ID', 'Customer', 'Date', 'Total', 'Status'];
    const csvData = orders.map(order => [
      order.id,
      order.user?.name || order.userId,
      new Date(order.createdAt).toLocaleDateString(),
      `$${order.total.toFixed(2)}`,
      order.status
    ]);

    const csvContent = [
      headers.join(','),
      ...csvData.map(row => row.join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `orders-${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  if (loading) {
    return (
      <div className="py-12">
        <div className="animate-pulse max-w-4xl mx-auto">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="page-header">
        <div>
          <h1 className="page-title">Orders</h1>
          <p className="page-description">
            View and manage customer orders.
          </p>
        </div>
        <div className="flex w-full flex-col sm:flex-row sm:w-auto gap-2">
          <Search placeholder="Search by user or order ID..." />
          <StatusFilter options={orderStatusOptions} filterKey="status" />
          <div className="flex gap-2">
            <input
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="form-input"
            />
            <input
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              className="form-input"
            />
          </div>
          <button
            onClick={handleExport}
            className="btn-secondary"
          >
            <ArrowDownTrayIcon className="h-5 w-5 mr-2" />
            Export
          </button>
          <Link href="/orders/create" className="btn-primary">
            <PlusIcon className="h-5 w-5 mr-2" />
            Create Order
          </Link>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div className="table-container">
        <table className="table">
          <thead className="table-header">
            <tr>
              <th scope="col" className="table-header-cell">Order ID</th>
              <th scope="col" className="table-header-cell">Customer</th>
              <th scope="col" className="table-header-cell">Date</th>
              <th scope="col" className="table-header-cell">Total</th>
              <th scope="col" className="table-header-cell">Status</th>
              <th scope="col" className="table-header-cell">Actions</th>
            </tr>
          </thead>
          <tbody className="table-body">
            {orders.length === 0 ? (
              <tr>
                <td colSpan={6} className="table-cell text-center py-8 text-gray-500">
                  {error ? 'Error loading orders' : 'No orders found'}
                </td>
              </tr>
            ) : (
              orders.map((order) => (
                <tr key={order.id} className="table-row">
                  <td className="table-cell">{order.id}</td>
                  <td className="table-cell">{order.user?.name || order.userId}</td>
                  <td className="table-cell">{new Date(order.createdAt).toLocaleDateString()}</td>
                  <td className="table-cell">${order.total.toFixed(2)}</td>
                  <td className="table-cell">
                    <span className={`badge badge-${order.status.toLowerCase()}`}>
                      {order.status}
                    </span>
                  </td>
                  <td className="table-cell">
                    <div className="flex items-center gap-2">
                      <Link href={`/orders/${order.id}`} className="btn-secondary">
                        View
                      </Link>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default function OrdersPage() {
  return (
    <Suspense fallback={
      <div className="py-12">
        <div className="animate-pulse max-w-4xl mx-auto">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    }>
      <OrdersContent />
    </Suspense>
  );
} 
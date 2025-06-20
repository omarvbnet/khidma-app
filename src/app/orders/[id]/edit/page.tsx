"use client";
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Navigation from '@/components/Navigation';

interface Order {
  id: string;
  userId: string;
  status: string;
  total: number;
  user?: {
    name: string;
    email: string;
  };
}

export default async function EditOrderPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  
  return <EditOrderClient orderId={id} />;
}

function EditOrderClient({ orderId }: { orderId: string }) {
  const router = useRouter();
  const [order, setOrder] = useState<Order | null>(null);
  const [userId, setUserId] = useState('');
  const [status, setStatus] = useState('PENDING');
  const [total, setTotal] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchOrder();
  }, [orderId]);

  const fetchOrder = async () => {
    try {
      const res = await fetch(`/api/orders/${orderId}`);
      if (!res.ok) throw new Error('Failed to fetch order');
      const data = await res.json();
      setOrder(data);
      setUserId(data.userId);
      setStatus(data.status);
      setTotal(data.total.toString());
    } catch (error) {
      setError('Failed to load order');
    }
    setLoading(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSaving(true);
    if (!userId || !total) {
      setError('User ID and total are required');
      setSaving(false);
      return;
    }
    try {
      const res = await fetch(`/api/orders/${orderId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId,
          status,
          total: parseFloat(total),
        }),
      });
      if (res.ok) {
        router.push('/orders');
      } else {
        const data = await res.json();
        setError(data.error || 'Failed to update order');
      }
    } catch (err) {
      setError('An error occurred');
    }
    setSaving(false);
  };

  if (loading) {
    return (
      <div>
        <Navigation />
        <main className="p-8">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
            <div className="space-y-4">
              <div className="h-12 bg-gray-200 rounded"></div>
              <div className="h-12 bg-gray-200 rounded"></div>
              <div className="h-12 bg-gray-200 rounded"></div>
            </div>
          </div>
        </main>
      </div>
    );
  }

  if (!order) {
    return (
      <div>
        <Navigation />
        <main className="p-8">
          <div className="text-red-500">Order not found</div>
        </main>
      </div>
    );
  }

  return (
    <div>
      <Navigation />
      <main className="p-8">
        <h1 className="text-3xl font-bold mb-6">Edit Order</h1>
        {error && <div className="mb-4 text-red-500">{error}</div>}
        <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow-md">
          <div className="mb-4">
            <label className="block mb-1 font-medium">User ID</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={userId}
              onChange={e => setUserId(e.target.value)}
              required
            />
            {order.user && (
              <div className="mt-1 text-sm text-gray-500">
                Current user: {order.user.name} ({order.user.email})
              </div>
            )}
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Status</label>
            <select
              className="w-full border px-3 py-2 rounded"
              value={status}
              onChange={e => setStatus(e.target.value)}
            >
              <option value="PENDING">Pending</option>
              <option value="CONFIRMED">Confirmed</option>
              <option value="COMPLETED">Completed</option>
              <option value="CANCELLED">Cancelled</option>
            </select>
          </div>
          <div className="mb-6">
            <label className="block mb-1 font-medium">Total</label>
            <input
              type="number"
              step="0.01"
              className="w-full border px-3 py-2 rounded"
              value={total}
              onChange={e => setTotal(e.target.value)}
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition"
            disabled={saving}
          >
            {saving ? 'Saving...' : 'Save Changes'}
          </button>
        </form>
      </main>
    </div>
  );
} 
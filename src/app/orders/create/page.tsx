"use client";
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Navigation from '@/components/Navigation';

export default function CreateOrderPage() {
  const router = useRouter();
  const [userId, setUserId] = useState('');
  const [status, setStatus] = useState('PENDING');
  const [total, setTotal] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    if (!userId || !total) {
      setError('User ID and total are required');
      setLoading(false);
      return;
    }
    try {
      const res = await fetch('/api/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, status, total: parseFloat(total) }),
      });
      if (res.ok) {
        router.push('/orders');
      } else {
        const data = await res.json();
        setError(data.error || 'Failed to create order');
      }
    } catch (err) {
      setError('An error occurred');
    }
    setLoading(false);
  };

  return (
    <div>
      <Navigation />
      <main className="p-8">
        <h1 className="text-3xl font-bold mb-6">Create Order</h1>
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
            disabled={loading}
          >
            {loading ? 'Creating...' : 'Create Order'}
          </button>
        </form>
      </main>
    </div>
  );
} 
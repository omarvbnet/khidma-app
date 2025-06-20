"use client";
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Navigation from '@/components/Navigation';

export default function CreateTaxiRequestPage() {
  const router = useRouter();
  const [userId, setUserId] = useState('');
  const [status, setStatus] = useState('PENDING');
  const [pickupLocation, setPickupLocation] = useState('');
  const [destination, setDestination] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    if (!userId || !pickupLocation || !destination) {
      setError('User ID, pickup location, and destination are required');
      setLoading(false);
      return;
    }
    try {
      const res = await fetch('/api/taxi-requests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId,
          status,
          pickupLocation,
          destination,
        }),
      });
      if (res.ok) {
        router.push('/taxi-requests');
      } else {
        const data = await res.json();
        setError(data.error || 'Failed to create taxi request');
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
        <h1 className="text-3xl font-bold mb-6">Create Taxi Request</h1>
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
              <option value="ACCEPTED">Accepted</option>
              <option value="COMPLETED">Completed</option>
              <option value="CANCELLED">Cancelled</option>
            </select>
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Pickup Location</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={pickupLocation}
              onChange={e => setPickupLocation(e.target.value)}
              required
            />
          </div>
          <div className="mb-6">
            <label className="block mb-1 font-medium">Destination</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={destination}
              onChange={e => setDestination(e.target.value)}
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition"
            disabled={loading}
          >
            {loading ? 'Creating...' : 'Create Taxi Request'}
          </button>
        </form>
      </main>
    </div>
  );
} 
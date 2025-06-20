"use client";
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Navigation from '@/components/Navigation';

export default function CreateUserPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('USER');
  const [status, setStatus] = useState('ACTIVE');
  const [province, setProvince] = useState('');
  const [budget, setBudget] = useState('0');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    if (!fullName || !phoneNumber || !password) {
      setError('Full name, phone number, and password are required');
      setLoading(false);
      return;
    }
    try {
      const res = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          fullName, 
          phoneNumber, 
          password, 
          role, 
          status, 
          province: province || 'Unknown',
          budget: parseFloat(budget) || 0
        }),
      });
      if (res.ok) {
        router.push('/users');
      } else {
        const data = await res.json();
        setError(data.error || 'Failed to create user');
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
        <h1 className="text-3xl font-bold mb-6">Create User</h1>
        {error && <div className="mb-4 text-red-500">{error}</div>}
        <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow-md">
          <div className="mb-4">
            <label className="block mb-1 font-medium">Full Name</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={fullName}
              onChange={e => setFullName(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Phone Number</label>
            <input
              type="tel"
              className="w-full border px-3 py-2 rounded"
              value={phoneNumber}
              onChange={e => setPhoneNumber(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Province</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={province}
              onChange={e => setProvince(e.target.value)}
              placeholder="e.g., Riyadh, Jeddah"
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Budget</label>
            <input
              type="number"
              step="0.01"
              className="w-full border px-3 py-2 rounded"
              value={budget}
              onChange={e => setBudget(e.target.value)}
              placeholder="0.00"
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Password</label>
            <input
              type="password"
              className="w-full border px-3 py-2 rounded"
              value={password}
              onChange={e => setPassword(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Role</label>
            <select
              className="w-full border px-3 py-2 rounded"
              value={role}
              onChange={e => setRole(e.target.value)}
            >
              <option value="USER">User</option>
              <option value="ADMIN">Admin</option>
              <option value="DRIVER">Driver</option>
            </select>
          </div>
          <div className="mb-6">
            <label className="block mb-1 font-medium">Status</label>
            <select
              className="w-full border px-3 py-2 rounded"
              value={status}
              onChange={e => setStatus(e.target.value)}
            >
              <option value="ACTIVE">Active</option>
              <option value="PENDING">Pending</option>
              <option value="SUSPENDED">Suspended</option>
              <option value="BLOCKED">Blocked</option>
            </select>
          </div>
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition"
            disabled={loading}
          >
            {loading ? 'Creating...' : 'Create User'}
          </button>
        </form>
      </main>
    </div>
  );
} 
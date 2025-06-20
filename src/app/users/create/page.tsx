"use client";
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Navigation from '@/components/Navigation';

export default function CreateUserPage() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('USER');
  const [status, setStatus] = useState('ACTIVE');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [phone, setPhone] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    if (!name || !email || !password) {
      setError('Name, email, and password are required');
      setLoading(false);
      return;
    }
    try {
      const res = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, email, password, role, status, phone }),
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
            <label className="block mb-1 font-medium">Name</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={name}
              onChange={e => setName(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Email</label>
            <input
              type="email"
              className="w-full border px-3 py-2 rounded"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Phone</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={phone}
              onChange={e => setPhone(e.target.value)}
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
              <option value="INACTIVE">Inactive</option>
              <option value="SUSPENDED">Suspended</option>
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
"use client";
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';

export default function Navigation() {
  const { user, logout } = useAuth();
  if (!user) return null;
  return (
    <nav className="bg-white shadow px-4 py-3 flex items-center justify-between">
      <div className="flex items-center gap-6">
        <Link href="/dashboard" className="font-bold text-lg text-blue-700">Dashboard</Link>
        <Link href="/orders">Orders</Link>
        <Link href="/products">Products</Link>
        <Link href="/taxi-requests">Taxi Requests</Link>
        <Link href="/drivers">Drivers</Link>
        <Link href="/driver-requests">Driver Requests</Link>
      </div>
      <div className="flex items-center gap-4">
        <span className="text-gray-600">{user.role}</span>
        <button
          onClick={logout}
          className="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 transition"
        >
          Logout
        </button>
      </div>
    </nav>
  );
} 
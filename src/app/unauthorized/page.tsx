"use client";
import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function UnauthorizedPage() {
  const { user, logout } = useAuth();
  const router = useRouter();

  useEffect(() => {
    // If user is admin, redirect to home
    if (user?.role === 'ADMIN') {
      router.push('/');
    }
  }, [user, router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-lg shadow">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Access Denied
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            You do not have permission to access this application.
            Only administrators can access this system.
          </p>
        </div>
        <div className="mt-8 space-y-4">
          <button
            onClick={logout}
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          >
            Logout
          </button>
        </div>
      </div>
    </div>
  );
} 
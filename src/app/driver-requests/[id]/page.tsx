'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import Image from 'next/image';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { use } from 'react';

interface DriverRequest {
  id: string;
  fullName: string;
  phoneNumber: string;
  status: string;
  role: string;
  createdAt: string;
  province: string;
}

export default function DriverRequestDetailsPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const router = useRouter();
  const { id } = use(params);
  const [request, setRequest] = useState<DriverRequest | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchRequest();
  }, [id]);

  const fetchRequest = async () => {
    try {
      console.log('Fetching driver request for ID:', id);
      const response = await fetch(`/api/driver-requests/${id}`);
      console.log('Response status:', response.status);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', errorText);
        throw new Error(`Failed to fetch driver request: ${response.status} ${errorText}`);
      }
      
      const data = await response.json();
      console.log('Fetched data:', data);
      setRequest(data);
    } catch (error) {
      console.error('Error in fetchRequest:', error);
      toast.error('Failed to fetch driver request details');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    try {
      const response = await fetch(`/api/driver-requests/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: 'ACTIVE' }),
      });

      if (!response.ok) {
        throw new Error('Failed to approve driver request');
      }

      toast.success('Driver request approved successfully');
      router.push('/driver-requests');
    } catch (error) {
      toast.error('Failed to approve driver request');
      console.error('Error:', error);
    }
  };

  const handleCancel = async () => {
    try {
      const response = await fetch(`/api/driver-requests/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: 'SUSPENDED' }),
      });

      if (!response.ok) {
        throw new Error('Failed to cancel driver request');
      }

      toast.success('Driver request cancelled successfully');
      router.push('/driver-requests');
    } catch (error) {
      toast.error('Failed to cancel driver request');
      console.error('Error:', error);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (!request) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen">
        <h1 className="text-2xl font-bold mb-4">Driver Request Not Found</h1>
        <Link href="/driver-requests" className="text-blue-600 hover:underline">
          Back to Driver Requests
        </Link>
      </div>
    );
  }

  return (
    <div className="py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900">
          Driver Request Details
        </h1>
        <Link href="/driver-requests" className="btn-secondary">
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back to List
        </Link>
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 className="font-semibold text-lg mb-2">Personal Information</h3>
            <p><strong>Name:</strong> {request.fullName}</p>
            <p><strong>Phone:</strong> {request.phoneNumber}</p>
            <p><strong>Province:</strong> {request.province}</p>
            <p><strong>Status:</strong> {request.status}</p>
            <p><strong>Role:</strong> {request.role}</p>
            <p><strong>Created At:</strong> {new Date(request.createdAt).toLocaleString()}</p>
          </div>

          <div>
            <h3 className="font-semibold text-lg mb-2">Actions</h3>
            <div className="flex gap-4">
              <Button onClick={handleApprove} className="bg-green-600 hover:bg-green-700">
                Approve Request
              </Button>
              <Button onClick={handleCancel} variant="destructive">
                Cancel Request
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
} 
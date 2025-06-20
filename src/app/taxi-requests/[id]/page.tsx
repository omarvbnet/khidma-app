'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import React from 'react';

interface TaxiRequest {
  id: string;
  status: string;
  pickupLocation: string;
  dropoffLocation: string;
  tripType: string;
  driverName?: string;
  driverPhone?: string;
  driverRate?: number;
  carId?: string;
  carType?: string;
  licenseId?: string;
  price?: number;
  distance?: number;
  createdAt: string;
  userFullName: string;
  userPhone: string;
  userProvince: string;
}

export default function ViewTaxiRequestPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = React.use(params);
  const [request, setRequest] = useState<TaxiRequest | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchRequest() {
      try {
        const res = await fetch(`/api/taxi-requests/${id}`);
        if (res.ok) {
          const data = await res.json();
          setRequest(data);
        }
      } catch (error) {
        console.error('Failed to fetch taxi request', error);
      } finally {
        setLoading(false);
      }
    }
    fetchRequest();
  }, [id]);

  if (loading) {
    return <div className="py-12 text-center">Loading...</div>;
  }

  if (!request) {
    return <div className="py-12 text-center text-red-500">Taxi request not found.</div>;
  }

  return (
    <div className="py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900">
          Taxi Request Details
        </h1>
        <Link href="/taxi-requests" className="btn-secondary">
          Back to List
        </Link>
      </div>
      
      <div className="bg-white shadow rounded-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 className="font-semibold text-lg mb-2">Trip Information</h3>
            <p><strong>ID:</strong> {request.id}</p>
            <p><strong>Status:</strong> {request.status}</p>
            <p><strong>Type:</strong> {request.tripType}</p>
            <p><strong>Price:</strong> {request.price ? `${request.price} IQD` : 'N/A'}</p>
            <p><strong>Distance:</strong> {request.distance ? `${request.distance} km` : 'N/A'}</p>
            <p><strong>Date:</strong> {new Date(request.createdAt).toLocaleString()}</p>
          </div>
          <div>
            <h3 className="font-semibold text-lg mb-2">User Details</h3>
            <p><strong>Name:</strong> {request.userFullName}</p>
            <p><strong>Phone:</strong> {request.userPhone || 'N/A'}</p>
            <p><strong>Province:</strong> {request.userProvince || 'N/A'}</p>
          </div>
          <div>
            <h3 className="font-semibold text-lg mb-2">Driver Details</h3>
            <p><strong>Name:</strong> {request.driverName || 'N/A'}</p>
            <p><strong>Phone:</strong> {request.driverPhone || 'N/A'}</p>
            <p><strong>Rating:</strong> {request.driverRate ?? 'N/A'}</p>
          </div>
          <div>
            <h3 className="font-semibold text-lg mb-2">Vehicle Details</h3>
            <p><strong>Car ID (VIN):</strong> {request.carId || 'N/A'}</p>
            <p><strong>Car Type:</strong> {request.carType || 'N/A'}</p>
            <p><strong>License ID:</strong> {request.licenseId || 'N/A'}</p>
          </div>
          <div className="md:col-span-2">
            <h3 className="font-semibold text-lg mb-2">Locations</h3>
            <p><strong>Pickup:</strong> {request.pickupLocation}</p>
            <p><strong>Destination:</strong> {request.dropoffLocation}</p>
          </div>
        </div>
      </div>
    </div>
  );
} 
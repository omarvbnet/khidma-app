"use client";
import { useState, useEffect, Suspense } from 'react';
import Link from 'next/link';
import { Search } from '@/components/ui/Search';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { useSearchParams, useRouter } from 'next/navigation';
import { PlusIcon, ArrowDownTrayIcon } from '@heroicons/react/24/outline';

interface TaxiRequest {
  id: string;
  userId: string;
  requester_id?: string;
  requester_name?: string;
  status: string;
  tripType: string;
  pickup: string;
  destination: string;
  createdAt: string;
  driverName?: string;
  userName?: string;
  userEmail?: string;
  userPhone?: string;
  province?: string;
  totalRequests: number;
  tripTime?: number;
  tripCost?: number;
}

const taxiStatusOptions = [
  { value: '', label: 'All Statuses' },
  { value: 'WAITING', label: 'Waiting' },
  { value: 'IN_WAY', label: 'In Way' },
  { value: 'CHECK_OUT', label: 'Check Out' },
  { value: 'ARRIVED', label: 'Arrived' },
];

const tripTypeOptions = [
  { label: 'ECO', value: 'ECO' },
  { label: 'VIP', value: 'VIP' },
  { label: 'SPECIAL', value: 'SPECIAL' },
];

function TaxiRequestsContent() {
  const [taxiRequests, setTaxiRequests] = useState<TaxiRequest[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const searchParams = useSearchParams();
  const router = useRouter();
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  const updateSearchParams = (key: string, value: string) => {
    const params = new URLSearchParams(searchParams.toString());
    if (value) {
      params.set(key, value);
    } else {
      params.delete(key);
    }
    router.push(`/taxi-requests?${params.toString()}`);
  };

  useEffect(() => {
    fetchTaxiRequests();
  }, [searchParams, startDate, endDate]);

  const fetchTaxiRequests = async () => {
    const query = searchParams.get('query') || '';
    const status = searchParams.get('status') || '';
    const tripType = searchParams.get('tripType') || '';
    setLoading(true);
    try {
      const res = await fetch(`/api/taxi-requests?query=${query}&status=${status}&tripType=${tripType}&startDate=${startDate}&endDate=${endDate}`);
      const data = await res.json();
      setTaxiRequests(Array.isArray(data.requests) ? data.requests : []);
      setTotalCount(data.totalCount || 0);
    } catch (error) {
      console.error('Error fetching taxi requests:', error);
      setTaxiRequests([]);
      setTotalCount(0);
    }
    setLoading(false);
  };

  const handleExport = () => {
    const headers = ['ID', 'User', 'Phone', 'Trip Type', 'Status', 'Date'];
    const csvData = taxiRequests.map(request => [
      request.id,
      request.userName || request.userId,
      request.userPhone || 'N/A',
      request.tripType,
      request.status,
      new Date(request.createdAt).toLocaleDateString()
    ]);

    const csvContent = [
      headers.join(','),
      ...csvData.map(row => row.join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `taxi-requests-${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  if (loading) {
    return (
      <div>
        <main className="p-8">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-12 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="space-y-8 p-6">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex flex-col gap-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Taxi Requests</h1>
            <p className="mt-1 text-sm text-gray-500">
              Manage taxi service requests and assignments. Total requests: {totalCount}
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-gray-700">Search by ID</label>
              <input
                type="text"
                placeholder="Trip ID, Requester ID, or Driver ID"
                className="form-input rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-colors"
                defaultValue={searchParams.get('query') || ''}
                onChange={(e) => updateSearchParams('query', e.target.value)}
              />
            </div>
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-gray-700">Status</label>
              <select
                className="form-select rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-colors"
                defaultValue={searchParams.get('status') || ''}
                onChange={(e) => updateSearchParams('status', e.target.value)}
              >
                <option value="">All Statuses</option>
                {taxiStatusOptions.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-gray-700">Trip Type</label>
              <select
                className="form-select rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-colors"
                defaultValue={searchParams.get('tripType') || ''}
                onChange={(e) => updateSearchParams('tripType', e.target.value)}
              >
                <option value="">All Types</option>
                {tripTypeOptions.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-gray-700">Date Range</label>
              <div className="flex gap-2">
                <input
                  type="date"
                  value={startDate}
                  onChange={(e) => {
                    setStartDate(e.target.value);
                    updateSearchParams('startDate', e.target.value);
                  }}
                  className="form-input rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-colors"
                />
                <input
                  type="date"
                  value={endDate}
                  onChange={(e) => {
                    setEndDate(e.target.value);
                    updateSearchParams('endDate', e.target.value);
                  }}
                  className="form-input rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-colors"
                />
              </div>
            </div>
          </div>
          <div className="flex justify-between items-center">
            <div className="flex gap-2">
              <Link href="/taxi-requests/create" className="btn-primary">
                <PlusIcon className="h-5 w-5 mr-2" />
                Create Request
              </Link>
              <button onClick={handleExport} className="btn-secondary">
                <ArrowDownTrayIcon className="h-5 w-5 mr-2" />
                Export CSV
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Trip Type
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Pickup
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Destination
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {taxiRequests.map((request) => (
                <tr key={request.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {request.id}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <div>
                      <div className="font-medium">{request.userName || request.userId}</div>
                      <div className="text-gray-500">{request.userPhone || 'N/A'}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      request.tripType === 'VIP' ? 'bg-purple-100 text-purple-800' :
                      request.tripType === 'SPECIAL' ? 'bg-orange-100 text-orange-800' :
                      'bg-green-100 text-green-800'
                    }`}>
                      {request.tripType}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      request.status === 'WAITING' ? 'bg-yellow-100 text-yellow-800' :
                      request.status === 'IN_WAY' ? 'bg-blue-100 text-blue-800' :
                      request.status === 'ARRIVED' ? 'bg-green-100 text-green-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {request.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {request.pickup}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {request.destination}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(request.createdAt).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <Link
                      href={`/taxi-requests/${request.id}`}
                      className="text-blue-600 hover:text-blue-900"
                    >
                      View Details
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default function TaxiRequestsPage() {
  return (
    <Suspense fallback={
      <div>
        <main className="p-8">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-12 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
        </main>
      </div>
    }>
      <TaxiRequestsContent />
    </Suspense>
  );
}

const TaxiRequestDetails = ({ request }: { request: TaxiRequest }) => {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <h3 className="text-sm font-medium text-gray-500">User</h3>
          {request.userName && (
            <>
              <p className="mt-1">{request.userName}</p>
              <p className="text-sm text-gray-500">{request.userEmail}</p>
              <p className="text-sm text-gray-500">{request.userPhone}</p>
            </>
          )}
        </div>
        <div>
          <h3 className="text-sm font-medium text-gray-500">Driver</h3>
          <p className="mt-1">{request.driverName || 'Not assigned'}</p>
        </div>
      </div>
    </div>
  );
}; 
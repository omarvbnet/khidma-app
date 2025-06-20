'use client';

import { useState, useEffect } from 'react';
import { DataTable } from '@/components/ui/data-table';
import { columns } from './columns';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { DateRangePicker } from '@/components/ui/date-range-picker';
import { toast } from 'sonner';
import { Download } from 'lucide-react';
import { DateRange } from 'react-day-picker';

export default function DriverRequestsPage() {
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dateRange, setDateRange] = useState<DateRange>({
    from: undefined,
    to: undefined,
  });
  const [phoneFilter, setPhoneFilter] = useState('');

  useEffect(() => {
    fetchRequests();
  }, [dateRange, phoneFilter]);

  const fetchRequests = async () => {
    try {
      let apiUrl = '/api/driver-requests';
      const params = new URLSearchParams();

      if (dateRange.from) {
        params.append('from', dateRange.from.toISOString());
      }
      if (dateRange.to) {
        params.append('to', dateRange.to.toISOString());
      }
      if (phoneFilter) {
        params.append('phone', phoneFilter);
      }

      if (params.toString()) {
        apiUrl += `?${params.toString()}`;
      }

      const response = await fetch(apiUrl);
      if (!response.ok) {
        throw new Error('Failed to fetch driver requests');
      }
      const data = await response.json();
      setRequests(data);
    } catch (error) {
      toast.error('Failed to fetch driver requests');
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async () => {
    try {
      let apiUrl = '/api/driver-requests/export';
      const params = new URLSearchParams();

      if (dateRange.from) {
        params.append('from', dateRange.from.toISOString());
      }
      if (dateRange.to) {
        params.append('to', dateRange.to.toISOString());
      }
      if (phoneFilter) {
        params.append('phone', phoneFilter);
      }

      if (params.toString()) {
        apiUrl += `?${params.toString()}`;
      }

      const response = await fetch(apiUrl);
      if (!response.ok) {
        throw new Error('Failed to export driver requests');
      }

      const blob = await response.blob();
      const downloadUrl = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = downloadUrl;
      a.download = 'driver-requests.csv';
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(downloadUrl);
      document.body.removeChild(a);
    } catch (error) {
      toast.error('Failed to export driver requests');
      console.error('Error:', error);
    }
  };

  return (
    <div className="container mx-auto py-10">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Driver Requests</h1>
        <Button onClick={handleExport} className="flex items-center gap-2">
          <Download className="h-4 w-4" />
          Export
        </Button>
      </div>

      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <DateRangePicker
          value={dateRange}
          onChange={setDateRange}
          className="w-full sm:w-auto"
        />
        <Input
          placeholder="Filter by phone number"
          value={phoneFilter}
          onChange={(e) => setPhoneFilter(e.target.value)}
          className="w-full sm:w-64"
        />
      </div>

      <DataTable columns={columns} data={requests} loading={loading} />
    </div>
  );
} 
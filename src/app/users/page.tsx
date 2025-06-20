"use client";
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { PlusIcon } from '@heroicons/react/24/outline';
import { Search } from '@/components/ui/Search';
import { useSearchParams } from 'next/navigation';
import { DataTable } from '@/components/ui/data-table';
import { columns, User } from './columns';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { DateRangePicker } from '@/components/ui/date-range-picker';
import { toast } from 'sonner';
import { Download, History } from 'lucide-react';
import { DateRange } from 'react-day-picker';

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [dateRange, setDateRange] = useState<DateRange>({
    from: undefined,
    to: undefined,
  });
  const [phoneFilter, setPhoneFilter] = useState('');

  useEffect(() => {
    fetchUsers();
  }, [dateRange, phoneFilter]);

  const fetchUsers = async () => {
    try {
      let apiUrl = '/api/users';
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
        throw new Error('Failed to fetch users');
      }
      const data = await response.json();
      setUsers(data);
    } catch (error) {
      toast.error('Failed to fetch users');
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async () => {
    try {
      let apiUrl = '/api/users/export';
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
        throw new Error('Failed to export users');
      }

      const blob = await response.blob();
      const downloadUrl = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = downloadUrl;
      a.download = 'users.csv';
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(downloadUrl);
      document.body.removeChild(a);
    } catch (error) {
      toast.error('Failed to export users');
      console.error('Error:', error);
    }
  };

  if (loading) {
    return (
      <div className="py-12">
        <div className="animate-pulse max-w-4xl mx-auto">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="page-header">
        <div>
          <h1 className="page-title">Users</h1>
          <p className="page-description">
            Manage your application users and their permissions.
          </p>
        </div>
        <div className="flex w-full sm:w-auto gap-2">
          <Search placeholder="Search users..." />
          <Link href="/users/create" className="btn-primary">
            <PlusIcon className="h-5 w-5 mr-2" />
            Create User
          </Link>
          <Button onClick={handleExport} className="flex items-center gap-2">
            <Download className="h-4 w-4" />
            Export
          </Button>
          <Link href="/users/logs">
            <Button variant="outline">
              <History className="mr-2 h-4 w-4" />
              View Logs
            </Button>
          </Link>
        </div>
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

      <DataTable 
        columns={columns} 
        data={users} 
        loading={loading}
        meta={{
          updateData: (newData: User[]) => {
            setUsers(newData);
          },
        }}
      />
    </div>
  );
} 
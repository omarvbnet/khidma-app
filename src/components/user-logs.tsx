'use client';

import { useEffect, useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";
import { Input } from "@/components/ui/input";
import { DateRangePicker } from "@/components/ui/date-range-picker";
import { DateRange } from "react-day-picker";

interface UserLog {
  id: string;
  userId: string;
  type: string;
  details: string;
  oldValue: string | null;
  newValue: string | null;
  createdAt: string;
  user: {
    name: string;
    email: string;
    phone: string;
  };
  changedBy: {
    name: string;
    email: string;
  };
}

export function UserLogs() {
  const [logs, setLogs] = useState<UserLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [phoneFilter, setPhoneFilter] = useState('');
  const [dateRange, setDateRange] = useState<DateRange>({
    from: undefined,
    to: undefined,
  });

  useEffect(() => {
    fetchLogs();
  }, [dateRange, phoneFilter]);

  const fetchLogs = async () => {
    try {
      let apiUrl = '/api/users/logs';
      const params = new URLSearchParams();

      if (dateRange.from) {
        params.append('startDate', dateRange.from.toISOString());
      }
      if (dateRange.to) {
        params.append('endDate', dateRange.to.toISOString());
      }
      if (phoneFilter) {
        params.append('phone', phoneFilter);
      }

      if (params.toString()) {
        apiUrl += `?${params.toString()}`;
      }

      const response = await fetch(apiUrl);
      if (!response.ok) {
        throw new Error('Failed to fetch logs');
      }
      const data = await response.json();
      setLogs(data);
    } catch (error) {
      console.error('Error fetching logs:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="space-y-4">
        <div className="h-8 w-[250px] animate-pulse rounded-md bg-gray-200" />
        <div className="h-[400px] animate-pulse rounded-md bg-gray-200" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
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

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>User</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Details</TableHead>
              <TableHead>Old Value</TableHead>
              <TableHead>New Value</TableHead>
              <TableHead>Changed By</TableHead>
              <TableHead>Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {logs.map((log) => (
              <TableRow key={log.id}>
                <TableCell>
                  <div>
                    <div className="font-medium">{log.user.name}</div>
                    <div className="text-sm text-gray-500">{log.user.email}</div>
                  </div>
                </TableCell>
                <TableCell>{log.user.phone}</TableCell>
                <TableCell>
                  <Badge variant="outline">{log.type}</Badge>
                </TableCell>
                <TableCell>{log.details}</TableCell>
                <TableCell>{log.oldValue || '-'}</TableCell>
                <TableCell>{log.newValue || '-'}</TableCell>
                <TableCell>
                  <div>
                    <div className="font-medium">{log.changedBy.name}</div>
                    <div className="text-sm text-gray-500">{log.changedBy.email}</div>
                  </div>
                </TableCell>
                <TableCell>
                  {format(new Date(log.createdAt), 'MMM d, yyyy HH:mm')}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
} 
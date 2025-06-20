'use client';

import { ColumnDef } from '@tanstack/react-table';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import Link from 'next/link';
import { Eye, Check, ArrowUpDown } from 'lucide-react';
import { Badge } from "@/components/ui/badge";
import { format } from 'date-fns';

export type DriverRequest = {
  id: string;
  fullName: string;
  phoneNumber: string;
  status: string;
  role: string;
  province: string;
  createdAt: Date;
};

export const columns: ColumnDef<DriverRequest>[] = [
  {
    accessorKey: 'fullName',
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
        >
          Name
          <ArrowUpDown className="ml-2 h-4 w-4" />
        </Button>
      );
    },
  },
  {
    accessorKey: 'phoneNumber',
    header: 'Phone',
  },
  {
    accessorKey: 'province',
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
        >
          Province
          <ArrowUpDown className="ml-2 h-4 w-4" />
        </Button>
      );
    },
  },
  {
    accessorKey: 'status',
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
        >
          Status
          <ArrowUpDown className="ml-2 h-4 w-4" />
        </Button>
      );
    },
    cell: ({ row }) => {
      const status = row.getValue('status') as string;
      return (
        <Badge
          variant={
            status === 'ACTIVE'
              ? 'default'
              : status === 'PENDING'
              ? 'secondary'
              : 'destructive'
          }
        >
          {status.toLowerCase()}
        </Badge>
      );
    },
  },
  {
    accessorKey: 'createdAt',
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
        >
          Created At
          <ArrowUpDown className="ml-2 h-4 w-4" />
        </Button>
      );
    },
    cell: ({ row }) => {
      return format(new Date(row.getValue('createdAt')), 'PPP');
    },
  },
  {
    id: 'actions',
    cell: ({ row }) => {
      const request = row.original;

      return (
        <Link href={`/driver-requests/${request.id}`}>
          <Button variant="ghost" size="sm">
            View
          </Button>
        </Link>
      );
    },
  },
];
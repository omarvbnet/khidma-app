"use client";

import { ColumnDef } from "@tanstack/react-table";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { DataTableColumnHeader } from "@/components/data-table-column-header";
import { DataTableRowActions } from "@/components/data-table-row-actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useState } from "react";
import { toast } from "sonner";
import { Eye } from "lucide-react";
import { useRouter } from "next/navigation";

export interface Driver {
  id: string;
  fullName: string;
  phoneNumber: string;
  status: string;
  role: string;
  province: string;
  createdAt: Date;
}

export const columns: ColumnDef<Driver>[] = [
  {
    id: "select",
    header: ({ table }) => (
      <Checkbox
        checked={table.getIsAllPageRowsSelected()}
        onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        aria-label="Select all"
        className="translate-y-[2px]"
      />
    ),
    cell: ({ row }) => (
      <Checkbox
        checked={row.getIsSelected()}
        onCheckedChange={(value) => row.toggleSelected(!!value)}
        aria-label="Select row"
        className="translate-y-[2px]"
      />
    ),
    enableSorting: false,
    enableHiding: false,
  },
  {
    accessorKey: "fullName",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Name" />
    ),
  },
  {
    accessorKey: "phoneNumber",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Phone" />
    ),
  },
  {
    accessorKey: "status",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Status" />
    ),
    cell: ({ row }) => {
      const status = row.getValue("status") as string;

      return (
        <Badge
          variant={
            status === "ACTIVE"
              ? "default"
              : status === "PENDING"
              ? "secondary"
              : "destructive"
          }
        >
          {status}
        </Badge>
      );
    },
    filterFn: (row, id, value) => {
      const status = row.getValue(id) as string;
      return value.includes(status);
    },
  },
  {
    accessorKey: "role",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Role" />
    ),
    cell: ({ row }) => {
      const role = row.getValue("role") as string;
      return (
        <Badge
          variant={
            role === "ADMIN"
              ? "default"
              : role === "DRIVER"
              ? "secondary"
              : "outline"
          }
        >
          {role.toLowerCase()}
        </Badge>
      );
    },
  },
  {
    accessorKey: "province",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Province" />
    ),
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const router = useRouter();

      return (
        <div className="flex items-center gap-2">
          <Button
            onClick={() => router.push(`/drivers/${row.original.id}`)}
            variant="outline"
            size="sm"
          >
            <Eye className="h-4 w-4 mr-2" />
            View
          </Button>
          <DataTableRowActions row={row} />
        </div>
      );
    },
  },
]; 
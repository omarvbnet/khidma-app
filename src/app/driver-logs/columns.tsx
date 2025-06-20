"use client";

import { ColumnDef } from "@tanstack/react-table";
import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";

interface DriverLog {
  id: string;
  driverId: string;
  type: string;
  details: string;
  oldValue: string | null;
  newValue: string | null;
  createdAt: string;
  driver: {
    name: string;
    phone: string | null;
  };
  changedBy: {
    name: string;
    email: string;
  };
}

export const columns: ColumnDef<DriverLog, unknown>[] = [
  {
    accessorKey: "driver.name",
    header: "Driver Name",
  },
  {
    accessorKey: "driver.phone",
    header: "Driver Phone",
    cell: ({ row }) => {
      const phone = row.original.driver.phone;
      return phone || "N/A";
    },
  },
  {
    accessorKey: "type",
    header: "Type",
    cell: ({ row }) => {
      const type = row.getValue("type") as string;
      return (
        <Badge variant={type === "BUDGET_UPDATE" ? "default" : "secondary"}>
          {type}
        </Badge>
      );
    },
  },
  {
    accessorKey: "details",
    header: "Details",
  },
  {
    accessorKey: "oldValue",
    header: "Old Value",
    cell: ({ row }) => {
      const oldValue = row.getValue("oldValue") as string | null;
      return oldValue ? `IQD ${oldValue}` : "-";
    },
  },
  {
    accessorKey: "newValue",
    header: "New Value",
    cell: ({ row }) => {
      const newValue = row.getValue("newValue") as string | null;
      return newValue ? `IQD ${newValue}` : "-";
    },
  },
  {
    accessorKey: "changedBy",
    header: "Changed By",
    cell: ({ row }) => {
      const changedBy = row.original.changedBy;
      return (
        <div>
          <div className="font-medium">{changedBy.name}</div>
          <div className="text-sm text-gray-500">{changedBy.email}</div>
        </div>
      );
    },
  },
  {
    accessorKey: "createdAt",
    header: "Date",
    cell: ({ row }) => {
      const date = new Date(row.getValue("createdAt"));
      return format(date, "PPp");
    },
  },
]; 
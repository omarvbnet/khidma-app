"use client";

import { ColumnDef } from "@tanstack/react-table";
import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";

interface DriverLog {
  id: string;
  driverId: string;
  action: string;
  details: string | null;
  createdAt: string;
  driver: {
    fullName: string;
    phoneNumber: string;
  };
}

export const columns: ColumnDef<DriverLog, unknown>[] = [
  {
    accessorKey: "driver.fullName",
    header: "Driver Name",
  },
  {
    accessorKey: "driver.phoneNumber",
    header: "Driver Phone",
  },
  {
    accessorKey: "action",
    header: "Action",
    cell: ({ row }) => {
      const action = row.getValue("action") as string;
      return (
        <Badge variant="secondary">
          {action}
        </Badge>
      );
    },
  },
  {
    accessorKey: "details",
    header: "Details",
    cell: ({ row }) => {
      const details = row.getValue("details") as string | null;
      return details || "-";
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
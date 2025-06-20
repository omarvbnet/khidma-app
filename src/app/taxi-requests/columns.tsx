import { ColumnDef } from "@tanstack/react-table";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { DataTableColumnHeader } from "@/components/data-table-column-header";
import { DataTableRowActions } from "@/components/data-table-row-actions";
import { format } from "date-fns";

export type TaxiRequest = {
  id: string;
  userId: string;
  userName: string;
  userPhone: string;
  pickupLocation: string;
  dropoffLocation: string;
  status: string;
  province: string;
  createdAt: Date;
};

export const columns: ColumnDef<TaxiRequest>[] = [
  {
    id: "select",
    header: ({ table }) => (
      <Checkbox
        checked={
          table.getIsAllPageRowsSelected() ||
          (table.getIsSomePageRowsSelected() && "indeterminate")
        }
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
    accessorKey: "userName",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="User Name" />
    ),
  },
  {
    accessorKey: "userPhone",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Phone" />
    ),
  },
  {
    accessorKey: "pickupLocation",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Pickup" />
    ),
  },
  {
    accessorKey: "dropoffLocation",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Dropoff" />
    ),
  },
  {
    accessorKey: "province",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Province" />
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
            status === "COMPLETED"
              ? "success"
              : status === "CANCELLED"
              ? "destructive"
              : "default"
          }
        >
          {status}
        </Badge>
      );
    },
  },
  {
    accessorKey: "createdAt",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Created At" />
    ),
    cell: ({ row }) => {
      const date = row.getValue("createdAt") as Date;
      return format(date, "MMM d, yyyy HH:mm");
    },
  },
  {
    id: "actions",
    cell: ({ row }) => <DataTableRowActions row={row} />,
  },
]; 
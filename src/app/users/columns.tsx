import { ColumnDef } from "@tanstack/react-table";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { DataTableColumnHeader } from "@/components/data-table-column-header";
import { DataTableRowActions } from "@/components/data-table-row-actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useState } from "react";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { UserStatus } from "@prisma/client";

export type User = {
  id: string;
  fullName: string;
  phoneNumber: string;
  status: UserStatus;
  role: string;
  province: string;
  budget: number;
  createdAt: Date;
};

export const columns: ColumnDef<User>[] = [
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
    accessorKey: "fullName",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Name" />
    ),
  },
  {
    accessorKey: "email",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Email" />
    ),
  },
  {
    accessorKey: "phoneNumber",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Phone" />
    ),
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
    accessorKey: "status",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Status" />
    ),
    cell: ({ row, table }) => {
      const status = row.getValue("status") as UserStatus;
      const [isUpdating, setIsUpdating] = useState(false);
      const router = useRouter();

      const handleStatusChange = async (newStatus: UserStatus) => {
        setIsUpdating(true);
        try {
          const response = await fetch(`/api/users/${row.original.id}/status`, {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ status: newStatus }),
          });

          if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to update status');
          }

          toast.success('Status updated successfully');
          // Refresh the page to show updated data
          router.refresh();
        } catch (error) {
          console.error('Error updating status:', error);
          toast.error(error instanceof Error ? error.message : 'Failed to update status');
        } finally {
          setIsUpdating(false);
        }
      };

      return (
        <Select
          value={status}
          onValueChange={handleStatusChange}
          disabled={isUpdating}
        >
          <SelectTrigger className="w-[130px]">
            <SelectValue placeholder="Select status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value={UserStatus.ACTIVE}>Active</SelectItem>
            <SelectItem value={UserStatus.SUSPENDED}>Suspended</SelectItem>
            <SelectItem value={UserStatus.PENDING}>Pending</SelectItem>
            <SelectItem value={UserStatus.BLOCKED}>Blocked</SelectItem>
          </SelectContent>
        </Select>
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
    accessorKey: "budget",
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Budget" />
    ),
    cell: ({ row, table }) => {
      const budget = row.getValue("budget") as number | undefined;
      const [isEditing, setIsEditing] = useState(false);
      const [newBudget, setNewBudget] = useState(budget?.toString() ?? '0');
      const [isUpdating, setIsUpdating] = useState(false);
      const router = useRouter();

      const handleUpdateBudget = async () => {
        setIsUpdating(true);
        try {
          const response = await fetch(`/api/users/${row.original.id}/budget`, {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ budget: parseFloat(newBudget) }),
          });

          if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to update budget');
          }

          setIsEditing(false);
          toast.success('Budget updated successfully');
          // Refresh the page to show updated data
          router.refresh();
        } catch (error) {
          console.error('Error updating budget:', error);
          toast.error(error instanceof Error ? error.message : 'Failed to update budget');
        } finally {
          setIsUpdating(false);
        }
      };

      if (isEditing) {
        return (
          <div className="flex items-center gap-2">
            <Input
              type="number"
              value={newBudget}
              onChange={(e) => setNewBudget(e.target.value)}
              className="w-32"
              disabled={isUpdating}
            />
            <Button
              size="sm"
              onClick={handleUpdateBudget}
              disabled={isUpdating}
            >
              {isUpdating ? 'Updating...' : 'Save'}
            </Button>
            <Button
              size="sm"
              variant="outline"
              onClick={() => {
                setIsEditing(false);
                setNewBudget(budget?.toString() ?? '0');
              }}
              disabled={isUpdating}
            >
              Cancel
            </Button>
          </div>
        );
      }

      return (
        <div className="flex items-center gap-2">
          <span className="font-medium">
            {(budget ?? 0).toLocaleString('en-US', {
              style: 'currency',
              currency: 'IQD'
            })}
          </span>
          <Button
            size="sm"
            variant="outline"
            onClick={() => setIsEditing(true)}
          >
            Update
          </Button>
        </div>
      );
    },
  },
  {
    id: "actions",
    cell: ({ row }) => <DataTableRowActions row={row} />,
  },
]; 
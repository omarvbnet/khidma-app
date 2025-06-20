'use client';

import { useEffect, useState } from "react";
import { DataTable } from "@/components/data-table";
import { columns } from "./columns";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { toast } from "sonner";
import { useRouter } from "next/navigation";

interface Driver {
  id: string;
  fullName: string;
  phoneNumber: string;
  status: string;
  role: string;
  province: string;
  createdAt: Date;
}

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState<string>("all");
  const router = useRouter();

  useEffect(() => {
    const fetchDrivers = async () => {
      try {
        const response = await fetch("/api/drivers");
        if (!response.ok) {
          throw new Error("Failed to fetch drivers");
        }
        const data = await response.json();
        setDrivers(data);
      } catch (error) {
        console.error("Error fetching drivers:", error);
        toast.error("Failed to fetch drivers");
      } finally {
        setLoading(false);
      }
    };

    fetchDrivers();
  }, []);

  const filteredDrivers = drivers.filter((driver) => {
    const matchesQuery = query
      ? driver.fullName.toLowerCase().includes(query.toLowerCase()) ||
        driver.phoneNumber?.toLowerCase().includes(query.toLowerCase())
      : true;

    const matchesStatus = status === "all" ? true : driver.status === status;

    return matchesQuery && matchesStatus;
  });

  return (
    <div className="container mx-auto py-10">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Drivers</h1>
        <Button onClick={() => router.push("/driver-logs")}>
          View Driver Logs
        </Button>
      </div>

      <div className="flex gap-4 mb-6">
        <Input
          placeholder="Search drivers..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="max-w-sm"
        />
        <Select
          value={status}
          onValueChange={(value) => setStatus(value)}
        >
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All</SelectItem>
            <SelectItem value="ACTIVE">Active</SelectItem>
            <SelectItem value="PENDING">Pending</SelectItem>
            <SelectItem value="SUSPENDED">Suspended</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <DataTable
        columns={columns}
        data={filteredDrivers}
        loading={loading}
        query={query}
        status={status}
      />
    </div>
  );
} 
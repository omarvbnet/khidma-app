"use client";

import { useEffect, useState } from "react";
import { DataTable } from "@/components/data-table";
import { columns } from "./columns";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { DatePickerWithRange } from "@/components/date-range-picker";
import { addDays } from "date-fns";
import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { DateRange } from "react-day-picker";

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

export default function DriverLogsPage() {
  const [logs, setLogs] = useState<DriverLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [dateRange, setDateRange] = useState<DateRange>({
    from: addDays(new Date(), -7),
    to: new Date(),
  });
  const router = useRouter();

  useEffect(() => {
    fetchLogs();
  }, [dateRange]);

  const fetchLogs = async () => {
    try {
      const response = await fetch(
        `/api/driver-logs?startDate=${dateRange.from?.toISOString()}&endDate=${dateRange.to?.toISOString()}`
      );
      const data = await response.json();
      setLogs(data);
    } catch (error) {
      console.error("Error fetching logs:", error);
    } finally {
      setLoading(false);
    }
  };

  const filteredLogs = logs.filter((log) => {
    const matchesQuery = query
      ? log.driver.fullName.toLowerCase().includes(query.toLowerCase()) ||
        log.driver.phoneNumber.toLowerCase().includes(query.toLowerCase()) ||
        (log.details?.toLowerCase().includes(query.toLowerCase()) || false)
      : true;

    return matchesQuery;
  });

  return (
    <div className="container mx-auto py-10">
      <div className="flex justify-between items-center mb-8">
        <div className="flex items-center gap-4">
          <Button
            variant="outline"
            size="icon"
            onClick={() => router.push("/drivers")}
          >
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <h1 className="text-3xl font-bold">Driver Logs</h1>
        </div>
      </div>

      <div className="flex items-center gap-4 mb-8">
        <Input
          placeholder="Search logs..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="max-w-sm"
        />
        <DatePickerWithRange
          date={dateRange}
          onDateChange={setDateRange}
        />
      </div>

      <DataTable
        columns={columns}
        data={filteredLogs}
        loading={loading}
        query={query}
      />
    </div>
  );
} 
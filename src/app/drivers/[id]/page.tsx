"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Car, User, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

interface Driver {
  id: string;
  fullName: string;
  phoneNumber: string;
  status: string;
  role: string;
  province: string;
  createdAt: string;
  carId?: string;
  carType?: string;
  licenseId?: string;
  rate: number;
  averageRate: number;
}

export default function DriverDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const [driver, setDriver] = useState<Driver | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDriver = async () => {
      try {
        const response = await fetch(`/api/drivers/${params.id}`);
        if (!response.ok) throw new Error("Failed to fetch driver");
        const data = await response.json();
        setDriver(data);
      } catch (error) {
        console.error("Error fetching driver:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchDriver();
  }, [params.id]);

  if (loading) {
    return (
      <div className="container mx-auto py-10">
        <div className="flex items-center gap-4 mb-8">
          <Skeleton className="h-10 w-10" />
          <Skeleton className="h-8 w-48" />
        </div>
        <div className="grid gap-6">
          <Skeleton className="h-[200px]" />
          <Skeleton className="h-[200px]" />
        </div>
      </div>
    );
  }

  if (!driver) {
    return (
      <div className="container mx-auto py-10">
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-4">Driver not found</h1>
          <Button onClick={() => router.push("/drivers")}>Back to Drivers</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-10">
      <div className="flex items-center gap-4 mb-8">
        <Button
          variant="outline"
          size="icon"
          onClick={() => router.push("/drivers")}
        >
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <h1 className="text-3xl font-bold">Driver Details</h1>
      </div>

      <div className="grid gap-6">
        {/* Personal Information */}
        <Card>
          <CardHeader className="flex flex-row items-center gap-2">
            <User className="h-5 w-5" />
            <CardTitle>Personal Information</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-muted-foreground">Name</p>
                <p className="font-medium">{driver.fullName}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Phone</p>
                <p className="font-medium">{driver.phoneNumber || "Not provided"}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Province</p>
                <p className="font-medium">{driver.province || "Not provided"}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Status</p>
                <p className="font-medium capitalize">{driver.status.toLowerCase()}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Member Since</p>
                <p className="font-medium">
                  {new Date(driver.createdAt).toLocaleDateString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Car Information */}
        <Card>
          <CardHeader className="flex flex-row items-center gap-2">
            <Car className="h-5 w-5" />
            <CardTitle>Car Information</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-muted-foreground">Car ID</p>
                <p className="font-medium">{driver.carId || "Not provided"}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Car Type</p>
                <p className="font-medium">{driver.carType || "Not provided"}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">License ID</p>
                <p className="font-medium">{driver.licenseId || "Not provided"}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Performance */}
        <Card>
          <CardHeader className="flex flex-row items-center gap-2">
            <Star className="h-5 w-5" />
            <CardTitle>Performance</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-muted-foreground">Driver Rate</p>
                <p className="font-medium">{driver.rate || 0}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Average Rating</p>
                <p className="font-medium">{driver.averageRate.toFixed(1)}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
} 
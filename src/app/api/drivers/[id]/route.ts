import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { parse } from 'cookie';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    // Get session from cookie
    const cookie = request.headers.get('cookie');
    if (!cookie) {
      return new NextResponse("Unauthorized", { status: 401 });
    }

    const cookies = parse(cookie);
    if (!cookies.session) {
      return new NextResponse("Unauthorized", { status: 401 });
    }

    const session = JSON.parse(cookies.session);
    if (!session || !session.role) {
      return new NextResponse("Unauthorized", { status: 401 });
    }

    // Check if user is either ADMIN or the driver themselves
    if (session.role !== 'ADMIN' && session.id !== id) {
      return new NextResponse("Unauthorized", { status: 401 });
    }

    const driver = await prisma.user.findUnique({
      where: {
        id: id,
        role: "DRIVER",
      },
      include: {
        driver: {
          select: {
            carId: true,
            carType: true,
            licenseId: true,
            rate: true,
          }
        }
      },
    });

    if (!driver) {
      return new NextResponse("Driver not found", { status: 404 });
    }

    // Calculate average rate from completed trips
    const completedTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: id,
        status: "TRIP_COMPLETED",
        driverRate: {
          not: null,
        },
      },
      select: {
        driverRate: true,
      },
    });

    const averageRate =
      completedTrips.length > 0
        ? completedTrips.reduce((acc, trip) => acc + (trip.driverRate || 0), 0) /
          completedTrips.length
        : 0;

    return NextResponse.json({
      id: driver.id,
      fullName: driver.fullName,
      phoneNumber: driver.phoneNumber,
      status: driver.status,
      role: driver.role,
      province: driver.province,
      createdAt: driver.createdAt,
      carId: driver.driver?.carId || null,
      carType: driver.driver?.carType || null,
      licenseId: driver.driver?.licenseId || null,
      rate: driver.driver?.rate || 0,
      averageRate,
    });
  } catch (error) {
    console.error("[DRIVER_GET]", error);
    return new NextResponse("Internal error", { status: 500 });
  }
}

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { status } = await request.json();

    // Get session from cookie
    const cookie = request.headers.get('cookie');
    if (!cookie) {
      return NextResponse.json(
        { error: 'Unauthorized - No session' },
        { status: 401 }
      );
    }

    const cookies = parse(cookie);
    if (!cookies.session) {
      return NextResponse.json(
        { error: 'Unauthorized - No session' },
        { status: 401 }
      );
    }

    const session = JSON.parse(cookies.session);
    if (!session?.id) {
      return NextResponse.json(
        { error: 'Unauthorized - Invalid session' },
        { status: 401 }
      );
    }

    // Update driver's status
    const updatedDriver = await prisma.user.update({
      where: { id: id },
      data: { 
        status: status || "ACTIVE"
      },
    });

    // Create a log entry for the status update
    await prisma.driverLog.create({
      data: {
        driverId: id,
        action: "STATUS_UPDATE",
        details: `Status updated to ${status}`,
      },
    });

    return NextResponse.json(updatedDriver);
  } catch (error) {
    console.error("Error updating driver:", error);
    return NextResponse.json(
      { error: "Failed to update driver" },
      { status: 500 }
    );
  }
} 
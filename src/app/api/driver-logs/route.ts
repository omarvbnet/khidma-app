import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const startDate = searchParams.get("startDate");
    const endDate = searchParams.get("endDate");

    const logs = await prisma.driverLog.findMany({
      where: {
        createdAt: {
          gte: startDate ? new Date(startDate) : undefined,
          lte: endDate ? new Date(endDate) : undefined,
        },
      },
      include: {
        driver: {
          select: {
            user: {
              select: {
                fullName: true,
                phoneNumber: true,
          },
        },
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return NextResponse.json(logs);
  } catch (error) {
    console.error("Error fetching driver logs:", error);
    return NextResponse.json(
      { error: "Failed to fetch driver logs" },
      { status: 500 }
    );
  }
} 
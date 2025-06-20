-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN', 'DRIVER');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('PENDING', 'ACTIVE', 'SUSPENDED', 'BLOCKED');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TaxiRequest_status" AS ENUM ('USER_WAITING', 'DRIVER_ACCEPTED', 'DRIVER_IN_WAY', 'DRIVER_ARRIVED', 'USER_PICKED_UP', 'DRIVER_IN_PROGRESS');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "province" TEXT NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'USER',

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Driver" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "carId" TEXT NOT NULL,
    "carType" TEXT NOT NULL,
    "licenseId" TEXT NOT NULL,
    "rate" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "Driver_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Order" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "status" "OrderStatus" NOT NULL DEFAULT 'PENDING',
    "total" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Product" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Product_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaxiRequest" (
    "id" TEXT NOT NULL,
    "status" "TaxiRequest_status" NOT NULL DEFAULT 'USER_WAITING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "acceptedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "userId" TEXT NOT NULL,
    "driverId" TEXT,
    "pickupLocation" TEXT NOT NULL,
    "dropoffLocation" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "distance" DOUBLE PRECISION NOT NULL,
    "userFullName" TEXT NOT NULL,
    "userPhone" TEXT NOT NULL,
    "userProvince" TEXT NOT NULL,
    "tripType" TEXT NOT NULL DEFAULT 'ECO',
    "driverDeduction" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "driverPhone" TEXT,
    "driverName" TEXT,
    "carId" TEXT,
    "carType" TEXT,
    "licenseId" TEXT,
    "driverRate" DOUBLE PRECISION,
    "dropoffLat" DOUBLE PRECISION NOT NULL,
    "dropoffLng" DOUBLE PRECISION NOT NULL,
    "pickupLat" DOUBLE PRECISION NOT NULL,
    "pickupLng" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "TaxiRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DriverLog" (
    "id" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "details" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DriverLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "details" TEXT NOT NULL,
    "oldValue" TEXT,
    "newValue" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "changedById" TEXT NOT NULL,

    CONSTRAINT "UserLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_phoneNumber_key" ON "User"("phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Driver_userId_key" ON "Driver"("userId");

-- AddForeignKey
ALTER TABLE "Driver" ADD CONSTRAINT "Driver_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaxiRequest" ADD CONSTRAINT "TaxiRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaxiRequest" ADD CONSTRAINT "TaxiRequest_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DriverLog" ADD CONSTRAINT "DriverLog_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserLog" ADD CONSTRAINT "UserLog_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserLog" ADD CONSTRAINT "UserLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function updateTaxiRequestStatus() {
  try {
    // Update PENDING to WAITING
    await prisma.$executeRaw`
      UPDATE TaxiRequest 
      SET status = 'WAITING' 
      WHERE status = 'PENDING'
    `;

    // Update CONFIRMED to IN_WAY
    await prisma.$executeRaw`
      UPDATE TaxiRequest 
      SET status = 'IN_WAY' 
      WHERE status = 'CONFIRMED'
    `;

    // Update COMPLETED to ARRIVED
    await prisma.$executeRaw`
      UPDATE TaxiRequest 
      SET status = 'ARRIVED' 
      WHERE status = 'COMPLETED'
    `;

    // Update CANCELLED to CHECK_OUT
    await prisma.$executeRaw`
      UPDATE TaxiRequest 
      SET status = 'CHECK_OUT' 
      WHERE status = 'CANCELLED'
    `;

    console.log('Successfully updated taxi request statuses');
  } catch (error) {
    console.error('Error updating taxi request statuses:', error);
  } finally {
    await prisma.$disconnect();
  }
}

updateTaxiRequestStatus(); 
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testTripStatus() {
  try {
    console.log('Testing TRIP_COMPLETED status...');
    
    // First, let's check what statuses are available
    console.log('Available TaxiRequest_status values:');
    const statuses = await prisma.$queryRaw`
      SELECT unnest(enum_range(NULL::"TaxiRequest_status")) as status;
    `;
    console.log(statuses);
    
    // Get an existing user
    const existingUser = await prisma.user.findFirst();
    if (!existingUser) {
      console.log('❌ No users found in database');
      return;
    }
    
    console.log('Using existing user:', existingUser.id);
    
    // Try to create a test taxi request with TRIP_COMPLETED status
    const testRequest = await prisma.taxiRequest.create({
      data: {
        userId: existingUser.id,
        pickupLocation: 'Test Pickup',
        dropoffLocation: 'Test Dropoff',
        price: 1000,
        distance: 5.0,
        userFullName: 'Test User',
        userPhone: '+1234567890',
        userProvince: 'Test Province',
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        dropoffLat: 33.3152,
        dropoffLng: 44.3661,
        status: 'TRIP_COMPLETED',
        completedAt: new Date(),
      },
    });
    
    console.log('✅ Successfully created taxi request with TRIP_COMPLETED status:');
    console.log('ID:', testRequest.id);
    console.log('Status:', testRequest.status);
    console.log('Completed At:', testRequest.completedAt);
    
    // Clean up - delete the test request
    await prisma.taxiRequest.delete({
      where: { id: testRequest.id },
    });
    console.log('✅ Test request cleaned up');
    
  } catch (error) {
    console.error('❌ Error testing TRIP_COMPLETED status:', error);
  } finally {
    await prisma.$disconnect();
  }
}

testTripStatus(); 
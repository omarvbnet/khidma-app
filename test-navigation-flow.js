const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testNavigationFlow() {
  try {
    console.log('Testing trip acceptance navigation flow...');
    
    // Get an existing user
    const existingUser = await prisma.user.findFirst();
    if (!existingUser) {
      console.log('❌ No users found in database');
      return;
    }
    
    console.log('Using existing user:', existingUser.id);
    
    // Create a driver profile for the user
    const driver = await prisma.driver.create({
      data: {
        fullName: 'Test Driver',
        phoneNumber: '+1234567890',
        carId: 'TEST123',
        carType: 'Sedan',
        licenseId: 'LICENSE123',
        rate: 4.5,
        userId: existingUser.id,
      },
    });
    
    console.log('Created driver profile:', driver.id);
    
    // Create a taxi request with USER_WAITING status
    const taxiRequest = await prisma.taxiRequest.create({
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
        status: 'USER_WAITING',
      },
    });
    
    console.log('✅ Created taxi request with USER_WAITING status:');
    console.log('ID:', taxiRequest.id);
    console.log('Status:', taxiRequest.status);
    
    // Simulate driver accepting the trip
    const updatedRequest = await prisma.taxiRequest.update({
      where: { id: taxiRequest.id },
      data: { 
        status: 'DRIVER_ACCEPTED',
        updatedAt: new Date(),
        acceptedAt: new Date(),
        driverId: driver.id,
        driverName: driver.fullName,
        driverPhone: driver.phoneNumber,
        carId: driver.carId,
        carType: driver.carType,
        licenseId: driver.licenseId,
        driverRate: driver.rate,
      },
    });
    
    console.log('✅ Successfully accepted trip:');
    console.log('ID:', updatedRequest.id);
    console.log('Status:', updatedRequest.status);
    console.log('Driver ID:', updatedRequest.driverId);
    console.log('Accepted At:', updatedRequest.acceptedAt);
    
    // Now the DriverHomeScreen should:
    // 1. Load the current trip (which will be DRIVER_ACCEPTED)
    // 2. Show the DriverNavigationScreen for pickup
    console.log('\n📱 Expected Flutter App Behavior:');
    console.log('1. Driver accepts trip → Status becomes DRIVER_ACCEPTED');
    console.log('2. App navigates to DriverHomeScreen');
    console.log('3. DriverHomeScreen loads current trip (DRIVER_ACCEPTED)');
    console.log('4. DriverHomeScreen shows DriverNavigationScreen for pickup');
    
    // Clean up
    await prisma.taxiRequest.delete({
      where: { id: taxiRequest.id },
    });
    await prisma.driver.delete({
      where: { id: driver.id },
    });
    console.log('✅ Test data cleaned up');
    
  } catch (error) {
    console.error('❌ Error testing navigation flow:', error);
  } finally {
    await prisma.$disconnect();
  }
}

testNavigationFlow(); 
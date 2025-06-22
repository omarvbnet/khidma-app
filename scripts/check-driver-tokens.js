const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function checkDriverTokens() {
  console.log('\n=== CHECKING DRIVER DEVICE TOKENS ===\n');

  try {
    // 1. Get all users with DRIVER role
    console.log('1. CHECKING ALL DRIVER USERS...');
    const driverUsers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      include: { driver: true }
    });
    
    console.log(`   Total driver users: ${driverUsers.length}`);

    // 2. Check device tokens for each driver
    console.log('\n2. CHECKING DEVICE TOKENS...');
    const driversWithTokens = [];
    const driversWithoutTokens = [];
    
    for (const driver of driverUsers) {
      const hasToken = !!driver.deviceToken;
      const tokenPreview = driver.deviceToken ? 
        `${driver.deviceToken.substring(0, 20)}...` : 'None';
      
      console.log(`   ${driver.fullName} (${driver.id}):`);
      console.log(`     - Status: ${driver.status}`);
      console.log(`     - Has Token: ${hasToken}`);
      console.log(`     - Token: ${tokenPreview}`);
      console.log(`     - Platform: ${driver.platform || 'Unknown'}`);
      console.log(`     - App Version: ${driver.appVersion || 'Unknown'}`);
      
      if (hasToken) {
        driversWithTokens.push(driver);
      } else {
        driversWithoutTokens.push(driver);
      }
    }

    // 3. Check active drivers
    console.log('\n3. CHECKING ACTIVE DRIVERS...');
    const activeDrivers = driverUsers.filter(d => d.status === 'ACTIVE');
    const activeDriversWithTokens = activeDrivers.filter(d => !!d.deviceToken);
    
    console.log(`   Active drivers: ${activeDrivers.length}`);
    console.log(`   Active drivers with tokens: ${activeDriversWithTokens.length}`);

    // 4. Check driver availability
    console.log('\n4. CHECKING DRIVER AVAILABILITY...');
    const availableDrivers = [];
    
    for (const driver of activeDrivers) {
      const activeTrips = await prisma.taxiRequest.findMany({
        where: {
          driverId: driver.id,
          status: {
            in: [
              'DRIVER_ACCEPTED',
              'DRIVER_IN_WAY', 
              'DRIVER_ARRIVED',
              'USER_PICKED_UP',
              'DRIVER_IN_PROGRESS'
            ]
          }
        }
      });
      
      const isAvailable = activeTrips.length === 0;
      if (isAvailable) {
        availableDrivers.push(driver);
      }
      
      console.log(`   ${driver.fullName}: ${isAvailable ? 'Available' : 'Busy'} (${activeTrips.length} active trips)`);
    }

    const availableDriversWithTokens = availableDrivers.filter(d => !!d.deviceToken);
    
    console.log(`   Available drivers: ${availableDrivers.length}`);
    console.log(`   Available drivers with tokens: ${availableDriversWithTokens.length}`);

    // 5. Summary
    console.log('\n=== SUMMARY ===');
    console.log(`Total driver users: ${driverUsers.length}`);
    console.log(`Drivers with device tokens: ${driversWithTokens.length}`);
    console.log(`Drivers without device tokens: ${driversWithoutTokens.length}`);
    console.log(`Active drivers: ${activeDrivers.length}`);
    console.log(`Active drivers with tokens: ${activeDriversWithTokens.length}`);
    console.log(`Available drivers: ${availableDrivers.length}`);
    console.log(`Available drivers with tokens: ${availableDriversWithTokens.length}`);

    // 6. Recommendations
    console.log('\n=== RECOMMENDATIONS ===');
    
    if (driversWithoutTokens.length > 0) {
      console.log('❌ ISSUE FOUND: Some drivers don\'t have device tokens');
      console.log('   Drivers without tokens:');
      driversWithoutTokens.forEach(driver => {
        console.log(`   - ${driver.fullName} (${driver.id})`);
      });
      console.log('\n   SOLUTION: Drivers need to register their device tokens');
      console.log('   - Make sure drivers are logged into the app');
      console.log('   - Check if the app is requesting notification permissions');
      console.log('   - Verify the device token update API is being called');
    }
    
    if (availableDriversWithTokens.length === 0) {
      console.log('❌ ISSUE FOUND: No available drivers have device tokens');
      console.log('   SOLUTION: Drivers need to register their device tokens');
    }
    
    if (availableDriversWithTokens.length > 0) {
      console.log('✅ System should work: Available drivers with tokens found');
    }

    // 7. Test notification data
    if (availableDriversWithTokens.length > 0) {
      console.log('\n=== TEST NOTIFICATION DATA ===');
      const testDriver = availableDriversWithTokens[0];
      console.log(`Test driver: ${testDriver.fullName}`);
      console.log(`Device token: ${testDriver.deviceToken?.substring(0, 30)}...`);
      console.log(`Platform: ${testDriver.platform}`);
      console.log(`App version: ${testDriver.appVersion}`);
    }

  } catch (error) {
    console.error('Error checking driver tokens:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the check
checkDriverTokens(); 
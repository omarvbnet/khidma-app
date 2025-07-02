const { PrismaClient } = require('@prisma/client');
const axios = require('axios');

const prisma = new PrismaClient();

// Province mapping based on coordinates (simplified for Iraq)
function getProvinceFromCoordinates(lat, lng) {
  const latitude = parseFloat(lat);
  const longitude = parseFloat(lng);

  if (latitude >= 33.0 && latitude <= 34.0 && longitude >= 44.0 && longitude <= 45.0) {
    return 'Baghdad';
  } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 43.0 && longitude <= 44.0) {
    return 'Erbil';
  } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 42.0 && longitude <= 43.0) {
    return 'Duhok';
  } else if (latitude >= 35.0 && latitude <= 36.0 && longitude >= 45.0 && longitude <= 46.0) {
    return 'Sulaymaniyah';
  } else if (latitude >= 32.0 && latitude <= 33.0 && longitude >= 44.0 && longitude <= 45.0) {
    return 'Babil';
  } else if (latitude >= 31.0 && latitude <= 32.0 && longitude >= 44.0 && longitude <= 45.0) {
    return 'Karbala';
  } else if (latitude >= 32.0 && latitude <= 33.0 && longitude >= 45.0 && longitude <= 46.0) {
    return 'Wasit';
  } else if (latitude >= 30.0 && latitude <= 31.0 && longitude >= 47.0 && longitude <= 48.0) {
    return 'Basra';
  } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 37.0 && longitude <= 38.0) {
    return 'Aleppo';
  } else if (latitude >= 33.0 && latitude <= 34.0 && longitude >= 36.0 && longitude <= 37.0) {
    return 'Damascus';
  }

  return 'Baghdad'; // Default
}

async function checkAndUpdateUserProvinces() {
  try {
    console.log('\n🔄 Starting province check for all users...');
    
    // Get all active users
    const users = await prisma.user.findMany({
      where: {
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        role: true,
        province: true,
        lastKnownLatitude: true,
        lastKnownLongitude: true,
        lastLocationUpdate: true
      }
    });

    console.log(`Found ${users.length} active users to check`);

    let updatedCount = 0;
    let errorCount = 0;

    for (const user of users) {
      try {
        // Skip users without location data
        if (!user.lastKnownLatitude || !user.lastKnownLongitude) {
          console.log(`⚠️ User ${user.fullName} (${user.id}) has no location data`);
          continue;
        }

        // Check if location is recent (within last 30 minutes)
        const lastUpdate = user.lastLocationUpdate;
        if (lastUpdate) {
          const timeDiff = Date.now() - new Date(lastUpdate).getTime();
          const minutesDiff = timeDiff / (1000 * 60);
          
          if (minutesDiff > 30) {
            console.log(`⚠️ User ${user.fullName} (${user.id}) location is ${Math.round(minutesDiff)} minutes old`);
            continue;
          }
        }

        // Determine current province from coordinates
        const currentProvince = getProvinceFromCoordinates(
          user.lastKnownLatitude,
          user.lastKnownLongitude
        );

        // Update if province has changed
        if (currentProvince !== user.province) {
          console.log(`🔄 Updating user ${user.fullName} (${user.id}) province: ${user.province} → ${currentProvince}`);
          
          await prisma.user.update({
            where: { id: user.id },
            data: { province: currentProvince }
          });

          updatedCount++;

          // Log the change
          console.log(`✅ Updated user ${user.fullName} (${user.id}) province to ${currentProvince}`);
        } else {
          console.log(`✅ User ${user.fullName} (${user.id}) province unchanged: ${user.province}`);
        }
      } catch (error) {
        console.error(`❌ Error updating user ${user.fullName} (${user.id}):`, error.message);
        errorCount++;
      }
    }

    console.log(`\n📊 Province check completed:`);
    console.log(`  - Total users checked: ${users.length}`);
    console.log(`  - Users updated: ${updatedCount}`);
    console.log(`  - Errors: ${errorCount}`);

  } catch (error) {
    console.error('❌ Error in province check:', error);
  }
}

// Function to update user location (called from Flutter app)
async function updateUserLocation(userId, lat, lng) {
  try {
    const province = getProvinceFromCoordinates(lat, lng);
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        lastKnownLatitude: lat,
        lastKnownLongitude: lng,
        lastLocationUpdate: new Date(),
        province: province
      }
    });

    console.log(`📍 Updated user ${userId} location: (${lat}, ${lng}) → ${province}`);
    return { success: true, province };
  } catch (error) {
    console.error(`❌ Error updating user ${userId} location:`, error);
    return { success: false, error: error.message };
  }
}

// Start periodic checking every 2 minutes
function startPeriodicProvinceChecking() {
  console.log('🚀 Starting periodic province checking every 2 minutes...');
  
  // Run immediately
  checkAndUpdateUserProvinces();
  
  // Then run every 2 minutes
  setInterval(checkAndUpdateUserProvinces, 2 * 60 * 1000);
}

// Export functions for use in other scripts
module.exports = {
  checkAndUpdateUserProvinces,
  updateUserLocation,
  startPeriodicProvinceChecking,
  getProvinceFromCoordinates
};

// If this script is run directly, start the periodic checking
if (require.main === module) {
  startPeriodicProvinceChecking();
  
  // Handle graceful shutdown
  process.on('SIGINT', async () => {
    console.log('\n🛑 Shutting down province checking service...');
    await prisma.$disconnect();
    process.exit(0);
  });
} 
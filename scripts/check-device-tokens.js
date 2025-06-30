const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Helper function to validate device token format
function isValidDeviceToken(token) {
  if (!token || typeof token !== 'string') {
    return false;
  }
  
  // Basic validation for FCM token format
  // FCM tokens are typically 140+ characters and contain alphanumeric characters and some special chars
  if (token.length < 100) {
    return false;
  }
  
  // Check if token contains only valid characters
  const validTokenRegex = /^[A-Za-z0-9:_-]+$/;
  return validTokenRegex.test(token);
}

async function checkAndCleanupDeviceTokens() {
  try {
    console.log('\n=== CHECKING AND CLEANING UP DEVICE TOKENS ===\n');

    // Get all users with device tokens
    const usersWithTokens = await prisma.user.findMany({
      where: {
        deviceToken: {
          not: null
        }
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true,
        deviceToken: true,
        updatedAt: true
      }
    });

    console.log(`Found ${usersWithTokens.length} users with device tokens`);

    let validTokens = 0;
    let invalidTokens = 0;
    const usersToUpdate = [];

    // Check each token
    for (const user of usersWithTokens) {
      const isValid = isValidDeviceToken(user.deviceToken);
      
      if (isValid) {
        validTokens++;
        console.log(`✅ Valid token: ${user.fullName} (${user.id}) - ${user.deviceToken.substring(0, 20)}...`);
      } else {
        invalidTokens++;
        usersToUpdate.push(user.id);
        console.log(`❌ Invalid token: ${user.fullName} (${user.id}) - ${user.deviceToken.substring(0, 20)}...`);
      }
    }

    console.log(`\n📊 Token Analysis:`);
    console.log(`- Total users with tokens: ${usersWithTokens.length}`);
    console.log(`- Valid tokens: ${validTokens}`);
    console.log(`- Invalid tokens: ${invalidTokens}`);

    if (invalidTokens > 0) {
      console.log(`\n🧹 Cleaning up ${invalidTokens} invalid device tokens...`);
      
      // Update users to remove invalid device tokens
      const updateResult = await prisma.user.updateMany({
        where: {
          id: {
            in: usersToUpdate
          }
        },
        data: {
          deviceToken: null
        }
      });

      console.log(`✅ Successfully cleaned up ${updateResult.count} invalid device tokens`);
    } else {
      console.log(`\n✅ All device tokens are valid!`);
    }

    // Show summary of remaining valid tokens
    const remainingUsers = await prisma.user.findMany({
      where: {
        deviceToken: {
          not: null
        }
      },
      select: {
        id: true,
        fullName: true,
        role: true,
        deviceToken: true
      }
    });

    console.log(`\n📱 Remaining valid device tokens: ${remainingUsers.length}`);
    for (const user of remainingUsers) {
      console.log(`- ${user.fullName} (${user.role}) - ${user.deviceToken.substring(0, 20)}...`);
    }

  } catch (error) {
    console.error('❌ Error checking device tokens:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the script
checkAndCleanupDeviceTokens(); 
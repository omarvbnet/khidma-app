import { PrismaClient } from '@prisma/client';
import { sendPushNotification } from '../src/lib/firebase-admin';

const prisma = new PrismaClient();

async function testNotifications() {
  console.log('🧪 Testing notification system...');
  
  try {
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
        deviceToken: true,
        platform: true,
        role: true,
        status: true
      }
    });

    console.log(`📊 Found ${usersWithTokens.length} users with device tokens`);

    for (const user of usersWithTokens) {
      console.log(`\n🧪 Testing notification for ${user.fullName} (${user.phoneNumber})`);
      console.log(`   Role: ${user.role}, Platform: ${user.platform}, Status: ${user.status}`);
      console.log(`   Token: ${user.deviceToken?.substring(0, 30)}...`);
      
      try {
        // Test with a simple notification
        const result = await sendPushNotification({
          token: user.deviceToken!,
          title: 'Test Notification',
          body: 'This is a test notification to verify your device token is working.',
          data: {
            type: 'TEST',
            userId: user.id,
            timestamp: new Date().toISOString()
          }
        });
        
        console.log(`   ✅ SUCCESS: Notification sent successfully`);
        console.log(`   📱 Response:`, result);
      } catch (error: any) {
        console.log(`   ❌ FAILED: ${error.message}`);
        
        // Check if it's a token-related error
        if (error.message.includes('Requested entity was not found') ||
            error.message.includes('Invalid registration token') ||
            error.message.includes('Registration token is not valid') ||
            error.message.includes('Device token not found')) {
          
          console.log(`   🧹 This appears to be an invalid token - should be cleaned up`);
          
          // Clean up the invalid token
          try {
            await prisma.user.update({
              where: { id: user.id },
              data: { deviceToken: null }
            });
            console.log(`   ✅ Invalid token cleaned up for ${user.fullName}`);
          } catch (cleanupError: any) {
            console.log(`   ❌ Failed to clean up token: ${cleanupError.message}`);
          }
        }
      }
    }

    // Show final summary
    const remainingUsers = await prisma.user.findMany({
      where: {
        deviceToken: {
          not: null
        }
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true
      }
    });

    console.log(`\n📊 Final Summary: ${remainingUsers.length} users still have valid device tokens`);
    
    for (const user of remainingUsers) {
      console.log(`   - ${user.fullName} (${user.phoneNumber}) - ${user.role}`);
    }

  } catch (error) {
    console.error('❌ Error during notification testing:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the test
testNotifications()
  .then(() => {
    console.log('✅ Notification testing completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Notification testing failed:', error);
    process.exit(1);
  }); 
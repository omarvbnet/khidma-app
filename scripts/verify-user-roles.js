const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function verifyUserRoles() {
  console.log('🔍 Verifying user roles and device tokens...\n');

  try {
    // Get all users with device tokens
    const usersWithTokens = await prisma.user.findMany({
      where: {
        deviceToken: { not: null },
      },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        role: true,
        status: true,
        deviceToken: true,
        province: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    console.log(`📱 Found ${usersWithTokens.length} users with device tokens:\n`);

    // Group by device token to find duplicates
    const tokenGroups = {};
    usersWithTokens.forEach(user => {
      if (user.deviceToken) {
        if (!tokenGroups[user.deviceToken]) {
          tokenGroups[user.deviceToken] = [];
        }
        tokenGroups[user.deviceToken].push(user);
      }
    });

    // Check for duplicate device tokens
    const duplicateTokens = Object.entries(tokenGroups).filter(([token, users]) => users.length > 1);
    
    if (duplicateTokens.length > 0) {
      console.log('⚠️ Found duplicate device tokens:');
      duplicateTokens.forEach(([token, users]) => {
        console.log(`\n🔑 Token: ${token.substring(0, 20)}...`);
        users.forEach(user => {
          console.log(`  - ${user.fullName} (${user.id}) - Role: ${user.role} - Status: ${user.status}`);
        });
      });

      console.log('\n🧹 Cleaning up duplicate device tokens...');
      
      for (const [token, users] of duplicateTokens) {
        // Keep the most recent user with this token, clear others
        const sortedUsers = users.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        const keepUser = sortedUsers[0];
        const clearUsers = sortedUsers.slice(1);

        console.log(`\n✅ Keeping token for: ${keepUser.fullName} (${keepUser.id})`);
        
        for (const user of clearUsers) {
          console.log(`🗑️ Clearing token for: ${user.fullName} (${user.id})`);
          await prisma.user.update({
            where: { id: user.id },
            data: {
              deviceToken: null,
              platform: null,
              appVersion: null,
            },
          });
        }
      }
    } else {
      console.log('✅ No duplicate device tokens found');
    }

    // Verify role distribution
    const roleStats = await prisma.user.groupBy({
      by: ['role'],
      _count: { role: true },
      where: {
        deviceToken: { not: null },
      },
    });

    console.log('\n📊 Role distribution for users with device tokens:');
    roleStats.forEach(stat => {
      console.log(`  - ${stat.role}: ${stat._count.role} users`);
    });

    // Check for users with incorrect roles
    const usersWithIncorrectRoles = usersWithTokens.filter(user => {
      return !['USER', 'DRIVER', 'ADMIN'].includes(user.role);
    });

    if (usersWithIncorrectRoles.length > 0) {
      console.log('\n⚠️ Found users with incorrect roles:');
      usersWithIncorrectRoles.forEach(user => {
        console.log(`  - ${user.fullName} (${user.id}): ${user.role}`);
      });
    } else {
      console.log('\n✅ All users have valid roles');
    }

    // Check for users with null roles
    // Note: Role field is not nullable in schema, so this check is not needed
    console.log('\n✅ Role field is not nullable in schema - no null roles possible');

    console.log('\n✅ User role verification completed successfully!');

  } catch (error) {
    console.error('❌ Error verifying user roles:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the verification
verifyUserRoles(); 
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function checkNotificationDuplicates() {
  console.log('🔍 Checking for Notification Duplicates\n');

  try {
    // Get recent notifications (last 24 hours)
    const recentNotifications = await prisma.notification.findMany({
      where: {
        createdAt: {
          gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
        }
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            role: true,
            language: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    console.log(`📊 Found ${recentNotifications.length} notifications in the last 24 hours\n`);

    // Group notifications by user and type
    const groupedNotifications = {};
    
    recentNotifications.forEach(notification => {
      const key = `${notification.userId}_${notification.type}`;
      if (!groupedNotifications[key]) {
        groupedNotifications[key] = [];
      }
      groupedNotifications[key].push(notification);
    });

    // Find duplicates (same user, same type, within 5 minutes)
    const duplicates = [];
    
    Object.entries(groupedNotifications).forEach(([key, notifications]) => {
      if (notifications.length > 1) {
        // Check for notifications within 5 minutes of each other
        for (let i = 0; i < notifications.length - 1; i++) {
          for (let j = i + 1; j < notifications.length; j++) {
            const timeDiff = Math.abs(
              new Date(notifications[i].createdAt) - new Date(notifications[j].createdAt)
            );
            
            if (timeDiff < 5 * 60 * 1000) { // 5 minutes
              duplicates.push({
                key,
                notifications: [notifications[i], notifications[j]],
                timeDiff: Math.round(timeDiff / 1000) // seconds
              });
            }
          }
        }
      }
    });

    if (duplicates.length === 0) {
      console.log('✅ No notification duplicates found!');
    } else {
      console.log(`❌ Found ${duplicates.length} potential duplicate notification groups:\n`);
      
      duplicates.forEach((duplicate, index) => {
        console.log(`\n${index + 1}. Duplicate Group: ${duplicate.key}`);
        console.log(`   Time difference: ${duplicate.timeDiff} seconds`);
        
        duplicate.notifications.forEach((notification, idx) => {
          console.log(`   ${idx + 1}. ID: ${notification.id}`);
          console.log(`      User: ${notification.user.fullName} (${notification.user.role})`);
          console.log(`      Type: ${notification.type}`);
          console.log(`      Title: ${notification.title}`);
          console.log(`      Created: ${notification.createdAt}`);
          console.log(`      Language: ${notification.user.language || 'not set'}`);
        });
      });
    }

    // Check for notification sources
    console.log('\n📋 Notification Sources Analysis:');
    
    const notificationTypes = {};
    recentNotifications.forEach(notification => {
      if (!notificationTypes[notification.type]) {
        notificationTypes[notification.type] = 0;
      }
      notificationTypes[notification.type]++;
    });

    Object.entries(notificationTypes).forEach(([type, count]) => {
      console.log(`   ${type}: ${count} notifications`);
    });

    // Check user language distribution
    console.log('\n🌍 User Language Distribution:');
    const languageCounts = {};
    recentNotifications.forEach(notification => {
      const lang = notification.user.language || 'not set';
      if (!languageCounts[lang]) {
        languageCounts[lang] = 0;
      }
      languageCounts[lang]++;
    });

    Object.entries(languageCounts).forEach(([lang, count]) => {
      console.log(`   ${lang}: ${count} notifications`);
    });

  } catch (error) {
    console.error('❌ Error checking notification duplicates:', error);
  }
}

async function main() {
  try {
    await checkNotificationDuplicates();
  } catch (error) {
    console.error('❌ Script failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main(); 
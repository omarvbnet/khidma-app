const axios = require('axios');

// Configuration
const API_BASE_URL = 'https://your-backend-url.vercel.app'; // Replace with your actual backend URL
const TEST_USER_ID = 'your-test-user-id'; // Replace with actual user ID

// Test notification payloads
const testNotifications = [
  {
    type: 'NEW_TRIP_AVAILABLE',
    title: 'New Trip Available!',
    message: 'A new trip request is waiting for you',
    data: {
      type: 'NEW_TRIP_AVAILABLE',
      screen: 'driver_waiting',
      timestamp: new Date().toISOString(),
    }
  },
  {
    type: 'NEW_TRIPS_AVAILABLE',
    title: 'Multiple Trips Available!',
    message: 'You have multiple trip requests waiting',
    data: {
      type: 'NEW_TRIPS_AVAILABLE',
      screen: 'driver_waiting',
      count: 3,
      timestamp: new Date().toISOString(),
    }
  },
  {
    type: 'trip_created',
    title: 'New Trip Request',
    message: 'A customer has requested a trip',
    data: {
      type: 'trip_created',
      screen: 'driver_waiting',
      timestamp: new Date().toISOString(),
    }
  }
];

async function sendTestNotification(notification) {
  try {
    console.log(`\n📤 Sending test notification: ${notification.type}`);
    console.log(`Title: ${notification.title}`);
    console.log(`Message: ${notification.message}`);
    
    const response = await axios.post(`${API_BASE_URL}/api/notifications/send`, {
      userId: TEST_USER_ID,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      data: notification.data
    }, {
      headers: {
        'Content-Type': 'application/json',
        // Add your auth token here if needed
        // 'Authorization': 'Bearer your-token'
      }
    });

    console.log(`✅ Notification sent successfully!`);
    console.log(`Response: ${response.status} - ${response.statusText}`);
    
    if (response.data) {
      console.log(`Response data:`, response.data);
    }
    
    return true;
  } catch (error) {
    console.error(`❌ Failed to send notification: ${notification.type}`);
    console.error(`Error: ${error.message}`);
    
    if (error.response) {
      console.error(`Response status: ${error.response.status}`);
      console.error(`Response data:`, error.response.data);
    }
    
    return false;
  }
}

async function testAllNotifications() {
  console.log('🧪 Testing Release Mode Notifications');
  console.log('=====================================');
  console.log(`API Base URL: ${API_BASE_URL}`);
  console.log(`Test User ID: ${TEST_USER_ID}`);
  console.log('');

  let successCount = 0;
  let totalCount = testNotifications.length;

  for (const notification of testNotifications) {
    const success = await sendTestNotification(notification);
    if (success) successCount++;
    
    // Wait 2 seconds between notifications
    await new Promise(resolve => setTimeout(resolve, 2000));
  }

  console.log('\n📊 Test Results');
  console.log('===============');
  console.log(`Total notifications sent: ${totalCount}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Failed: ${totalCount - successCount}`);
  console.log(`Success rate: ${((successCount / totalCount) * 100).toFixed(1)}%`);

  if (successCount === totalCount) {
    console.log('\n🎉 All notifications sent successfully!');
    console.log('Now test the app in release mode to see if background notifications work.');
  } else {
    console.log('\n⚠️ Some notifications failed. Check the backend configuration.');
  }
}

// Test specific notification type
async function testSpecificNotification(type) {
  const notification = testNotifications.find(n => n.type === type);
  if (notification) {
    await sendTestNotification(notification);
  } else {
    console.error(`❌ Notification type "${type}" not found`);
  }
}

// CLI interface
const args = process.argv.slice(2);
if (args.length > 0) {
  const command = args[0];
  
  switch (command) {
    case 'all':
      testAllNotifications();
      break;
    case 'trip':
      testSpecificNotification('NEW_TRIP_AVAILABLE');
      break;
    case 'trips':
      testSpecificNotification('NEW_TRIPS_AVAILABLE');
      break;
    case 'created':
      testSpecificNotification('trip_created');
      break;
    default:
      console.log('Usage:');
      console.log('  node test-release-notifications.js all     - Test all notification types');
      console.log('  node test-release-notifications.js trip    - Test single trip notification');
      console.log('  node test-release-notifications.js trips   - Test multiple trips notification');
      console.log('  node test-release-notifications.js created - Test trip created notification');
      break;
  }
} else {
  console.log('🧪 Release Mode Notification Tester');
  console.log('====================================');
  console.log('');
  console.log('Before running this script:');
  console.log('1. Update API_BASE_URL with your actual backend URL');
  console.log('2. Update TEST_USER_ID with an actual user ID');
  console.log('3. Add authentication token if required');
  console.log('4. Build and install the app in release mode');
  console.log('');
  console.log('Usage:');
  console.log('  node test-release-notifications.js all     - Test all notification types');
  console.log('  node test-release-notifications.js trip    - Test single trip notification');
  console.log('  node test-release-notifications.js trips   - Test multiple trips notification');
  console.log('  node test-release-notifications.js created - Test trip created notification');
}

module.exports = {
  sendTestNotification,
  testAllNotifications,
  testSpecificNotification
}; 
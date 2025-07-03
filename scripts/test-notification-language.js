const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testNotificationLanguage() {
  console.log('🧪 Testing Notification Language Detection\n');

  // Test users with different language settings
  const testUsers = [
    {
      id: 'test-user-1',
      language: 'en',
      phoneNumber: '+1234567890',
      description: 'English user with explicit language setting'
    },
    {
      id: 'test-user-2',
      language: 'ar',
      phoneNumber: '+964123456789',
      description: 'Arabic user with explicit language setting'
    },
    {
      id: 'test-user-3',
      language: 'ku',
      phoneNumber: '+964712345678',
      description: 'Kurdish user with explicit language setting'
    },
    {
      id: 'test-user-4',
      language: 'tr',
      phoneNumber: '+901234567890',
      description: 'Turkish user with explicit language setting'
    },
    {
      id: 'test-user-5',
      language: null,
      phoneNumber: '+964123456789',
      description: 'Iraqi user without language setting (should default to Arabic)'
    },
    {
      id: 'test-user-6',
      language: null,
      phoneNumber: '+964712345678',
      description: 'Kurdish region user without language setting (should default to Kurdish)'
    },
    {
      id: 'test-user-7',
      language: null,
      phoneNumber: '+1234567890',
      description: 'US user without language setting (should default to English)'
    }
  ];

  for (const testUser of testUsers) {
    console.log(`\n📱 Testing: ${testUser.description}`);
    console.log(`   User ID: ${testUser.id}`);
    console.log(`   Language: ${testUser.language || 'null'}`);
    console.log(`   Phone: ${testUser.phoneNumber}`);
    
    // Simulate the language detection logic
    let detectedLanguage = 'en'; // default
    
    if (testUser.language && typeof testUser.language === 'string') {
      const lang = testUser.language.toLowerCase().trim();
      const supportedLanguages = ['en', 'ar', 'ku', 'tr'];
      if (supportedLanguages.includes(lang)) {
        detectedLanguage = lang;
      }
    } else if (testUser.phoneNumber && testUser.phoneNumber.startsWith('+964')) {
      if (testUser.phoneNumber.startsWith('+9647') || testUser.phoneNumber.startsWith('+9646')) {
        detectedLanguage = 'ku'; // Kurdish
      } else {
        detectedLanguage = 'ar'; // Arabic
      }
    }
    
    console.log(`   ✅ Detected Language: ${detectedLanguage}`);
    
    // Test notification messages
    const messages = {
      en: { title: 'Driver is on the Way!', message: 'Your driver is heading to your pickup location.' },
      ar: { title: 'السائق في الطريق!', message: 'سائقك متجه إلى موقع الاستلام.' },
      ku: { title: 'شۆفێر لە ڕێگەدایە!', message: 'شۆفێرەکەت بەرەو شوێنی وەرگرتن دەڕوات.' },
      tr: { title: 'Sürücü Yolda!', message: 'Sürücünüz alış noktanıza doğru yolda.' }
    };
    
    const message = messages[detectedLanguage];
    console.log(`   📨 Notification: "${message.title}"`);
    console.log(`   📝 Message: "${message.message}"`);
  }

  console.log('\n✅ Language detection test completed!');
}

async function main() {
  try {
    await testNotificationLanguage();
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main(); 
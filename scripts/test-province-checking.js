const { checkAndUpdateUserProvinces, getProvinceFromCoordinates } = require('./check-user-provinces');

// Test province determination
console.log('🧪 Testing province determination...');

const testCoordinates = [
  { lat: 33.3152, lng: 44.3661, expected: 'Baghdad' }, // Baghdad
  { lat: 36.1901, lng: 43.9930, expected: 'Erbil' },   // Erbil
  { lat: 36.8671, lng: 42.9880, expected: 'Duhok' },   // Duhok
  { lat: 35.5569, lng: 45.4361, expected: 'Sulaymaniyah' }, // Sulaymaniyah
  { lat: 32.4826, lng: 44.4330, expected: 'Babil' },   // Babil
  { lat: 32.6167, lng: 44.0333, expected: 'Karbala' }, // Karbala
  { lat: 32.6167, lng: 45.7500, expected: 'Wasit' },   // Wasit
  { lat: 30.5150, lng: 47.8190, expected: 'Basra' },   // Basra
];

testCoordinates.forEach(({ lat, lng, expected }) => {
  const result = getProvinceFromCoordinates(lat, lng);
  const status = result === expected ? '✅' : '❌';
  console.log(`${status} (${lat}, ${lng}) → ${result} (expected: ${expected})`);
});

console.log('\n🧪 Testing province checking function...');

// Test the province checking function
async function testProvinceChecking() {
  try {
    await checkAndUpdateUserProvinces();
    console.log('✅ Province checking completed successfully');
  } catch (error) {
    console.error('❌ Error testing province checking:', error);
  }
}

testProvinceChecking(); 
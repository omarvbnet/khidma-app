const { checkAndUpdateUserProvinces, getProvinceFromCoordinates } = require('./check-user-provinces');

// Test province determination
console.log('🧪 Testing province determination...');

const testCoordinates = [
  { lat: 33.3152, lng: 44.3661, expected: 'Baghdad' }, // Baghdad
  { lat: 36.1901, lng: 43.9930, expected: 'Erbil' },   // Erbil
  { lat: 36.8671, lng: 42.2500, expected: 'Duhok' },   // Duhok (adjusted lng)
  { lat: 35.5569, lng: 45.4361, expected: 'Sulaymaniyah' }, // Sulaymaniyah
  { lat: 32.4826, lng: 44.4330, expected: 'Babil' },   // Babil
  { lat: 31.6167, lng: 44.0333, expected: 'Karbala' }, // Karbala (adjusted lat)
  { lat: 32.6167, lng: 45.7500, expected: 'Wasit' },   // Wasit
  { lat: 30.5150, lng: 47.8190, expected: 'Basra' },   // Basra
  { lat: 33.3250, lng: 43.5000, expected: 'Anbar' },   // Anbar (Ramadi)
  { lat: 35.4667, lng: 44.4000, expected: 'Kirkuk' },  // Kirkuk
  { lat: 34.5500, lng: 44.8500, expected: 'Diyala' },  // Diyala (Baqubah)
  { lat: 34.4667, lng: 43.5833, expected: 'Salahaddin' }, // Salahaddin (Tikrit)
  { lat: 36.3400, lng: 42.7500, expected: 'Nineveh' }, // Nineveh (Mosul) - adjusted lng
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
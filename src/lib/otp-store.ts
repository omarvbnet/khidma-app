// Shared OTP store for all routes
export const otpStore = new Map<string, { code: string; expires: number }>();

// Debug function to log OTP store state
export function logOTPStore() {
  console.log('=== OTP STORE STATE ===');
  console.log('Store size:', otpStore.size);
  console.log('All entries:');
  for (const [phone, data] of otpStore.entries()) {
    console.log(`- ${phone}: ${data.code} (expires: ${new Date(data.expires).toISOString()})`);
  }
  console.log('=======================');
}

// Cleanup expired OTPs
export function cleanupExpiredOTPs() {
  const now = Date.now();
  let cleaned = 0;
  for (const [phone, data] of otpStore.entries()) {
    if (now > data.expires) {
      otpStore.delete(phone);
      cleaned++;
    }
  }
  if (cleaned > 0) {
    console.log(`Cleaned up ${cleaned} expired OTPs`);
  }
} 
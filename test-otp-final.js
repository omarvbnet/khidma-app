const axios = require('axios');

async function testOTPFlowFinal() {
  try {
    console.log('=== FINAL OTP FLOW TEST ===');
    
    const baseUrl = 'http://192.168.0.90:3000/api/flutter';
    const phoneNumber = '9647501234567'; // Test phone number
    
    console.log('\n1. Sending OTP...');
    const sendResponse = await axios.post(`${baseUrl}/auth/otp/send`, {
      phoneNumber: phoneNumber
    });
    
    console.log('Send response:', sendResponse.data);
    
    if (sendResponse.data.otp) {
      const otp = sendResponse.data.otp;
      console.log('\n2. Verifying OTP...');
      console.log('Using OTP:', otp);
      
      // Wait a moment to see if there are any timing issues
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      const verifyResponse = await axios.post(`${baseUrl}/auth/otp/verify`, {
        phoneNumber: phoneNumber,
        otp: otp
      });
      
      console.log('Verify response:', verifyResponse.data);
    } else {
      console.log('No OTP returned in development mode');
    }
    
  } catch (error) {
    console.error('Error testing OTP flow:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  }
}

testOTPFlowFinal(); 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waddiny/constants/api_constants.dart';

class OTPService {
  // Helper method to format phone number
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-numeric characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If the number starts with 0, remove it
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If the number starts with 964, remove it to avoid duplication
    if (cleaned.startsWith('964')) {
      cleaned = cleaned.substring(3);
    }

    // Add 964 prefix
    cleaned = '964$cleaned';

    print('Original phone number: $phoneNumber'); // Debug log
    print('Formatted phone number: $cleaned'); // Debug log
    return cleaned;
  }

  Future<void> sendOTP(String phoneNumber) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/otp/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': formattedPhone}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Failed to send OTP';
      throw Exception(error);
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': formattedPhone,
        'otp': otp,
      }),
    );

    if (response.statusCode != 200) {
      final error =
          jsonDecode(response.body)['error'] ?? 'Failed to verify OTP';
      throw Exception(error);
    }

    return true;
  }
}

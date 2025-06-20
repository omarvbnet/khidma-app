import 'package:flutter/material.dart';
import '../services/otp_service.dart';
import '../services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _otpService = OTPService();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  late String _phoneNumber;
  late bool _isDriver;
  late Map<String, dynamic> _registrationData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _phoneNumber = args['phoneNumber'];
    _isDriver = args['isDriver'];
    _registrationData = args['registrationData'];
    _sendOTP();
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _otpService.sendOTP(_phoneNumber);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _error = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isVerified =
          await _otpService.verifyOTP(_phoneNumber, _otpController.text);
      if (isVerified) {
        if (_isDriver) {
          await _authService.registerDriver(
            phoneNumber: _phoneNumber,
            password: _registrationData['password'],
            fullName: _registrationData['fullName'],
            carId: _registrationData['carId'],
            carType: _registrationData['carType'],
            licenseId: _registrationData['licenseId'],
          );
        } else {
          await _authService.registerUser(
            phoneNumber: _phoneNumber,
            password: _registrationData['password'],
            fullName: _registrationData['fullName'],
          );
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the OTP sent to $_phoneNumber',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify OTP'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _sendOTP,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}

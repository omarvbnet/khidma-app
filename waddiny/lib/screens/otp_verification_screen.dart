import 'package:flutter/material.dart';
import '../services/otp_service.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

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
        _error = AppLocalizations.of(context)!.pleaseEnterOtp;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isVerified = await _otpService.verifyOTPForRegistration(
          _phoneNumber, _otpController.text);

      if (isVerified) {
        Map<String, dynamic>? regResponse;
        if (_isDriver) {
          regResponse = await _authService.registerDriver(
            phoneNumber: _phoneNumber,
            password: _registrationData['password'],
            fullName: _registrationData['fullName'],
            carId: _registrationData['carId'],
            carType: _registrationData['carType'],
            licenseId: _registrationData['licenseId'],
          );
        } else {
          regResponse = await _authService.registerUser(
            phoneNumber: _phoneNumber,
            password: _registrationData['password'],
            fullName: _registrationData['fullName'],
          );
        }

        // After registration, update province and log in automatically
        if (regResponse != null) {
          final userData = regResponse['user'];
          final token = regResponse['token'];
          if (userData != null && token != null) {
            try {
              final locationService = LocationService();
              final position = await locationService.getCurrentLocation();
              final province = await locationService.getProvinceFromCoordinates(
                position.latitude,
                position.longitude,
              );
              await locationService.updateUserProvince(token, province);
              // Optionally update local user data province here
            } catch (e) {
              print('Error updating province after registration: $e');
            }
            if (mounted) {
              if (userData['role'] == 'DRIVER') {
                Navigator.pushReplacementNamed(context, '/driver-main');
              } else {
                Navigator.pushReplacementNamed(context, '/user-main');
              }
              return;
            }
          }
        }
        // fallback
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
        title: Text(AppLocalizations.of(context)!.verifyPhoneNumber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.enterOtpSentTo(_phoneNumber),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.otp,
                border: const OutlineInputBorder(),
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
                  : Text(AppLocalizations.of(context)!.verifyOtp),
            ),
            TextButton(
              onPressed: _isLoading ? null : _sendOTP,
              child: Text(AppLocalizations.of(context)!.resendOtp),
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

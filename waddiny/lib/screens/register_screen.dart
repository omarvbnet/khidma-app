import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _carIdController = TextEditingController();
  final _carTypeController = TextEditingController();
  final _licenseIdController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isDriver = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _isDriver = args['isDriver'] ?? false;
        if (args['isVerified'] == true) {
          _phoneController.text = args['phoneNumber'] ?? '';
        }
      });
    }
  }

  Future<void> _verifyPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    final registrationData = {
      'password': _passwordController.text,
      'fullName': _fullNameController.text,
    };

    if (_isDriver) {
      registrationData.addAll({
        'carId': _carIdController.text,
        'carType': _carTypeController.text,
        'licenseId': _licenseIdController.text,
      });
    }

    Navigator.pushNamed(
      context,
      '/verify-otp',
      arguments: {
        'phoneNumber': _phoneController.text,
        'isDriver': _isDriver,
        'registrationData': registrationData,
      },
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = AuthService();
      if (_isDriver) {
        await authService.registerDriver(
          phoneNumber: _phoneController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          carId: _carIdController.text,
          carType: _carTypeController.text,
          licenseId: _licenseIdController.text,
        );
      } else {
        await authService.registerUser(
          phoneNumber: _phoneController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
        );
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
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
        title: Text(_isDriver ? 'Register as Driver' : 'Register as User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (_isDriver) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _carIdController,
                  decoration: const InputDecoration(
                    labelText: 'Car ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your car ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _carTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Car Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your car type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseIdController,
                  decoration: const InputDecoration(
                    labelText: 'License ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your license ID';
                    }
                    return null;
                  },
                ),
              ],
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
                onPressed: _isLoading ? null : _verifyPhoneNumber,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Verify Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _carIdController.dispose();
    _carTypeController.dispose();
    _licenseIdController.dispose();
    super.dispose();
  }
}

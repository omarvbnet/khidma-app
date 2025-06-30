import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'user_main_screen.dart';
import 'driver_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final response = await authService.login(
          _phoneController.text,
          _passwordController.text,
        );

        // Check user role and navigate accordingly
        final userData = response['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', userData['role']);
        if (userData['role'] == 'DRIVER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverMainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserMainScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseRegistrationType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLocalizations.of(context)!.registerAsUser),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/register-user',
                  arguments: {'isDriver': false},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_eta),
              title: Text(AppLocalizations.of(context)!.registerAsDriver),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/register-driver',
                  arguments: {'isDriver': true},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.local_taxi,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterPhoneNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(AppLocalizations.of(context)!.login),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _showRegistrationDialog,
                  child: Text(AppLocalizations.of(context)!.dontHaveAccount),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

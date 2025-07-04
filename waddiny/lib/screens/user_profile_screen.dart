import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../components/language_switcher.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'create_report_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _apiService.getUserProfile();
      print('User profile loaded: ${user.toJson()}'); // Debug print
      print('User budget from API: ${user.budget}'); // Debug print
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorLoadingUserData(e.toString()))),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.errorLoggingOut(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.noUserDataFound),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                child: Text(AppLocalizations.of(context)!.goToLogin),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: AppLocalizations.of(context)!.personalInformation,
              children: [
                _buildInfoRow(
                    AppLocalizations.of(context)!.fullName, _user!.fullName),
                _buildInfoRow(AppLocalizations.of(context)!.phoneNumber,
                    _user!.phoneNumber),
                _buildInfoRow(
                    AppLocalizations.of(context)!.province, _user!.province),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: AppLocalizations.of(context)!.accountInformation,
              children: [
                _buildInfoRow(AppLocalizations.of(context)!.accountType,
                    _getLocalizedRole(_user!.role)),
                _buildInfoRow(AppLocalizations.of(context)!.accountStatus,
                    _getLocalizedStatus(_user!.status)),
                _buildInfoRow(AppLocalizations.of(context)!.budget,
                    '${_user!.budget.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currencyLabel}'),
                _buildInfoRow(AppLocalizations.of(context)!.memberSince,
                    _formatDate(_user!.createdAt)),
              ],
            ),
            const SizedBox(height: 16),
            // Report Button
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.reports),
                subtitle: Text(AppLocalizations.of(context)!.createReport),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateReportScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Language Switcher
            LanguageSwitcher(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getLocalizedRole(String role) {
    switch (role.toUpperCase()) {
      case 'USER':
        return AppLocalizations.of(context)!.userRole;
      case 'DRIVER':
        return AppLocalizations.of(context)!.driverRole;
      case 'ADMIN':
        return AppLocalizations.of(context)!.adminRole;
      default:
        return role;
    }
  }

  String _getLocalizedStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppLocalizations.of(context)!.activeStatus;
      case 'PENDING':
        return AppLocalizations.of(context)!.pendingStatus;
      case 'SUSPENDED':
        return AppLocalizations.of(context)!.suspendedStatus;
      case 'BLOCKED':
        return AppLocalizations.of(context)!.blockedStatus;
      default:
        return status;
    }
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

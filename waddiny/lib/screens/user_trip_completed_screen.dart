import 'package:flutter/material.dart';
import 'dart:async';
import '../models/trip_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

class UserTripCompletedScreen extends StatefulWidget {
  final Trip trip;

  const UserTripCompletedScreen({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  _UserTripCompletedScreenState createState() =>
      _UserTripCompletedScreenState();
}

class _UserTripCompletedScreenState extends State<UserTripCompletedScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _navigationTimer;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _animationController.forward();

    // Start countdown timer
    _startCountdown();
  }

  void _startCountdown() {
    _navigationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });

        if (_countdown <= 0) {
          timer.cancel();
          // Don't navigate here - parent will handle it
        }
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      // Navigate back to parent which will handle the flow
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success message
                  Text(
                    getLocalizations(context).tripCompletedTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    getLocalizations(context).thankYouForUsingService,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Trip details card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildTripDetail(
                            getLocalizations(context).fromLabel,
                            widget.trip.pickupLocation,
                            Icons.location_on,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildTripDetail(
                            getLocalizations(context).toLabel,
                            widget.trip.dropoffLocation,
                            Icons.flag,
                            Colors.red,
                          ),
                          const SizedBox(height: 16),
                          _buildTripDetail(
                            getLocalizations(context).distance,
                            '${widget.trip.distance.toStringAsFixed(1)} km',
                            Icons.route,
                            Colors.purple,
                          ),
                          const SizedBox(height: 16),
                          _buildTripDetail(
                            getLocalizations(context).fareLabel,
                            '${widget.trip.fare} IQD',
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Countdown message
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 20,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          getLocalizations(context)
                              .countdownMessage(_countdown),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Return to home button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(getLocalizations(context).returnToHomeNow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetail(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

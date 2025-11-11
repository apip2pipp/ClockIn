import 'package:flutter/material.dart';
import '../utils/app_helpers.dart';
import 'splash_screen.dart';

/// Developer screen untuk testing dan debugging
/// Dapat dihapus di production
class DeveloperTestScreen extends StatefulWidget {
  const DeveloperTestScreen({super.key});

  @override
  State<DeveloperTestScreen> createState() => _DeveloperTestScreenState();
}

class _DeveloperTestScreenState extends State<DeveloperTestScreen> {
  bool hasSeenOnboarding = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final status = await OnboardingPreferences.hasSeenOnboarding();
    setState(() {
      hasSeenOnboarding = status;
    });
  }

  Future<void> _resetOnboarding() async {
    setState(() => isLoading = true);
    await OnboardingPreferences.resetOnboarding();
    await _checkOnboardingStatus();
    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding has been reset!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _setOnboardingComplete() async {
    setState(() => isLoading = true);
    await OnboardingPreferences.setOnboardingComplete();
    await _checkOnboardingStatus();
    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding marked as complete!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _restartApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Test Screen'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    color: hasSeenOnboarding
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            hasSeenOnboarding
                                ? Icons.check_circle
                                : Icons.info_outline,
                            size: 48,
                            color: hasSeenOnboarding
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Onboarding Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasSeenOnboarding ? 'Completed' : 'Not Completed',
                            style: TextStyle(
                              fontSize: 16,
                              color: hasSeenOnboarding
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Use this screen to test onboarding flow. '
                          'Reset onboarding to see it again, or mark as complete to skip it.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reset Button
                  ElevatedButton.icon(
                    onPressed: _resetOnboarding,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mark Complete Button
                  ElevatedButton.icon(
                    onPressed: _setOnboardingComplete,
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Restart App Button
                  ElevatedButton.icon(
                    onPressed: _restartApp,
                    icon: const Icon(Icons.replay),
                    label: const Text('Restart App (Show Splash)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Refresh Status Button
                  OutlinedButton.icon(
                    onPressed: _checkOnboardingStatus,
                    icon: const Icon(Icons.sync),
                    label: const Text('Refresh Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Note',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This screen is for development only. '
                          'Remove or hide it in production build.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

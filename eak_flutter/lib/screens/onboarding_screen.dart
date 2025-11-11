import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  // Onboarding data
  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/onboarding/onboarding-1.png',
      title: 'Welcome to ClockIn',
      subtitle: 'Your smart attendance management solution',
      color: Color(0xFF4A90E2),
    ),
    OnboardingData(
      image: 'assets/onboarding/onboarding-2.png',
      title: 'Easy Attendance',
      subtitle: 'Clock in and out with just one tap, anytime, anywhere',
      color: Color(0xFF50C878),
    ),
    OnboardingData(
      image: 'assets/onboarding/onboarding-3.png',
      title: 'Track Your Time',
      subtitle: 'Monitor your working hours and attendance history',
      color: Color(0xFFFF6B6B),
    ),
    OnboardingData(
      image: 'assets/onboarding/onboarding-4.png',
      title: 'Real-time Reports',
      subtitle: 'Get instant updates and detailed attendance reports',
      color: Color(0xFFFFB84D),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (!isLastPage)
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 20),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _controller.jumpToPage(_pages.length - 1),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    isLastPage = index == _pages.length - 1;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Bottom section with indicator and button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor:
                          _pages[_controller.hasClients
                                  ? (_controller.page?.round() ?? 0)
                                  : 0]
                              .color,
                      dotColor: Colors.grey[300]!,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          _completeOnboarding();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _pages[_controller.hasClients
                                    ? (_controller.page?.round() ?? 0)
                                    : 0]
                                .color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Image.asset(data.image, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Flexible(
            flex: 1,
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      // Set onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }
}

// Model class for onboarding data
class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final Color color;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

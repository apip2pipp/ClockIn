import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          children: [
            _buildPage(
              color: Colors.blue.shade100,
              urlImage: 'assets/images/onboarding1.png',
              title: 'Welcome to EAK',
              subtitle: 'Your Ultimate Attendance Solution',
            ),
            _buildPage(
              color: Colors.green.shade100,
              urlImage: 'assets/images/onboarding2.png',
              title: 'Easy Clock In/Out',
              subtitle: 'Track your attendance with just one tap',
            ),
            _buildPage(
              color: Colors.orange.shade100,
              urlImage: 'assets/images/onboarding3.png',
              title: 'Real-time Updates',
              subtitle: 'Stay informed with instant attendance status',
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? _buildGetStartedButton()
          : _buildBottomButtons(),
    );
  }

  Widget _buildPage({
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
  }) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            urlImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
          ),
          const SizedBox(height: 64),
          Text(
            title,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => _controller.jumpToPage(2),
            child: const Text('SKIP'),
          ),
          Center(
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: WormEffect(
                spacing: 16,
                dotColor: Colors.black26,
                activeDotColor: Colors.teal.shade700,
              ),
              onDotClicked: (index) => _controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
            child: const Text('NEXT'),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.teal.shade700,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              // Set onboarding as completed
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('showHome', true);

              // Navigate to home screen
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            child: const Text(
              'Get Started',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

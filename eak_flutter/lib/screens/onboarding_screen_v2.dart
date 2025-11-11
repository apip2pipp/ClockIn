import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Alternative Onboarding Screen dengan design yang berbeda
/// Dapat digunakan sebagai alternatif dari onboarding_screen.dart
class OnboardingScreenV2 extends StatefulWidget {
  const OnboardingScreenV2({super.key});

  @override
  State<OnboardingScreenV2> createState() => _OnboardingScreenV2State();
}

class _OnboardingScreenV2State extends State<OnboardingScreenV2>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  bool isLastPage = false;
  int currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      image: 'assets/onboarding/onboarding-1.png',
      title: 'Welcome to ClockIn',
      subtitle: 'Your smart attendance management solution',
      features: [
        'Easy clock in/out system',
        'Real-time attendance tracking',
        'Automated reporting',
      ],
      color: Color(0xFF4A90E2),
    ),
    OnboardingPageData(
      image: 'assets/onboarding/onboarding-2.png',
      title: 'Easy Attendance',
      subtitle: 'Clock in and out with just one tap',
      features: [
        'GPS location tracking',
        'Quick QR code scanning',
        'Offline mode support',
      ],
      color: Color(0xFF50C878),
    ),
    OnboardingPageData(
      image: 'assets/onboarding/onboarding-3.png',
      title: 'Track Your Time',
      subtitle: 'Monitor your working hours easily',
      features: [
        'Daily attendance summary',
        'Working hours calculator',
        'Overtime tracking',
      ],
      color: Color(0xFFFF6B6B),
    ),
    OnboardingPageData(
      image: 'assets/onboarding/onboarding-4.png',
      title: 'Real-time Reports',
      subtitle: 'Get instant updates and reports',
      features: [
        'Monthly attendance reports',
        'Export to PDF/Excel',
        'Performance analytics',
      ],
      color: Color(0xFFFFB84D),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[currentPage].color.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                      isLastPage = index == _pages.length - 1;
                    });
                    _fadeController.reset();
                    _fadeController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPageContent(_pages[index]);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ClockIn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _pages[currentPage].color,
            ),
          ),
          if (!isLastPage)
            TextButton(
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
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPageData data) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image with hero animation
            Hero(
              tag: 'onboarding_image_$currentPage',
              child: Container(
                height: 280,
                padding: const EdgeInsets.all(20),
                child: Image.asset(data.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 40),
            // Title
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
            const SizedBox(height: 32),
            // Features list
            ...data.features.map(
              (feature) => _buildFeatureItem(feature, data.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${currentPage + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _pages[currentPage].color,
                ),
              ),
              Text(
                ' / ${_pages.length}',
                style: TextStyle(fontSize: 18, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Page indicator
          SmoothPageIndicator(
            controller: _controller,
            count: _pages.length,
            effect: WormEffect(
              activeDotColor: _pages[currentPage].color,
              dotColor: Colors.grey[300]!,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 12,
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              if (currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _pages[currentPage].color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size(0, 56),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        color: _pages[currentPage].color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (currentPage > 0) const SizedBox(width: 16),
              Expanded(
                flex: currentPage > 0 ? 1 : 1,
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
                    backgroundColor: _pages[currentPage].color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 56),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLastPage ? Icons.check : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      if (mounted) {
        // TODO: Navigate to home/login screen
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: _pages[currentPage].color),
                const SizedBox(width: 12),
                const Text('Welcome!'),
              ],
            ),
            content: const Text('You\'re all set to start using ClockIn app.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to actual home screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pages[currentPage].color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Let\'s Go!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }
}

class OnboardingPageData {
  final String image;
  final String title;
  final String subtitle;
  final List<String> features;
  final Color color;

  OnboardingPageData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.color,
  });
}

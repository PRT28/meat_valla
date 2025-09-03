import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'Login.dart';
import 'Register.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image: 'assets/landing/1.jpg',
      title: 'Fresh Meat Delivered',
      subtitle: 'Get premium quality fresh meat delivered straight to your doorstep',
    ),
    OnboardingData(
      image: 'assets/landing/2.jpg',
      title: 'Wide Selection',
      subtitle: 'Choose from chicken, mutton, fish, and more premium cuts',
    ),
    OnboardingData(
      image: 'assets/landing/3.jpg',
      title: 'Quick & Reliable',
      subtitle: 'Fast delivery with temperature-controlled packaging',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // PageView for onboarding slides
              Expanded(
                flex: 4,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingData[index]);
                  },
                ),
              ),

              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),

              // Bottom Section with Buttons
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_currentPage < _onboardingData.length - 1) ...[
                        // Next Button
                        CustomButton(
                          onPressed: _nextPage,
                          child: const Text('Next'),
                        ),
                      ] else ...[
                        // Get Started and Login Buttons
                        CustomButton(
                          onPressed: _goToRegister,
                          child: const Text('Get Started'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: _skipToLogin,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLight,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.textLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
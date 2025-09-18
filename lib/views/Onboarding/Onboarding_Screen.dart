import 'package:flutter/material.dart';
import 'package:sales_bets/views/Login/Login_Screen.dart';
import 'package:sales_bets/views/SignUp/Signup_onboarding.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sales_bets/core/utils/app_theme.dart'; // Ensure this path is correct

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _onboardingData = const [
    {
      'title': 'Welcome to Sales Bets',
      'description': 'The revolutionary platform where business challenges become a game. Bet on success, not on loss.',
      'Asset': 'assets/1.png',
    },
    {
      'title': 'Win Big, Never Lose',
      'description': 'Unlike traditional betting, your credits are safe. You only gain rewards and money when your team wins!',
      'Asset': 'assets/2.png',
    },
    {
      'title': 'Follow Your Winners',
      'description': 'Track top-performing teams and athletes. Get real-time updates and exclusive access to live streams.',
      'Asset': 'assets/3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(
                  title: _onboardingData[index]['title']!,
                  description: _onboardingData[index]['description']!,
                  lottieAsset: _onboardingData[index]['Asset']!,
                  theme: theme,
                );
              },
            ),
            _buildPageIndicator(theme),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required String lottieAsset,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Image.asset(
              lottieAsset,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppTheme.lightText,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Align(
      alignment: const Alignment(0, 0.8),
      child: SmoothPageIndicator(
        controller: _pageController,
        count: _onboardingData.length,
        effect: WormEffect(
          dotColor: AppTheme.darkSurface,
          activeDotColor: AppTheme.primaryColor,
          dotHeight: 8,
          dotWidth: 8,
          spacing: 8,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Navigate to auth screen
              },
              child: Text(
                'Skip',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
FloatingActionButton(
  onPressed: () {
    if (_pageController.page == _onboardingData.length - 1) {
      // Navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    }
  },
  backgroundColor: AppTheme.primaryColor,
  child: const Icon(Icons.arrow_forward_ios_rounded),
)

          ],
        ),
      ),
    );
  }
}
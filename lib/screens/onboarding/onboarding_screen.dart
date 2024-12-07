import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:foodpundit/theme/app_colors.dart';
import 'package:foodpundit/utils/preferences_utils.dart';
import 'package:foodpundit/widgets/splash_painter.dart';
import 'package:foodpundit/screens/auth/sign_in_screen.dart';
import 'package:foodpundit/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to Food Pundit',
      description: 'Your personal guide to understanding what\'s in your food',
      image: 'assets/images/onboarding/thali.png',
      pattern: SplashPattern.waves,
    ),
    OnboardingPage(
      title: 'Scan & Learn',
      description:
          'Simply upload any product back label to instantly see detailed ingredient detailed information',
      image: 'assets/images/onboarding/foodpacket.png',
      pattern: SplashPattern.circles,
    ),
    OnboardingPage(
      title: 'Ingredient Analysis',
      description:
          'Get in-depth information about ingredients, including benefits and potential allergens',
      image: 'assets/images/onboarding/nutri_quality.jpg',
      pattern: SplashPattern.curves,
    ),
    OnboardingPage(
      title: 'Health Insights',
      description:
          'Make informed decisions with detailed nutritional facts and health impact analysis',
      image: 'assets/images/onboarding/19197874.jpg',
      pattern: SplashPattern.dots,
    ),
    OnboardingPage(
      title: 'Start Your Journey',
      description:
          'Join us in making healthier food choices with knowledge at your fingertips',
      image: 'assets/images/onboarding/healthy_family.png',
      pattern: SplashPattern.lines,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIntroEnd(BuildContext context) async {
    await PreferencesUtils.setOnboardingComplete();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          return Container(
            padding: const EdgeInsets.only(bottom: 80),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  isLastPage = index == pages.length - 1;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return OnboardingPageWidget(page: pages[index]);
              },
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        color: theme.scaffoldBackgroundColor,
        child: Builder(
          builder: (BuildContext bottomContext) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _onIntroEnd(bottomContext),
                  child: Text(
                    'Skip',
                    style: TextStyle(color: AppColors.getTextPrimary(context)),
                  ),
                ),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: WormEffect(
                      spacing: 16,
                      dotColor:
                          AppColors.getTextSecondary(context).withOpacity(0.3),
                      activeDotColor: theme.colorScheme.primary,
                    ),
                    onDotClicked: (index) => _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (isLastPage) {
                      _onIntroEnd(bottomContext);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(
                    isLastPage ? 'Start' : 'Next',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final SplashPattern pattern;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.pattern,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        CustomPaint(
          size: Size(size.width, size.height),
          painter: SplashPainter(
            color: AppColors.primary,
            pattern: page.pattern,
            isDarkMode: isDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.35,
                width: size.width * 0.8,
                constraints: const BoxConstraints(
                  maxHeight: 400,
                  maxWidth: 400,
                ),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 64),
              Text(
                page.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                page.description,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

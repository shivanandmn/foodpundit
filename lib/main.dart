import 'package:flutter/material.dart';
import 'package:foodpundit/config/environment_config.dart';
import 'dart:ui';
import 'package:foodpundit/utils/ui_constants.dart';
import 'package:foodpundit/widgets/custom_app_bar.dart';
import 'package:foodpundit/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foodpundit/screens/onboarding/onboarding_screen.dart';
import 'package:foodpundit/utils/preferences_utils.dart';
import 'package:foodpundit/utils/size_config.dart';
import 'package:foodpundit/theme/app_theme.dart';
import 'package:foodpundit/screens/auth/sign_in_screen.dart';
import 'package:foodpundit/providers/app_auth_provider.dart';
import 'package:foodpundit/screens/home/home_page.dart';
import 'package:foodpundit/services/network_service.dart';
import 'package:foodpundit/screens/help_support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the environment based on build configuration
  const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  switch (environment) {
    case 'production':
      EnvironmentConfig.setEnvironment(Environment.production);
      break;
    case 'staging':
      EnvironmentConfig.setEnvironment(Environment.staging);
      break;
    default:
      EnvironmentConfig.setEnvironment(Environment.development);
  }

  await Firebase.initializeApp();

  // Add error handling for platform errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
            create: (_) => AppAuthProvider()),
        ChangeNotifierProvider<NetworkService>(create: (_) => NetworkService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig().init(context);

    return MaterialApp(
      title: 'Food Pundit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AppAuthProvider>(
              builder: (context, authProvider, child) {
                Widget mainContent = FutureBuilder<bool>(
                  future: PreferencesUtils.hasCompletedOnboarding(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    }

                    final bool hasCompletedOnboarding = snapshot.data ?? false;
                    if (!hasCompletedOnboarding) {
                      return const OnboardingScreen();
                    }

                    return authProvider.isAuthenticated
                        ? const HomePage()
                        : const SignInScreen();
                  },
                );

                return LoadingOverlay(
                  isLoading: authProvider.isLoading,
                  child: mainContent,
                );
              },
            ),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomePage(),
        '/help': (context) => const HelpSupportScreen(),
      },
    );
  }
}

Future<bool> _checkOnboardingStatus() async {
  try {
    final hasCompletedOnboarding =
        await PreferencesUtils.hasCompletedOnboarding();
    return hasCompletedOnboarding;
  } catch (e) {
    debugPrint('Error checking onboarding status: $e');
    return false;
  }
}

Future<void> _initializeApp() async {
  try {
    // Add any additional initialization here
    await Future.delayed(
        const Duration(seconds: 2)); // Minimum splash screen duration
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.white.withOpacity(0.5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;
  const AppShell({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: child,
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.055; // Reduced from 0.07
    final fontSize = size.width * 0.028; // Reduced from 0.035

    return Semantics(
      label: '$label navigation button',
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight,
                minHeight: 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? theme.primaryColor : theme.hintColor,
                    size: iconSize,
                  ),
                  const SizedBox(height: UIConstants.spacingXXS),
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            isSelected ? theme.primaryColor : theme.hintColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: fontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

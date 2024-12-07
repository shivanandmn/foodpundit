import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  static const String keyOnboardingComplete = 'onboarding_complete';

  static Future<bool> hasCompletedOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyOnboardingComplete, true);
  }
}

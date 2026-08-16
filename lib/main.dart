import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/detox_provider.dart';
import 'screens/detox_timer_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';
import 'services/strict_mode_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final storage = StorageService();
  final bool hasCompletedOnboarding = await storage.isOnboardingCompleted();

  Widget initialScreen = const OnboardingScreen();

  if (hasCompletedOnboarding) {
    // Check if current time falls within scheduled strict detox window
    final strictCheck = await StrictModeService().checkStrictMode();

    if (strictCheck.shouldTrigger) {
      initialScreen = DetoxTimerScreen(
        totalMinutes: strictCheck.durationMinutes,
        isStrict: true,
        routineType: strictCheck.routineType,
      );
    } else {
      initialScreen = const MainNavScreen();
    }
  }

  runApp(MainApp(initialScreen: initialScreen));
}

class MainApp extends StatelessWidget {
  final Widget initialScreen;

  const MainApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DetoxProvider()),
      ],
      child: MaterialApp(
        title: 'Unscreen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: initialScreen,
      ),
    );
  }
}
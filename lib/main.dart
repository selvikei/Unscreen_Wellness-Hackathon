import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/detox_provider.dart';
import 'screens/main_nav_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';
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

  runApp(MainApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class MainApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MainApp({super.key, required this.hasCompletedOnboarding});

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
        home: hasCompletedOnboarding
            ? const MainNavScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}
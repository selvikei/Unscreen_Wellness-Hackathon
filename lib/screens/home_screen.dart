import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/detox_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'choose_detox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final profile = await StorageService().getUserProfile();
    if (!mounted) return;
    setState(() {
      _userName = profile?.name.trim() ?? '';
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    if (_userName.isNotEmpty) {
      return '$greeting, $_userName 👋';
    }

    return '$greeting 👋';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetoxProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                "Take a break from your screen.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Main Highlight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: AppTheme.lightSage.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.lightSage, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Today's Digital Wellness",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${provider.todayCompletedMinutes}',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primarySage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'mins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              size: 18, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            "Streak: ${provider.currentStreakDays} days",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Goal Progress Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Daily Intention",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            "${(provider.todayProgress * 100).toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primarySage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: provider.todayProgress,
                          minHeight: 10,
                          backgroundColor: AppTheme.lightSage,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primarySage),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${provider.todayCompletedMinutes} of ${provider.dailyGoalMinutes} min goal reached",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Call-to-Action Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChooseDetoxScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 20),
                      SizedBox(width: 8),
                      Text("Start Detox"),
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
}
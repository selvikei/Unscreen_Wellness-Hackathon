import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final StorageService _storage = StorageService();

  int _currentPage = 0;

  // Form State
  final TextEditingController _nameController = TextEditingController();
  String _selectedPronoun = 'she/her';
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  String _selectedRoutine = 'Both';

  final List<String> _pronouns = ['she/her', 'he/him', 'they/them'];
  final List<Map<String, dynamic>> _routines = [
    {
      'title': 'Before Sleep',
      'desc': 'Wind down and clear your mind before bed',
      'icon': Icons.nightlight_round,
    },
    {
      'title': 'When Waking Up',
      'desc': 'Start your morning without instant screen noise',
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'title': 'Both',
      'desc': 'Protect both morning clarity and night rest',
      'icon': Icons.all_inclusive_rounded,
    },
    {
      'title': 'Custom / Flexible',
      'desc': 'Take spontaneous detox moments during the day',
      'icon': Icons.touch_app_rounded,
    },
  ];

  Future<void> _selectTime(bool isWakeUp) async {
    final initial = isWakeUp ? _wakeUpTime : _sleepTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primarySage,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isWakeUp) {
          _wakeUpTime = picked;
        } else {
          _sleepTime = picked;
        }
      });
    }
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final profile = UserProfile(
      name: _nameController.text.trim(),
      pronoun: _selectedPronoun,
      wakeUpTime: _wakeUpTime.format(context),
      sleepTime: _sleepTime.format(context),
      detoxRoutine: _selectedRoutine,
    );

    await _storage.saveUserProfile(profile);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Top Progress Indicator
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primarySage
                            : AppTheme.lightSage,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Step Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildNameAndPronounStep(),
                    _buildWakeUpStep(),
                    _buildSleepStep(),
                    _buildRoutineStep(),
                  ],
                ),
              ),

              // Bottom Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == 3 ? "Get Started" : "Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: Name & Pronoun
  Widget _buildNameAndPronounStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome to Unscreen", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text("What should we call you?", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Your name or nickname",
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEFEFEA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEFEFEA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primarySage, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          "Pronoun",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _pronouns.map((pronoun) {
            final isSelected = _selectedPronoun == pronoun;
            return ChoiceChip(
              label: Text(pronoun),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPronoun = pronoun),
              selectedColor: AppTheme.lightSage,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primarySage : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 2: Wake Up Time
  Widget _buildWakeUpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Routine", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text("When does your day usually begin?", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(
          "We use this to encourage screen-free mornings.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 48),
        Center(
          child: InkWell(
            onTap: () => _selectTime(true),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.lightSage, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.wb_sunny_rounded, size: 40, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    _wakeUpTime.format(context),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Tap to change time", style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Sleep Time
  Widget _buildSleepStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rest & Recovery", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text("What time do you usually go to bed?", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(
          "Helps you set up gentle wind-down detox habits.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 48),
        Center(
          child: InkWell(
            onTap: () => _selectTime(false),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.lightSage, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.nightlight_round, size: 40, color: AppTheme.accentBlue),
                  const SizedBox(height: 16),
                  Text(
                    _sleepTime.format(context),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Tap to change time", style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Detox Routine Selection
  Widget _buildRoutineStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Detox & Streak Focus", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text("When do you prefer to take your break?", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          ..._routines.map((routine) {
            final isSelected = _selectedRoutine == routine['title'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => setState(() => _selectedRoutine = routine['title'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.lightSage : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        routine['icon'] as IconData,
                        color: isSelected ? AppTheme.primarySage : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              routine['desc'] as String,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
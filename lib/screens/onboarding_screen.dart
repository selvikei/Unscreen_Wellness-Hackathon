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

  final TextEditingController _nameController = TextEditingController();
  String _selectedPronoun = 'she/her';
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  String _selectedRoutine = 'Both';
  int _morningMinutes = 15;
  int _nightMinutes = 30;

  final List<String> _pronouns = ['she/her', 'he/him', 'they/them'];
  final List<int> _durations = [15, 30, 45, 60];

  final List<Map<String, dynamic>> _routines = [
    {
      'title': 'When Waking Up',
      'desc': 'Start your morning without instant screen noise',
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'title': 'Before Sleep',
      'desc': 'Wind down and clear your mind before bed',
      'icon': Icons.nightlight_round,
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
      wakeUpHour: _wakeUpTime.hour,
      wakeUpMinute: _wakeUpTime.minute,
      sleepHour: _sleepTime.hour,
      sleepMinute: _sleepTime.minute,
      detoxRoutine: _selectedRoutine,
      morningMinutes: _morningMinutes,
      nightMinutes: _nightMinutes,
    );

    await _storage.saveUserProfile(profile);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }

  Widget _buildDurationPicker(String title, int currentVal, ValueChanged<int> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Row(
          children: _durations.map((m) {
            final isSel = currentVal == m;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(m),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.primarySage : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? AppTheme.primarySage : const Color(0xFFEFEFEA)),
                  ),
                  child: Center(
                    child: Text(
                      "${m}m",
                      style: TextStyle(
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : AppTheme.textDark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index <= _currentPage ? AppTheme.primarySage : AppTheme.lightSage,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildNameStep(),
                    _buildWakeUpStep(),
                    _buildSleepStep(),
                    _buildRoutineAndDurationStep(),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == 3 ? "Complete Setup" : "Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
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
          ),
        ),
        const SizedBox(height: 28),
        const Text("Pronoun", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
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
                side: BorderSide(color: isSelected ? AppTheme.primarySage : const Color(0xFFEFEFEA)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWakeUpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Morning Routine", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text("When do you wake up?", style: Theme.of(context).textTheme.headlineLarge),
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
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: AppTheme.textDark),
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

  Widget _buildSleepStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Evening Routine", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text("What time do you sleep?", style: Theme.of(context).textTheme.headlineLarge),
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
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: AppTheme.textDark),
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

  Widget _buildRoutineAndDurationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Strict Detox Preference", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text("Select routine & duration", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),

          ..._routines.map((routine) {
            final isSelected = _selectedRoutine == routine['title'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () => setState(() => _selectedRoutine = routine['title'] as String),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.lightSage : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(routine['icon'] as IconData, color: isSelected ? AppTheme.primarySage : AppTheme.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          routine['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Duration picker for Morning
          if (_selectedRoutine == 'When Waking Up' || _selectedRoutine == 'Both') ...[
            _buildDurationPicker(
              "Morning Strict Duration:",
              _morningMinutes,
              (val) => setState(() => _morningMinutes = val),
            ),
            const SizedBox(height: 14),
          ],

          // Duration picker for Night
          if (_selectedRoutine == 'Before Sleep' || _selectedRoutine == 'Both') ...[
            _buildDurationPicker(
              "Night Strict Duration:",
              _nightMinutes,
              (val) => setState(() => _nightMinutes = val),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
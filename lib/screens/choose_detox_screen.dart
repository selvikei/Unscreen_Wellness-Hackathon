import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'detox_timer_screen.dart';

class ChooseDetoxScreen extends StatefulWidget {
  const ChooseDetoxScreen({super.key});

  @override
  State<ChooseDetoxScreen> createState() => _ChooseDetoxScreenState();
}

class _ChooseDetoxScreenState extends State<ChooseDetoxScreen> {
  int _selectedMinutes = 15;

  final List<int> _durations = [15, 30, 60];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How long do you want\nto disconnect?",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Pick a moment that feels right for you right now.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Duration Choices
              ..._durations.map((duration) {
                final isSelected = _selectedMinutes == duration;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => setState(() => _selectedMinutes = duration),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.lightSage : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? AppTheme.primarySage : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "$duration Minutes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetoxTimerScreen(
                          totalMinutes: _selectedMinutes,
                        ),
                      ),
                    );
                  },
                  child: const Text("Begin Session"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
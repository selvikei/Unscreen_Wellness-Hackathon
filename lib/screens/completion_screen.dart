import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detox_provider.dart';
import '../theme/app_theme.dart';

class CompletionScreen extends StatefulWidget {
  final int durationMinutes;

  const CompletionScreen({super.key, required this.durationMinutes});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  String _selectedFeeling = 'Better';

  final List<Map<String, String>> _feelings = [
    {'label': 'Better', 'emoji': '😊'},
    {'label': 'Same', 'emoji': '😐'},
    {'label': 'Difficult', 'emoji': '😫'},
  ];

  void _saveAndFinish() async {
    await context.read<DetoxProvider>().addSession(
      durationMinutes: widget.durationMinutes,
      feeling: _selectedFeeling,
    );
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.lightSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 40,
                  color: AppTheme.primarySage,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "You're back 🌿",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                "You spent ${widget.durationMinutes} minutes offline.\nThat's time you gave back to yourself.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Highlight Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.lightSage.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "+${widget.durationMinutes} Wellness Minutes",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primarySage,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 48),
              const Text(
                "How do you feel?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Feeling selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _feelings.map((item) {
                  final isSelected = _selectedFeeling == item['label'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedFeeling = item['label']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            Text(item['emoji']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              item['label']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _saveAndFinish,
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
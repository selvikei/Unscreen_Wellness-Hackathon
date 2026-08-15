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
  bool _isCustom = false;
  int _customMinutes = 15;

  final List<int> _presetDurations = [15, 30, 60];

  void _showCustomDurationDialog() {
    final controller = TextEditingController(text: '$_customMinutes');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int tempMinutes = _customMinutes;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Set Custom Duration",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Display Minutes
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$tempMinutes',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primarySage,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tempMinutes == 1 ? 'minute' : 'minutes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Slider: min 1, max 180
                  Slider(
                    value: tempMinutes.toDouble().clamp(1.0, 180.0),
                    min: 1.0,
                    max: 180.0,
                    divisions: 179,
                    activeColor: AppTheme.primarySage,
                    inactiveColor: AppTheme.lightSage,
                    onChanged: (val) {
                      setModalState(() {
                        tempMinutes = val.round();
                        controller.text = '$tempMinutes';
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Text Field with safe empty-state handling
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Or type duration (1 - 180 min)",
                      hintText: "1",
                      suffixText: "min",
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEFEFEA)),
                      ),
                    ),
                    onChanged: (val) {
                      final trimmed = val.trim();
                      if (trimmed.isEmpty) {
                        // Empty string is allowed - no error thrown
                        setModalState(() {
                          tempMinutes = 1;
                        });
                        return;
                      }

                      final parsed = int.tryParse(trimmed);
                      if (parsed != null) {
                        setModalState(() {
                          tempMinutes = parsed.clamp(1, 180);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Fallback safe value on submit if user cleared input
                        final textVal = controller.text.trim();
                        final parsed = int.tryParse(textVal) ?? tempMinutes;
                        final finalMinutes = parsed.clamp(1, 180);

                        setState(() {
                          _customMinutes = finalMinutes;
                          _selectedMinutes = finalMinutes;
                          _isCustom = true;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Apply Duration"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
              const SizedBox(height: 32),

              // Preset Options
              ..._presetDurations.map((duration) {
                final isSelected = !_isCustom && _selectedMinutes == duration;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        _selectedMinutes = duration;
                        _isCustom = false;
                      });
                    },
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

              // Custom Duration Option
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    _isCustom = true;
                    _selectedMinutes = _customMinutes;
                  });
                  _showCustomDurationDialog();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isCustom ? AppTheme.lightSage : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isCustom ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                      width: _isCustom ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCustom ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: _isCustom ? AppTheme.primarySage : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _isCustom ? "Custom ($_customMinutes min)" : "Custom Duration",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: _isCustom ? FontWeight.w600 : FontWeight.w400,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: _isCustom ? AppTheme.primarySage : AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

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
                  child: Text("Begin Session ($_selectedMinutes min)"),
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
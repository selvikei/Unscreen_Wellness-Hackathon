import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;

  late TextEditingController _nameController;
  late String _selectedPronoun;
  late TimeOfDay _wakeUpTime;
  late TimeOfDay _sleepTime;
  late String _selectedRoutine;
  late int _morningMinutes;
  late int _nightMinutes;
  late bool _isStrictModeEnabled;

  final List<String> _pronouns = ['she/her', 'he/him', 'they/them'];
  final List<int> _durations = [15, 30, 45, 60];
  final List<String> _routines = ['When Waking Up', 'Before Sleep', 'Both', 'Custom / Flexible'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _storage.getUserProfile() ??
        UserProfile(
          name: '',
          pronoun: 'they/them',
          wakeUpHour: 7,
          wakeUpMinute: 0,
          sleepHour: 23,
          sleepMinute: 0,
          detoxRoutine: 'Both',
        );

    _nameController = TextEditingController(text: profile.name);
    _selectedPronoun = profile.pronoun;
    _wakeUpTime = TimeOfDay(hour: profile.wakeUpHour, minute: profile.wakeUpMinute);
    _sleepTime = TimeOfDay(hour: profile.sleepHour, minute: profile.sleepMinute);
    _selectedRoutine = profile.detoxRoutine;
    _morningMinutes = profile.morningMinutes;
    _nightMinutes = profile.nightMinutes;
    _isStrictModeEnabled = profile.isStrictModeEnabled;

    setState(() => _isLoading = false);
  }

  Future<void> _pickTime(bool isWakeUp) async {
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

  void _onToggleStrictMode(bool value) {
    if (value) {
      // Prompt user for permission/commitment
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: AppTheme.primarySage),
              SizedBox(width: 8),
              Text("Enable Strict Mode?", style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text(
            "When enabled, launching the app during your scheduled wake-up or bedtime window will immediately start a locked detox timer that cannot be canceled early.",
            style: TextStyle(height: 1.4, color: AppTheme.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primarySage,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () {
                setState(() => _isStrictModeEnabled = true);
                Navigator.pop(ctx);
              },
              child: const Text("I Commit"),
            ),
          ],
        ),
      );
    } else {
      setState(() => _isStrictModeEnabled = false);
    }
  }

  Future<void> _saveSettings() async {
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
      isStrictModeEnabled: _isStrictModeEnabled,
    );

    await _storage.saveUserProfile(profile);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings saved successfully!"),
        backgroundColor: AppTheme.primarySage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primarySage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Profile", style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Strict Mode Permission Card
              Card(
                color: _isStrictModeEnabled ? AppTheme.lightSage.withOpacity(0.4) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _isStrictModeEnabled ? AppTheme.primarySage : const Color(0xFFEFEFEA),
                    width: _isStrictModeEnabled ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _isStrictModeEnabled ? AppTheme.primarySage : AppTheme.lightSage,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              color: _isStrictModeEnabled ? Colors.white : AppTheme.textMuted,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Strict Mode",
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Auto-lock app during scheduled routine",
                                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isStrictModeEnabled,
                            activeColor: AppTheme.primarySage,
                            onChanged: _onToggleStrictMode,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Personal Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEFEA))),
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                children: _pronouns.map((p) {
                  final isSel = _selectedPronoun == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedPronoun = p),
                    selectedColor: AppTheme.lightSage,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: isSel ? AppTheme.primarySage : AppTheme.textDark),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text("Schedule & Routine", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTimeTile("Wake Up", _wakeUpTime.format(context), Icons.wb_sunny_rounded, () => _pickTime(true)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeTile("Sleep Time", _sleepTime.format(context), Icons.nightlight_round, () => _pickTime(false)),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Routine Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEFEFEA)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoutine,
                    isExpanded: true,
                    items: _routines.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRoutine = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Duration selectors
              if (_selectedRoutine == 'When Waking Up' || _selectedRoutine == 'Both') ...[
                _buildDurationOption("Morning Detox Duration", _morningMinutes, (v) => setState(() => _morningMinutes = v)),
                const SizedBox(height: 14),
              ],
              if (_selectedRoutine == 'Before Sleep' || _selectedRoutine == 'Both') ...[
                _buildDurationOption("Night Detox Duration", _nightMinutes, (v) => setState(() => _nightMinutes = v)),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text("Save Changes"),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile(String title, String timeStr, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFEFEA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primarySage),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            Text(timeStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(String title, int currentVal, ValueChanged<int> onSelect) {
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
}
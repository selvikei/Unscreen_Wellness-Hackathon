import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/detox_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late String _selectedPronoun;
  late TimeOfDay _wakeUpTime;
  late TimeOfDay _sleepTime;
  late String _selectedRoutine;
  late int _morningMinutes;
  late int _nightMinutes;
  late bool _isStrictModeEnabled;
  bool _isInit = false;

  final List<String> _pronouns = ['she/her', 'he/him', 'they/them'];
  final List<int> _durations = [15, 30, 45, 60];
  final List<String> _routines = ['When Waking Up', 'Before Sleep', 'Both', 'Custom / Flexible'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final provider = context.watch<DetoxProvider>();
      final profile = provider.userProfile ??
          UserProfile(
            name: '',
            pronoun: 'they/them',
            wakeUpHour: 7,
            wakeUpMinute: 0,
            sleepHour: 23,
            sleepMinute: 0,
            detoxRoutine: 'Both',
            isStrictModeEnabled: false,
          );

      _nameController = TextEditingController(text: profile.name);
      _selectedPronoun = profile.pronoun;
      _wakeUpTime = TimeOfDay(hour: profile.wakeUpHour, minute: profile.wakeUpMinute);
      _sleepTime = TimeOfDay(hour: profile.sleepHour, minute: profile.sleepMinute);
      _selectedRoutine = profile.detoxRoutine;
      _morningMinutes = profile.morningMinutes;
      _nightMinutes = profile.nightMinutes;
      _isStrictModeEnabled = profile.isStrictModeEnabled;
      _isInit = true;
    }
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
            "Strict Mode removes the 'End session' button and shows your allowed apps directly on the timer screen.\n\nOpening any allowed app will invalidate the session (0 minutes saved).\n\nThe timer will keep running.",
            style: TextStyle(height: 1.4, color: AppTheme.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primarySage),
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

  void _showRealAppPickerModal(BuildContext context, DetoxProvider provider) {
    String searchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredApps = provider.installedApps.where((app) {
              return app.name.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Phone Apps",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search installed apps...",
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.background,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFEFEFEA)),
                      ),
                    ),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredApps.isEmpty
                        ? const Center(child: Text("No apps found", style: TextStyle(color: AppTheme.textMuted)))
                        : ListView.separated(
                            itemCount: filteredApps.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2EC)),
                            itemBuilder: (context, index) {
                              final app = filteredApps[index];
                              final isAllowed = provider.allowedPackageNames.contains(app.packageName);

                              return CheckboxListTile(
                                value: isAllowed,
                                activeColor: AppTheme.primarySage,
                                secondary: app.icon != null
                                    ? Image.memory(app.icon!, width: 36, height: 36)
                                    : const Icon(Icons.android, size: 36, color: AppTheme.primarySage),
                                title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                subtitle: Text(
                                  app.packageName,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onChanged: (_) {
                                  provider.toggleAllowedPackage(app.packageName);
                                  setModalState(() {});
                                },
                              );
                            },
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

    await context.read<DetoxProvider>().updateUserProfile(profile);

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
    final provider = context.watch<DetoxProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primarySage)),
      );
    }

    final allowedApps = provider.allowedApps;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  child: Row(
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
                              "Hides 'End session' button & shows allowed apps inline",
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
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Allowed Phone Apps",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                  TextButton.icon(
                    onPressed: () => _showRealAppPickerModal(context, provider),
                    icon: const Icon(Icons.add, size: 18, color: AppTheme.primarySage),
                    label: const Text("Manage", style: TextStyle(color: AppTheme.primarySage, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const Text(
                "Pick installed apps that appear on the timer during Strict Mode. Opening them invalidates the session.",
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: allowedApps.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "No apps whitelisted yet.\nTap 'Manage' to choose installed apps.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allowedApps.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2EC)),
                          itemBuilder: (context, index) {
                            final app = allowedApps[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: app.icon != null
                                  ? Image.memory(app.icon!, width: 32, height: 32)
                                  : const Icon(Icons.android, size: 32, color: AppTheme.primarySage),
                              title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => provider.toggleAllowedPackage(app.packageName),
                              ),
                            );
                          },
                        ),
                ),
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
}
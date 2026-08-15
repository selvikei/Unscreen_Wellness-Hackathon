import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

class StrictCheckResult {
  final bool shouldTrigger;
  final int durationMinutes;
  final String routineType;

  StrictCheckResult({
    required this.shouldTrigger,
    this.durationMinutes = 15,
    this.routineType = '',
  });
}

class StrictModeService {
  final StorageService _storage = StorageService();

  Future<StrictCheckResult> checkStrictMode() async {
    final UserProfile? profile = await _storage.getUserProfile();
    if (profile == null || !profile.isStrictModeEnabled) {
      return StrictCheckResult(shouldTrigger: false);
    }

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = "${now.year}-${now.month}-${now.day}";

    // 1. Morning Window (within 60 mins of wake-up time)
    if (profile.detoxRoutine == 'When Waking Up' || profile.detoxRoutine == 'Both') {
      final morningStart = DateTime(now.year, now.month, now.day, profile.wakeUpHour, profile.wakeUpMinute);
      final morningEnd = morningStart.add(const Duration(minutes: 60));

      if (now.isAfter(morningStart) && now.isBefore(morningEnd)) {
        final alreadyDone = prefs.getBool('strict_morning_done_$todayKey') ?? false;
        if (!alreadyDone) {
          return StrictCheckResult(
            shouldTrigger: true,
            durationMinutes: profile.morningMinutes,
            routineType: 'morning',
          );
        }
      }
    }

    // 2. Night Window (60 mins before sleep time)
    if (profile.detoxRoutine == 'Before Sleep' || profile.detoxRoutine == 'Both') {
      final nightEnd = DateTime(now.year, now.month, now.day, profile.sleepHour, profile.sleepMinute);
      final nightStart = nightEnd.subtract(const Duration(minutes: 60));

      if (now.isAfter(nightStart) && now.isBefore(nightEnd)) {
        final alreadyDone = prefs.getBool('strict_night_done_$todayKey') ?? false;
        if (!alreadyDone) {
          return StrictCheckResult(
            shouldTrigger: true,
            durationMinutes: profile.nightMinutes,
            routineType: 'night',
          );
        }
      }
    }

    return StrictCheckResult(shouldTrigger: false);
  }

  Future<void> markCompleted(String routineType) async {
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('strict_${routineType}_done_$todayKey', true);
  }
}
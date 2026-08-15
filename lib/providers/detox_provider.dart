import 'package:flutter/material.dart';
import '../models/detox_session.dart';
import '../services/storage_service.dart';

class DetoxProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<DetoxSession> _sessions = [];
  bool _isLoading = true;

  final int dailyGoalMinutes = 30;

  List<DetoxSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  DetoxProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _sessions = await _storage.loadSessions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSession({
    required int durationMinutes,
    required String feeling,
  }) async {
    final session = DetoxSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      durationMinutes: durationMinutes,
      completedAt: DateTime.now(),
      feeling: feeling,
    );
    await _storage.saveSession(session);
    _sessions.add(session);
    notifyListeners();
  }

  // --- Calculations ---

  int get todayCompletedMinutes {
    final now = DateTime.now();
    return _sessions
        .where((s) =>
            s.completedAt.year == now.year &&
            s.completedAt.month == now.month &&
            s.completedAt.day == now.day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  double get todayProgress {
    if (dailyGoalMinutes == 0) return 0.0;
    final progress = todayCompletedMinutes / dailyGoalMinutes;
    return progress > 1.0 ? 1.0 : progress;
  }

  int get totalMinutes {
    return _sessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get currentStreakDays {
    if (_sessions.isEmpty) return 0;

    // Collect all distinct dates where a session occurred
    final activeDates = _sessions.map((s) {
      return DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day);
    }).toSet().toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!activeDates.contains(today) && !activeDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = activeDates.contains(today) ? today : yesterday;

    while (activeDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Last 7 days progress: returns Map of Date -> minutes
  Map<DateTime, int> get pastSevenDaysData {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<DateTime, int> data = {};

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final minutes = _sessions
          .where((s) =>
              s.completedAt.year == day.year &&
              s.completedAt.month == day.month &&
              s.completedAt.day == day.day)
          .fold(0, (sum, s) => sum + s.durationMinutes);
      data[day] = minutes;
    }

    return data;
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detox_session.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _sessionsKey = 'unscreen_sessions';
  static const String _onboardingDoneKey = 'unscreen_onboarding_done';
  static const String _userProfileKey = 'unscreen_user_profile';

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingDoneKey) ?? false;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
    await prefs.setBool(_onboardingDoneKey, true);
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userProfileKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<List<DetoxSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_sessionsKey);
    if (data == null || data.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((item) => DetoxSession.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSession(DetoxSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await loadSessions();
    sessions.add(session);

    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, encoded);
  }
}
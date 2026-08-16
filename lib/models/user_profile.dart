class UserProfile {
  final String name;
  final String pronoun;
  final int wakeUpHour;
  final int wakeUpMinute;
  final int sleepHour;
  final int sleepMinute;
  final String detoxRoutine;
  final int morningMinutes;
  final int nightMinutes;
  final bool isStrictModeEnabled;

  UserProfile({
    required this.name,
    required this.pronoun,
    required this.wakeUpHour,
    required this.wakeUpMinute,
    required this.sleepHour,
    required this.sleepMinute,
    required this.detoxRoutine,
    this.morningMinutes = 15,
    this.nightMinutes = 30,
    this.isStrictModeEnabled = false, // Strictly OFF by default
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'pronoun': pronoun,
        'wakeUpHour': wakeUpHour,
        'wakeUpMinute': wakeUpMinute,
        'sleepHour': sleepHour,
        'sleepMinute': sleepMinute,
        'detoxRoutine': detoxRoutine,
        'morningMinutes': morningMinutes,
        'nightMinutes': nightMinutes,
        'isStrictModeEnabled': isStrictModeEnabled,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        pronoun: json['pronoun'] as String? ?? 'they/them',
        wakeUpHour: json['wakeUpHour'] as int? ?? 7,
        wakeUpMinute: json['wakeUpMinute'] as int? ?? 0,
        sleepHour: json['sleepHour'] as int? ?? 23,
        sleepMinute: json['sleepMinute'] as int? ?? 0,
        detoxRoutine: json['detoxRoutine'] as String? ?? 'Both',
        morningMinutes: json['morningMinutes'] as int? ?? 15,
        nightMinutes: json['nightMinutes'] as int? ?? 30,
        isStrictModeEnabled: json['isStrictModeEnabled'] as bool? ?? false, // Defaults to false
      );
}
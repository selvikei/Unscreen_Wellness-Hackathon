class UserProfile {
  final String name;
  final String pronoun; // 'she/her', 'he/him', 'they/them'
  final String wakeUpTime; // e.g. "07:00 AM"
  final String sleepTime; // e.g. "11:00 PM"
  final String detoxRoutine; // 'Before Sleep', 'When Waking Up', 'Both', 'Custom'

  UserProfile({
    required this.name,
    required this.pronoun,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.detoxRoutine,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'pronoun': pronoun,
    'wakeUpTime': wakeUpTime,
    'sleepTime': sleepTime,
    'detoxRoutine': detoxRoutine,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    pronoun: json['pronoun'] as String? ?? 'they/them',
    wakeUpTime: json['wakeUpTime'] as String? ?? '07:00 AM',
    sleepTime: json['sleepTime'] as String? ?? '11:00 PM',
    detoxRoutine: json['detoxRoutine'] as String? ?? 'Both',
  );
}
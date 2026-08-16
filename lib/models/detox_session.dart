class DetoxSession {
  final String id;
  final int durationMinutes;
  final DateTime completedAt;
  final String feeling; // 'Better', 'Same', 'Difficult'

  DetoxSession({
    required this.id,
    required this.durationMinutes,
    required this.completedAt,
    required this.feeling,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'durationMinutes': durationMinutes,
    'completedAt': completedAt.toIso8601String(),
    'feeling': feeling,
  };

  factory DetoxSession.fromJson(Map<String, dynamic> json) => DetoxSession(
    id: json['id'] as String,
    durationMinutes: json['durationMinutes'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
    feeling: json['feeling'] as String,
  );
}
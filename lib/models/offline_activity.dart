import 'package:flutter/material.dart';

class OfflineActivity {
  final String id;
  final String title;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  bool isSelected;

  OfflineActivity({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    this.isSelected = false,
  });

  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily ?? 'MaterialIcons',
        fontPackage: iconFontPackage,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'iconFontPackage': iconFontPackage,
        'isSelected': isSelected,
      };

  factory OfflineActivity.fromJson(Map<String, dynamic> json) => OfflineActivity(
        id: json['id'] as String,
        title: json['title'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        iconFontFamily: json['iconFontFamily'] as String?,
        iconFontPackage: json['iconFontPackage'] as String?,
        isSelected: json['isSelected'] as bool? ?? false,
      );

  // Default preset activities
  static List<OfflineActivity> get defaultActivities => [
        OfflineActivity(
          id: '1',
          title: 'Pray',
          iconCodePoint: Icons.self_improvement_rounded.codePoint,
          isSelected: true,
        ),
        OfflineActivity(
          id: '2',
          title: 'Journaling',
          iconCodePoint: Icons.edit_note_rounded.codePoint,
          isSelected: true,
        ),
        OfflineActivity(
          id: '3',
          title: 'Workout',
          iconCodePoint: Icons.fitness_center_rounded.codePoint,
          isSelected: false,
        ),
        OfflineActivity(
          id: '4',
          title: 'Reading',
          iconCodePoint: Icons.menu_book_rounded.codePoint,
          isSelected: true,
        ),
        OfflineActivity(
          id: '5',
          title: 'Connect with nature',
          iconCodePoint: Icons.park_rounded.codePoint,
          isSelected: false,
        ),
      ];
}
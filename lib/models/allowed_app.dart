import 'package:flutter/material.dart';

class AllowedApp {
  final String id;
  final String name;
  final int iconCodePoint;
  final String category;
  bool isAllowed;

  AllowedApp({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.category,
    this.isAllowed = false,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'category': category,
        'isAllowed': isAllowed,
      };

  factory AllowedApp.fromJson(Map<String, dynamic> json) => AllowedApp(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        category: json['category'] as String,
        isAllowed: json['isAllowed'] as bool? ?? false,
      );

  static List<AllowedApp> get defaultApps => [
        AllowedApp(
          id: 'phone',
          name: 'Phone / Urgent Calls',
          iconCodePoint: Icons.phone_in_talk_rounded.codePoint,
          category: 'Essential',
          isAllowed: true,
        ),
        AllowedApp(
          id: 'messages',
          name: 'Emergency SMS',
          iconCodePoint: Icons.mark_chat_unread_rounded.codePoint,
          category: 'Essential',
          isAllowed: true,
        ),
        AllowedApp(
          id: 'work_email',
          name: 'Work Email',
          iconCodePoint: Icons.mail_outline_rounded.codePoint,
          category: 'Productivity',
          isAllowed: false,
        ),
        AllowedApp(
          id: 'work_chat',
          name: 'Slack / Teams',
          iconCodePoint: Icons.forum_rounded.codePoint,
          category: 'Productivity',
          isAllowed: false,
        ),
        AllowedApp(
          id: 'maps',
          name: 'Navigation & Maps',
          iconCodePoint: Icons.map_rounded.codePoint,
          category: 'Utility',
          isAllowed: false,
        ),
      ];
}
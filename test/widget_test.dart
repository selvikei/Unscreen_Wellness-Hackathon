// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unscreen/models/user_profile.dart';
import 'package:unscreen/providers/detox_provider.dart';
import 'package:unscreen/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen greeting includes saved user name', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'unscreen_user_profile': jsonEncode(UserProfile(
        name: 'Maya',
        pronoun: 'she/her',
        wakeUpHour: 7,
        wakeUpMinute: 0,
        sleepHour: 23,
        sleepMinute: 0,
        detoxRoutine: 'Both',
      ).toJson()),
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DetoxProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Maya'), findsOneWidget);
  });
}

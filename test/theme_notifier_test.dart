import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportwatch_ng/theme_notifier.dart';

void main() {
  group('ThemeNotifier', () {
    test('starts as light mode', () {
      final notifier = ThemeNotifier();

      expect(notifier.isDark, isFalse);
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('toggle switches mode and notifies listeners exactly once', () {
      final notifier = ThemeNotifier();
      var notificationCount = 0;
      notifier.addListener(() {
        notificationCount += 1;
      });

      notifier.toggle();

      expect(notifier.isDark, isTrue);
      expect(notifier.themeMode, ThemeMode.dark);
      expect(notificationCount, 1);
    });
  });
}

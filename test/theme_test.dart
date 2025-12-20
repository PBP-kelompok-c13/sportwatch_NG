import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sportwatch_ng/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'helpers/fake_cookie_request.dart';

void main() {
  final fakeRequest = FakeCookieRequest();
  group('Theme Test', () {
    testWidgets('Verify ThemeData properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(testMode: true, cookieRequestOverride: fakeRequest),
      );
      await tester.pumpAndSettle();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      final ThemeData theme = app.theme!;

      // Verify useMaterial3
      expect(theme.useMaterial3, true);

      // Verify ColorScheme properties
      expect(theme.colorScheme.primary, appPrimaryBlue);
      expect(theme.colorScheme.surface, appSurface);
      expect(theme.colorScheme.onSurface, appPrimaryText);

      // Verify Scaffold Background Color
      expect(theme.scaffoldBackgroundColor, appBackground);

      // Verify AppBarTheme
      expect(theme.appBarTheme.elevation, 0);
      expect(
        theme.appBarTheme.backgroundColor,
        appPrimaryBlue,
      ); // Now Primary Blue
      expect(theme.appBarTheme.foregroundColor, Colors.white); // Now White
      expect(
        theme.appBarTheme.titleTextStyle?.fontFamily,
        GoogleFonts.inter(fontWeight: FontWeight.bold).fontFamily,
      );
      expect(theme.appBarTheme.titleTextStyle?.color, Colors.white);

      // Verify CardTheme
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, appSurface);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      final RoundedRectangleBorder cardShape =
          theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.side.color, appBorder); // Updated constant verification
      expect(cardShape.side.width, 1);
      expect(theme.cardTheme.margin, const EdgeInsets.all(8.0));

      // Verify InputDecorationTheme
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
      final OutlineInputBorder inputBorder =
          theme.inputDecorationTheme.border as OutlineInputBorder;
      expect(
        inputBorder.borderRadius,
        const BorderRadius.all(Radius.circular(12)),
      );
      expect(inputBorder.borderSide.color, appBorder);
      expect(
        theme.inputDecorationTheme.focusedBorder,
        isA<OutlineInputBorder>(),
      );
      final OutlineInputBorder focusedInputBorder =
          theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(focusedInputBorder.borderSide.color, appPrimaryBlue);
      expect(focusedInputBorder.borderSide.width, 2); // Also verify width
      expect(
        theme.inputDecorationTheme.labelStyle?.fontFamily,
        contains('Inter'),
      );
      expect(
        theme.inputDecorationTheme.hintStyle?.fontFamily,
        contains('Inter'),
      );

      // Verify BottomNavigationBarTheme
      expect(theme.bottomNavigationBarTheme.selectedItemColor, appPrimaryBlue);
      expect(
        theme.bottomNavigationBarTheme.unselectedItemColor,
        appSecondaryText,
      );
      expect(theme.bottomNavigationBarTheme.backgroundColor, appSurface);
      expect(
        theme.bottomNavigationBarTheme.type,
        BottomNavigationBarType.fixed,
      );
      expect(theme.bottomNavigationBarTheme.elevation, 0);

      // Verify TextTheme (checking a few examples)
      expect(theme.textTheme.displayLarge?.fontFamily, contains('Inter'));
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Inter'));
      expect(theme.textTheme.bodyMedium?.color, appPrimaryText);

      // Verify fontFamily (checking a few examples)
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Inter'));
    });
  });
}

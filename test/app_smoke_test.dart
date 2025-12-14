import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportwatch_ng/main.dart';

void main() {
  testWidgets('renders home screen with drawer navigation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('News Portal'), findsOneWidget);
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('News'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Scoreboard'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
  });
}

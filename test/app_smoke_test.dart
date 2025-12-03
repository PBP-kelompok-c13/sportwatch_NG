import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportwatch_ng/main.dart';

void main() {
  testWidgets('renders home screen with bottom navigation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sportwatch New Generations'), findsOneWidget);
    expect(find.text('Welcome to Sportwatch NG!'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Scoreboard'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
  });
}

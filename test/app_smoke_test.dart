import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportwatch_ng/main.dart';

void main() {
  testWidgets('renders login screen with expected controls', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text("Don't have an account? Register"), findsOneWidget);
  });
}

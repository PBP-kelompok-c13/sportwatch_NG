import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportwatch_ng/main.dart';
import 'helpers/fake_cookie_request.dart';

void main() {
  late FakeCookieRequest fakeRequest;

  setUp(() {
    fakeRequest = FakeCookieRequest();
  });

  testWidgets('Guest can open login form from the drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(testMode: true, cookieRequestOverride: fakeRequest),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login / Register'), findsOneWidget);
    await tester.tap(find.text('Login / Register'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == "Don't have an account? Register",
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Please fill in all fields'), findsOneWidget);
  });
}

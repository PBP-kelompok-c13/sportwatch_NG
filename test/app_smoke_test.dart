import 'package:flutter_test/flutter_test.dart';
import 'package:sportwatch_ng/main.dart';
import 'helpers/fake_cookie_request.dart';

void main() {
  late FakeCookieRequest fakeRequest;

  setUp(() {
    fakeRequest = FakeCookieRequest();
  });

  testWidgets('renders home screen with drawer navigation', (tester) async {
    await tester.pumpWidget(
      MyApp(testMode: true, cookieRequestOverride: fakeRequest),
    );
    await tester.pumpAndSettle();

    expect(find.text('SportWatch'), findsOneWidget);
    expect(find.text('Welcome, Guest'), findsOneWidget);
    expect(find.text('Hot News'), findsOneWidget);

    await tester.tap(find.text('Login / Register'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}

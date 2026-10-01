import 'package:flutter_test/flutter_test.dart';
import 'package:brew_and_bite/main.dart';
import 'package:brew_and_bite/utils/constants.dart';

void main() {
  testWidgets('App smoke test - verifies Brew & Bite launches',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BrewAndBiteApp());
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}

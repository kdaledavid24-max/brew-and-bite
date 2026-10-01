import 'package:flutter_test/flutter_test.dart';
import 'package:brew_and_bite/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrewAndBiteApp());
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}

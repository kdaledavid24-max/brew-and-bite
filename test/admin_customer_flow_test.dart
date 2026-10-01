import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brew_and_bite/main.dart';
import 'package:brew_and_bite/screens/admin/admin_dashboard.dart';

void main() {
  testWidgets('End-to-End Quick Login and Admin Dashboard Flow Test',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // 1. Launch App
    await tester.pumpWidget(const BrewAndBiteApp());
    await tester.pumpAndSettle();

    // 2. Verify Quick Demo Accounts buttons exist on Login Screen
    expect(find.text('⚡ Local Admin'), findsOneWidget);
    expect(find.text('Kristian (Customer)'), findsOneWidget);

    // 3. Tap Local Admin quick login
    await tester.tap(find.text('⚡ Local Admin'));
    // Pump frames to let async login complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // 4. Verify Admin Dashboard opens and shows Live Order Counters
    expect(find.byType(AdminDashboard), findsOneWidget);
    expect(find.text('Live Order Counters'), findsOneWidget);
    expect(find.text('Live Order Management'), findsOneWidget);

    // 5. Open Live Order Management
    await tester.scrollUntilVisible(
      find.text('Live Order Management'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Live Order Management'));
    await tester.pumpAndSettle();

    // 6. Verify orders appear (ORD-001, ORD-002, ORD-003)
    expect(find.text('ORD-001'), findsOneWidget);
    expect(find.text('ORD-002'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('ORD-003'), findsOneWidget);

    // 7. Verify Filter chips exist
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Pending'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Preparing'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Ready'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Completed'), findsOneWidget);

    // 8. Tap filter "Preparing"
    await tester.tap(find.widgetWithText(ChoiceChip, 'Preparing'));
    await tester.pumpAndSettle();

    // Only ORD-001 is Preparing initially
    expect(find.text('ORD-001'), findsOneWidget);
    expect(find.text('ORD-003'), findsNothing);
  });
}

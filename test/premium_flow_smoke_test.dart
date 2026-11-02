import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mume_music_player/app/router.dart';
import 'package:mume_music_player/app/theme/app_theme.dart';
import 'package:mume_music_player/data/library_store.dart';
import 'package:mume_music_player/data/player_controller.dart';
import 'package:mume_music_player/features/premium/premium_screen.dart';
import 'package:provider/provider.dart';

void main() {
  void dump(String tag) => debugPrint(
      '$tag >>> ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().toList().join(' | ')}');

  Future<void> pumpFlow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(428 * 3, 926 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryStore()),
        ChangeNotifierProvider(create: (_) => PlayerController()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        initialRoute: Routes.premium,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('premium flow walks end to end', (WidgetTester tester) async {
    await pumpFlow(tester);
    dump('START');

    expect(find.text('Subscribe to Premium'), findsOneWidget);
    expect(find.text('\$19.99'), findsOneWidget);

    // Pick the yearly tier, then subscribe.
    await tester.ensureVisible(find.text('\$29.99'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('\$29.99'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subscribe Now'));
    await tester.pumpAndSettle();
    dump('PAYMENT');

    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.text('Google Pay'), findsOneWidget);

    // Add a card through the form.
    await tester.tap(find.text('Add New Card'));
    await tester.pumpAndSettle();
    dump('CARD FORM');
    expect(find.text('Save Card'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, '1234 5678 9012 3456'), '55223344');
    await tester.pump();
    expect(find.text('5522 3344'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, '1234 5678 9012 3456'),
        '5522334444556679');
    await tester.enterText(find.widgetWithText(TextField, 'MM/YY'), '1230');
    await tester.enterText(find.widgetWithText(TextField, '123'), '982');
    await tester.enterText(
        find.widgetWithText(TextField, 'Andrew Ainsley'), 'Andrew Ainsley');
    await tester.pumpAndSettle();

    expect(find.text('A card number has 16 digits'), findsNothing);
    expect(find.text('12/30'), findsNWidgets(2));
    expect(find.text('ANDREW AINSLEY'), findsOneWidget);
    expect(find.text('5522 3344 4455 6679'), findsNWidgets(2));

    await tester.tap(find.text('Save Card'));
    await tester.pumpAndSettle();
    dump('BACK FROM CARD');
    expect(find.text('•••• •••• •••• 6679'), findsOneWidget);

    // Continue into the review board and apply a promo.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    dump('REVIEW');
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('\$29.99'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(TextField, 'Enter code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter code'), 'nope');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('"NOPE" is not valid.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Enter code'), 'MUME10');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Promo (MUME10)'), findsOneWidget);
    expect(find.text('-\$3.00'), findsOneWidget);

    // Swap the payment method from the review board.
    await tester.ensureVisible(find.text('Change'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    dump('CHANGE PAYMENT');
    await tester.tap(find.text('PayPal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    dump('BACK TO REVIEW');
    expect(find.text('PayPal'), findsOneWidget);

    await tester.tap(find.text('Confirm & Pay'));
    await tester.pumpAndSettle();
    dump('SUCCESS');
    expect(find.text('Subscription Successful!'), findsOneWidget);
    expect(find.text('Premium Yearly'), findsOneWidget);

    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Receipt'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enjoy Premium'));
    await tester.pumpAndSettle();
    dump('HOME');
    expect(find.text('Suggested'), findsWidgets);
  });

  testWidgets('premium tiers are selectable models', (WidgetTester tester) async {
    expect(PremiumPlans.byId('yearly').totalLabel, '\$35.98');
    expect(PremiumPlans.byId(null).id, 'monthly');
  });
}

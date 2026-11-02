import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mume_music_player/app/router.dart';
import 'package:mume_music_player/app/theme/app_theme.dart';

void main() {
  testWidgets('router builds card form', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(428 * 3, 926 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      initialRoute: Routes.cardForm,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.pumpAndSettle();
    debugPrint(
      'PROBE: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().toList().join(' | ')}',
    );
  });
}

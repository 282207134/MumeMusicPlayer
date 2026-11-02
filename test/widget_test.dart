import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mume_music_player/app/theme/app_theme.dart';
import 'package:mume_music_player/app/widgets/app_shell.dart';
import 'package:mume_music_player/data/library_store.dart';
import 'package:mume_music_player/data/player_controller.dart';
import 'package:mume_music_player/features/home/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('home shell renders the five library tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryStore()),
        ChangeNotifierProvider(create: (_) => PlayerController()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: MumeScaffold(
          selectedTab: ShellTab.home,
          body: const HomeScreen(),
        ),
      ),
    ));

    expect(find.text('Mume'), findsWidgets);
    for (final tab in ['Suggested', 'Songs', 'Artists', 'Albums', 'Folders']) {
      expect(find.text(tab), findsWidgets);
    }
  });
}

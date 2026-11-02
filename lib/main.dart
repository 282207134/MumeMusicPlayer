import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'data/library_store.dart';
import 'data/player_controller.dart';

void main() => runApp(const MumeApp());

class MumeApp extends StatelessWidget {
  const MumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryStore()),
        ChangeNotifierProvider(create: (_) => PlayerController()),
      ],
      child: Consumer<LibraryStore>(
        builder: (context, store, _) => MaterialApp(
          title: 'Mume',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: Routes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}

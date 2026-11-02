import 'package:flutter/material.dart';

import '../../app/widgets/app_shell.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../playlist/playlists_screen.dart';
import '../settings/settings_screen.dart';

/// Hosts the four destinations behind the floating bar. Deep links push a new
/// host with the wanted tab pre-selected, which is why the artboards show both
/// a back arrow and the nav bar on `25_playlists`.
class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialTab = ShellTab.home});

  final ShellTab initialTab;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late ShellTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return MumeScaffold(
      selectedTab: _tab,
      onTabSelected: (t) => setState(() => _tab = t),
      body: IndexedStack(
        index: _tab.index,
        children: const [
          HomeScreen(),
          FavoritesScreen(),
          PlaylistsScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}

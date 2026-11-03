import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import 'home_tabs.dart';

const _tabs = ['Suggested', 'Songs', 'Artists', 'Albums', 'Folders'];

/// `5..17_Light_home *` — the Home destination: wordmark header, section tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(
    length: _tabs.length,
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            Insets.gapLg,
            Insets.gapMd,
            0,
          ),
          child: AppWordmark(
            onSearch: () => Navigator.of(context).pushNamed(Routes.search),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.gapSm),
          child: UnderlineTabs(tabs: _tabs, controller: _controller),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              SuggestedTab(onArtistsSeeAll: () => _controller.animateTo(2)),
              const SongsTab(),
              const ArtistsTab(),
              const AlbumsTab(),
              const FoldersTab(),
            ],
          ),
        ),
      ],
    );
  }
}

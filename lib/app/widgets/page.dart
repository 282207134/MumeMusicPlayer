import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/library_store.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';

/// Back arrow + page title + trailing actions, the header used by every
/// detail and settings board.
class PageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const PageTopBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.onBack,
    this.bottom,
    this.centerTitle = false,
  });

  final String? title;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final Widget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom == null ? 8 : 56));

  @override
  Widget build(BuildContext context) {
    final bar = bottom;
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      titleSpacing: Insets.page,
      title: title == null
          ? null
          : Text(
              title!,
              style: AppTypography.heading(AppTypography.h4,
                  color: context.inkPrimary),
            ),
      leading: leading ??
          (Navigator.of(context).canPop()
              ? Padding(
                  padding: const EdgeInsets.only(left: Insets.gapSm),
                  child: GhostIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                )
              : null),
      actions: [
        ...actions,
        const SizedBox(width: Insets.gapMd),
      ],
      bottom: bar == null
          ? null
          : PreferredSize(preferredSize: const Size.fromHeight(48), child: bar),
    );
  }
}

/// Standard page: top bar, scrollable body, optional pinned bottom action.
class MumePage extends StatelessWidget {
  const MumePage({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.padding = const EdgeInsets.symmetric(horizontal: Insets.page),
    this.showMiniPlayer = true,
  });

  final Widget body;
  final PageTopBar? topBar;
  final Widget? bottomBar;
  final EdgeInsets padding;
  final bool showMiniPlayer;

  @override
  Widget build(BuildContext context) {
    final footer = bottomBar;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: topBar,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: padding,
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
            ),
            if (footer != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                    Insets.page, Insets.gapMd, Insets.page, Insets.gapLg),
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(top: false, child: footer),
              ),
          ],
        ),
      ),
    );
  }
}

/// Back arrow + the theme dot that every player/settings board prints top-right.
class PageHeaderActions extends StatelessWidget implements PreferredSizeWidget {
  const PageHeaderActions({super.key, this.title});

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryStore>();
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: Insets.gapSm,
      title: title == null
          ? null
          : Text(
              title!,
              style: AppTypography.body(AppTypography.bodyLarge,
                  weight: FontWeight.w600, color: context.inkSoft),
            ),
      leading: Navigator.of(context).canPop()
          ? GhostIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Insets.page),
          child: OutlinedIconButton(
            icon: Icons.circle_outlined,
            tooltip: 'Toggle theme',
            onPressed: () => library.darkMode = !library.darkMode,
          ),
        ),
      ],
    );
  }
}


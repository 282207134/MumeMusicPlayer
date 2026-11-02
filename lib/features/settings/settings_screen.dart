import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';

/// `30_settings` — the Settings tab: premium banner, the settings rows and the
/// `41_quit modal` confirmation. Rendered inside [RootShell], so it paints no
/// bottom navigation of its own.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _setDarkMode(bool value) => context.read<LibraryStore>().darkMode = value;

  Future<void> _openLanguage() async {
    await Navigator.of(context).pushNamed(Routes.language);
    if (mounted) setState(() {});
  }

  Future<void> _quit() async {
    final ok = await confirmDialog(
      context,
      title: 'Are you sure you want to\nquit the app?',
      message: 'Your music will stop and Mume will close.',
      confirmLabel: 'Quit',
      cancelLabel: 'Cancel',
    );
    if (ok) await SystemNavigator.pop();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSheet(String title, List<Widget> body) {
    showMumeSheet(
      context,
      builder: (_) => MumeSheet(title: title, children: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LibraryStore>();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        Insets.page,
        MediaQuery.paddingOf(context).top + Insets.gapLg,
        Insets.page,
        Insets.navBarHeight + Insets.gapXl,
      ),
      children: [
        _Header(
          darkMode: store.darkMode,
          onToggleTheme: () => _setDarkMode(!store.darkMode),
        ),
        const SizedBox(height: Insets.gapXl),
        _PremiumBanner(
          onTap: () => Navigator.of(context).pushNamed(Routes.premium),
        ),
        const SizedBox(height: Insets.gapXl),
        Divider(height: 1, color: context.separatorColor),
        const SizedBox(height: Insets.gapSm),
        SettingTile(
          icon: Icons.upload_rounded,
          label: 'Backup',
          onTap: () => _toast('Scanning your library for new music…'),
        ),
        SettingTile(
          icon: Icons.notifications_rounded,
          label: 'Notification',
          onTap: () => Navigator.of(context).pushNamed(Routes.notification),
        ),
        SettingTile(
          icon: Icons.language_rounded,
          label: 'Language',
          value: store.language,
          onTap: _openLanguage,
        ),
        SettingTile(
          icon: Icons.dark_mode_rounded,
          label: 'Dark Mode',
          onTap: () => _setDarkMode(!store.darkMode),
          trailing: Switch(value: store.darkMode, onChanged: _setDarkMode),
        ),
        SettingTile(
          icon: Icons.send_rounded,
          label: 'Share App',
          onTap: () => Navigator.of(context).pushNamed(Routes.shareApp),
        ),
        SettingTile(
          icon: Icons.history_rounded,
          label: 'Change Log',
          onTap: () => _showSheet('Change Log', _changeLog()),
        ),
        SettingTile(
          icon: Icons.privacy_tip_rounded,
          label: 'Privacy Policy',
          onTap: () => _showSheet('Privacy Policy', _privacy()),
        ),
        SettingTile(
          icon: Icons.help_rounded,
          label: 'FAQ',
          onTap: () => Navigator.of(context).pushNamed(Routes.faq),
        ),
        SettingTile(
          icon: Icons.logout_rounded,
          label: 'Quit',
          destructive: true,
          onTap: _quit,
        ),
      ],
    );
  }

  List<Widget> _changeLog() => [
        for (final entry in const [
          ('v2.4.0', 'Offline lyrics sync, a redesigned mini player and up to 3× faster library scanning.'),
          ('v2.3.1', 'Fixed playback not resuming after a Bluetooth headset reconnects.'),
          ('v2.3.0', 'Added the Folders view, Dark Mode and in-app invites.'),
        ]) ...[
          const SizedBox(height: Insets.gapMd),
          Text(entry.$1,
              style: AppTypography.body(AppTypography.bodyXLarge,
                  weight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: Insets.gapSm),
          Text(entry.$2,
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: context.inkMuted)),
        ],
      ];

  List<Widget> _privacy() => [
        const SizedBox(height: Insets.gapMd),
        for (final line in const [
          'Your music, playlists and settings stay on this device. Mume never uploads the audio files you already own.',
          'If you subscribe to Premium we store your plan and the email you sign in with so we can restore it for you.',
          'Anonymous crash reports may be sent to help us fix bugs — they never contain your media or file names.',
          'You can erase everything Mume keeps locally at any time from Backup → Reset library.',
        ]) ...[
          Text('•  $line',
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: context.inkMuted)),
          const SizedBox(height: Insets.gapLg),
        ],
      ];
}

/// Logo + `Settings` + the circular theme toggle printed top-right.
class _Header extends StatelessWidget {
  const _Header({required this.darkMode, required this.onToggleTheme});

  final bool darkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: 32),
        const SizedBox(width: Insets.gapMd),
        Expanded(
          child: Text(
            'Settings',
            style: AppTypography.heading(
                AppTypography.h4, color: context.inkPrimary),
          ),
        ),
        OutlinedIconButton(
          icon: darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          tooltip: 'Toggle theme',
          onPressed: onToggleTheme,
        ),
      ],
    );
  }
}

/// Orange gradient `Enjoy All Benefits!` card linking to the Premium flow.
class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = constraints.maxWidth * 0.46;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Insets.radiusXl),
          child: Container(
            height: 200,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Insets.radiusXl),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.gradientOrange,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: imageWidth,
                  child: Image.asset(
                    'assets/images/premium_banner.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, imageWidth + 8, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enjoy All Benefits!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.heading(
                            AppTypography.h4, color: AppColors.white),
                      ),
                      const SizedBox(height: Insets.gapSm),
                      Text(
                        'Enjoy listening songs with better audio quality, without restrictions, and without ads.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(AppTypography.bodySmall,
                            color: AppColors.white.withValues(alpha: 0.92)),
                      ),
                      const SizedBox(height: Insets.gapLg),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Insets.gapXl, vertical: Insets.gapMd),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(Insets.radiusPill),
                        ),
                        child: Text(
                          'Get Premium',
                          style: AppTypography.body(AppTypography.bodyMedium,
                              weight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

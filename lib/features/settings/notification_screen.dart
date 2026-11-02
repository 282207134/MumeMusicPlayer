import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';

/// `37_notification` — grouped push switches bound to the store's notify flags.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Notify flags are plain fields, so mirror the change locally for the switch.
  void _write(void Function(LibraryStore store) mutate) {
    mutate(context.read<LibraryStore>());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LibraryStore>();
    return MumePage(
      topBar: const PageTopBar(title: 'Notification'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Insets.gapMd),
          Text(
            'Choose what Mume is allowed to ping you about.',
            style: AppTypography.body(
                AppTypography.bodyLarge, color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gapXl),
          const SectionHeader(title: 'New content'),
          _row(
            icon: Icons.album_rounded,
            label: 'New Album Released',
            value: store.notifyNewAlbum,
            onChanged: (v) => _write((s) => s.notifyNewAlbum = v),
          ),
          _divider(),
          _row(
            icon: Icons.auto_awesome_rounded,
            label: 'Music Recommendations',
            value: store.notifyRecommendations,
            onChanged: (v) => _write((s) => s.notifyRecommendations = v),
          ),
          const SizedBox(height: Insets.gapXl),
          const SectionHeader(title: 'For you'),
          _row(
            icon: Icons.event_rounded,
            label: 'Concerts in Your Area',
            value: store.notifyConcerts,
            onChanged: (v) => _write((s) => s.notifyConcerts = v),
          ),
          _divider(),
          _row(
            icon: Icons.local_offer_rounded,
            label: 'Offers & Promotions',
            value: store.notifyOffers,
            onChanged: (v) => _write((s) => s.notifyOffers = v),
          ),
          const SizedBox(height: Insets.gap2xl),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: context.separatorColor);

  Widget _row({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingTile(
      icon: icon,
      label: label,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

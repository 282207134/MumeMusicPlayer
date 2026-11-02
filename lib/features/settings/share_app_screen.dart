import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';

/// `39_share_app` — invite copy, a primary Share action and a grid of social
/// channels rendered with Material's brand glyphs.
class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  static const _inviteUrl = 'https://mume.app/invite';
  static const _channels = <(IconData, String, Color)>[
    (Icons.chat_rounded, 'WhatsApp', AppColors.green),
    (Icons.alternate_email_rounded, 'Twitter', AppColors.lightBlue),
    (Icons.facebook, 'Facebook', AppColors.blue),
    (Icons.camera_alt_rounded, 'Instagram', AppColors.purple),
    (Icons.mail_outline_rounded, 'Yahoo', AppColors.deepPurple),
    (Icons.music_note_rounded, 'TikTok', AppColors.cyan),
    (Icons.forum_rounded, 'Chat', AppColors.amber),
    (Icons.wechat, 'WeChat', AppColors.teal),
  ];

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _inviteUrl));
    if (context.mounted) {
      _toast(context, 'Invite link copied — pick a channel to send it');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MumePage(
      topBar: const PageTopBar(title: 'Share App'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Insets.gapMd),
          Text(
            'Loved the vibe? Send Mume to a friend.',
            style: AppTypography.heading(
                AppTypography.h5, color: context.inkPrimary),
          ),
          const SizedBox(height: Insets.gapMd),
          Text(
            'Share your invite link and you both unlock a free week of Premium audio the moment they install the app.',
            style:
                AppTypography.body(AppTypography.bodyLarge, color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gapXl),
          PrimaryPillButton(
            label: 'Share',
            icon: Icons.ios_share_rounded,
            onPressed: () => _share(context),
          ),
          const SizedBox(height: Insets.gap2xl),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Insets.gapXl,
            childAspectRatio: 0.78,
            children: [
              for (final (icon, label, color) in _channels)
                _ChannelCell(
                  icon: icon,
                  label: label,
                  color: color,
                  onTap: () => _toast(context, 'Opening $label to share Mume…'),
                ),
            ],
          ),
          const SizedBox(height: Insets.gap2xl),
        ],
      ),
    );
  }
}

class _ChannelCell extends StatelessWidget {
  const _ChannelCell({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Insets.radiusLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: Insets.gapMd),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              AppTypography.bodyMedium,
              weight: FontWeight.w600,
              color: context.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

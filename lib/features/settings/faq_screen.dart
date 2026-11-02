import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/sheets.dart';

/// `40_faq` — searchable accordion of support questions with a rounded card per
/// entry and an orange chevron while expanded.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const _faqs = <(String, String)>[
    (
      'What is Mume Music Player?',
      'Mume is an offline-first player for the audio files already on your device. It groups them into songs, artists, albums and folders and adds playlists, lyrics and a distraction-free player.',
    ),
    (
      'Is Mume free to use?',
      'Yes. Browsing your library, building playlists and the full player are free forever. Premium only adds higher-quality audio, offline sync and an ad-free experience.',
    ),
    (
      'What are the features in Mume?',
      'Local library scanning, smart and manual playlists, artist and album grouping, synced lyrics, a sleep timer, Light and Dark themes, and a mini player that follows you across tabs.',
    ),
    (
      'How can I subscribe to Premium?',
      'Open Settings, tap the orange banner, choose a plan and a payment method, then review and confirm. Your benefits start immediately.',
    ),
    (
      'How do I unsubscribe from Premium?',
      'Go to Settings → Premium → Manage and choose Cancel subscription. You keep every benefit until the end of the current billing period.',
    ),
    (
      'How do I create a playlist?',
      'From Home open Playlists and tap New, give it a name, then add tracks any time with the ⋮ menu on a song row.',
    ),
    (
      'Why can’t Mume find my songs?',
      'Make sure the files are stored on this device and that Mume is allowed to read media. After adding music, re-scan from Settings → Backup.',
    ),
    (
      'Does Mume work without internet?',
      'Completely. Everything you own plays offline; only album artwork and synced lyrics are fetched when you happen to be online.',
    ),
  ];

  String _query = '';
  String? _open = _faqs.first.$1;

  List<(String, String)> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _faqs;
    return _faqs
        .where((f) =>
            f.$1.toLowerCase().contains(q) || f.$2.toLowerCase().contains(q))
        .toList();
  }

  void _contactSupport() {
    showMumeSheet(
      context,
      builder: (_) => MumeSheet(
        title: 'Contact Support',
        children: [
          Text(
            'Tell us what happened and a human from the Mume team replies within one business day.',
            style: AppTypography.body(
                AppTypography.bodyLarge, color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gapXl),
          Text('support@mume.app',
              style: AppTypography.body(AppTypography.bodyXLarge,
                  weight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: Insets.gapSm),
          Text('Mon–Fri, 9:00–18:00 (GMT+1)',
              style: AppTypography.body(
                  AppTypography.bodyMedium, color: context.inkMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return MumePage(
      topBar: const PageTopBar(title: 'FAQ'),
      bottomBar: SizedBox(
        width: double.infinity,
        child: SoftPillButton(
          label: 'Contact Support',
          icon: Icons.headset_mic_rounded,
          onPressed: _contactSupport,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Insets.gapMd),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search_rounded, size: 22),
            ),
          ),
          const SizedBox(height: Insets.gapXl),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.gap2xl),
              child: Text(
                'No answers match “$_query”.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                    AppTypography.bodyLarge, color: context.inkMuted),
              ),
            )
          else
            for (final (question, answer) in items)
              _FaqTile(
                question: question,
                answer: answer,
                expanded: _open == question,
                onTap: () => setState(
                    () => _open = _open == question ? null : question),
              ),
          const SizedBox(height: Insets.gap2xl),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Insets.gapLg),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(Insets.radiusLg),
        border: Border.all(
          color: expanded
              ? AppColors.primary.withValues(alpha: 0.35)
              : context.separatorColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Insets.gapLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: AppTypography.body(
                          AppTypography.bodyXLarge,
                          weight: FontWeight.w700,
                          color: context.inkPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: expanded ? AppColors.primary : context.inkSoft,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: Insets.gapMd),
                          child: Text(
                            answer,
                            style: AppTypography.body(AppTypography.bodyMedium,
                                color: context.inkMuted),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

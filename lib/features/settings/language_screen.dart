import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';

/// `38_language` — pick the app language. The active one gets an orange tick;
/// tapping stores the choice and pops back to Settings.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _suggested = ['English (US)', 'English (UK)'];
  static const _others = [
    '简体中文',
    '日本語',
    '한국어',
    'Español',
    'Français',
    'Deutsch',
    'Português (BR)',
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LibraryStore>();
    return MumePage(
      topBar: const PageTopBar(title: 'Language'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Insets.gapMd),
          const SectionHeader(title: 'Suggested'),
          for (final language in _suggested)
            _tile(context, store, language, dividerAfter: true),
          const SizedBox(height: Insets.gapXl),
          const SectionHeader(title: 'Others'),
          for (final language in _others)
            _tile(context, store, language, dividerAfter: true),
          const SizedBox(height: Insets.gap2xl),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    LibraryStore store,
    String language, {
    required bool dividerAfter,
  }) {
    final selected = store.language == language;
    return Column(
      children: [
        InkWell(
          onTap: () {
            store.language = language;
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w600,
                      color: context.inkPrimary,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
              ],
            ),
          ),
        ),
        if (dividerAfter) Divider(height: 1, color: context.separatorColor),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../app/widgets/app_shell.dart';
import '../features/album/album_details_screen.dart';
import '../features/artist/artist_details_screen.dart';
import '../features/folders/folder_details_screen.dart';
import '../features/home/recently_played_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/walkthrough_screen.dart';
import '../features/player/player_screen.dart';
import '../features/playlist/add_to_playlist_screen.dart';
import '../features/playlist/new_playlist_screen.dart';
import '../features/playlist/playlist_details_screen.dart';
import '../features/premium/card_form_screen.dart';
import '../features/premium/payment_method_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/premium/review_summary_screen.dart';
import '../features/premium/subscription_success_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/faq_screen.dart';
import '../features/settings/language_screen.dart';
import '../features/settings/notification_screen.dart';
import '../features/settings/share_app_screen.dart';
import '../features/shell/root_shell.dart';

/// Arguments accepted by the detail routes.
@immutable
class MediaArgs {
  const MediaArgs(this.id, {this.extra});

  final String id;
  final String? extra;
}

abstract final class Routes {
  static const splash = '/';
  static const walkthrough = '/walkthrough';
  static const home = '/home';
  static const favorites = '/favorites';
  static const playlists = '/playlists';
  static const settings = '/settings';
  static const search = '/search';
  static const player = '/player';
  static const lyrics = '/player/lyrics';
  static const recentlyPlayed = '/recently-played';
  static const artist = '/artist';
  static const album = '/album';
  static const folder = '/folder';
  static const playlist = '/playlist';
  static const newPlaylist = '/playlists/new';
  static const addToPlaylist = '/playlists/pick';
  static const notification = '/settings/notification';
  static const language = '/settings/language';
  static const shareApp = '/settings/share';
  static const faq = '/settings/faq';
  static const premium = '/premium';
  static const paymentMethod = '/premium/payment';
  static const cardForm = '/premium/payment/card';
  static const reviewSummary = '/premium/review';
  static const subscriptionDone = '/premium/success';
}

abstract final class AppRouter {
  static Route<void> _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;
    final id = args is MediaArgs ? args.id : (args is String ? args : '');

    return switch (name) {
      Routes.splash => _page(const SplashScreen(), settings),
      Routes.walkthrough => _page(const WalkthroughScreen(), settings),
      Routes.home => _page(const RootShell(), settings),
      Routes.favorites =>
        _page(const RootShell(initialTab: ShellTab.favorites), settings),
      Routes.playlists =>
        _page(const RootShell(initialTab: ShellTab.playlists), settings),
      Routes.settings =>
        _page(const RootShell(initialTab: ShellTab.settings), settings),
      Routes.search => _page(const SearchScreen(), settings),
      Routes.player => _page(const PlayerScreen(), settings),
      Routes.lyrics => _page(const LyricsScreen(), settings),
      Routes.recentlyPlayed => _page(const RecentlyPlayedScreen(), settings),
      Routes.artist => _page(ArtistDetailsScreen(artistId: id), settings),
      Routes.album => _page(AlbumDetailsScreen(albumId: id), settings),
      Routes.folder => _page(FolderDetailsScreen(folderId: id), settings),
      Routes.playlist => _page(PlaylistDetailsScreen(playlistId: id), settings),
      Routes.newPlaylist =>
        _page(NewPlaylistScreen(playlistId: args is MediaArgs ? args.id : null),
            settings),
      Routes.addToPlaylist =>
        _page(AddToPlaylistScreen(songId: id), settings),
      Routes.notification => _page(const NotificationScreen(), settings),
      Routes.language => _page(const LanguageScreen(), settings),
      Routes.shareApp => _page(const ShareAppScreen(), settings),
      Routes.faq => _page(const FaqScreen(), settings),
      Routes.premium => _page(const PremiumScreen(), settings),
      Routes.paymentMethod => _page(const PaymentMethodScreen(), settings),
      Routes.cardForm => _page(const CardFormScreen(), settings),
      Routes.reviewSummary => _page(const ReviewSummaryScreen(), settings),
      Routes.subscriptionDone =>
        _page(const SubscriptionSuccessScreen(), settings),
      _ => _page(_UnknownRoute(name: name), settings),
    };
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text('No route named ${name ?? '?'}')),
      );
}

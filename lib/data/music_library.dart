import 'models/media.dart';

/// Seed catalogue for the UI. Track names mirror the copy used on the
/// `Mume - Music Player App UI Kit` artboards; covers are the image assets
/// lifted from the same file.
abstract final class MusicLibrary {
  static const _coverAssets = [
    'assets/images/covers/starboy.png',
    'assets/images/covers/song_2.png',
    'assets/images/covers/song_3.png',
    'assets/images/covers/song_4.png',
    'assets/images/covers/song_5.png',
    'assets/images/covers/song_6.png',
    'assets/images/covers/song_7.png',
    'assets/images/covers/sug_1.png',
    'assets/images/covers/sug_2.png',
    'assets/images/covers/sug_3.png',
    'assets/images/covers/sug_4.png',
    'assets/images/covers/sug_5.png',
    'assets/images/covers/sug_6.png',
    'assets/images/covers/pl_1.png',
    'assets/images/covers/pl_2.png',
    'assets/images/covers/pl_3.png',
    'assets/images/covers/pl_4.png',
    'assets/images/covers/pl_5.png',
    'assets/images/covers/pl_6.png',
  ];

  static String cover(int index) => _coverAssets[index % _coverAssets.length];

  static final List<Song> songs = <Song>[
    _s(0, 'Starboy', 'The Weeknd, Daft Punk', 'Starboy', 230, 1, 2016),
    _s(1, 'Disaster', 'Conan Gray', 'Superache', 238, 2, 2022),
    _s(2, 'HANDSOME', 'Warren Hue', 'HANDSOME', 285, 3, 2023),
    _s(3, 'Sharks', 'Imagine Dragons', 'Loom', 323, 4, 2024),
    _s(4, 'Fly Me To The Sun', 'Romantic Echoes', 'Solar Drift', 260, 5, 2023),
    _s(5, 'The Bended Man', 'Sunwich', 'Quiet Hours', 228, 6, 2021),
    _s(6, 'Shades of Love', 'Ania Szarmach', 'Shades of Love', 214, 7, 2022),
    _s(7, 'Without You', 'The Kid LAROI', 'F*CK LOVE 3', 149, 8, 2021),
    _s(8, 'Save Your Tears', 'The Weeknd', 'After Hours', 286, 9, 2020),
    _s(9, 'Take My Breath', 'The Weeknd', 'After Hours', 220, 10, 2021),
    _s(10, 'A Tale by Quincy', 'The Weeknd', 'Echoes of Dawn', 198, 11, 2020),
    _s(11, 'Out of Time', 'The Weeknd', 'After Hours', 273, 12, 2022),
    _s(12, 'positions', 'Ariana Grande', 'positions', 172, 13, 2020),
    _s(13, 'thank u, next', 'Ariana Grande', 'thank u, next', 207, 14, 2018),
    _s(14, '7 rings', 'Ariana Grande', 'thank u, next', 178, 15, 2019),
    _s(15, 'Into You', 'Ariana Grande', 'Dangerous Woman', 244, 16, 2016),
    _s(16, 'ACID TRAP', 'Acidrap', 'Acidrap', 195, 17, 2024),
    _s(17, 'Neon Hollow', 'Acidrap', 'Acidrap', 211, 18, 2024),
    _s(18, 'Blinding Lights', 'The Weeknd', 'After Hours', 200, 19, 2020),
    _s(19, 'Sweater Weather', 'The Neighbourhood', 'I Love You.', 240, 20, 2013),
    _s(20, 'Electric Feel', 'MGMT', 'Oracular Spectacular', 229, 21, 2007),
    _s(21, 'Nightcall', 'Kavinsky', 'OutRun', 258, 22, 2013),
    _s(22, 'Resonance', 'HOME', 'Odyssey', 212, 23, 2014),
    _s(23, 'After Dark', 'Mr. Kitty', 'Eternity', 251, 24, 2017),
    _s(24, 'Somewhere Someone', 'Ryan Jones', 'Pain', 189, 25, 2023),
    _s(25, 'Pain', 'Ryan Jones', 'Pain', 233, 26, 2023),
    _s(26, 'Memories of Love', 'Quincy', 'Memories', 246, 27, 2019),
    _s(27, 'Acoustic Morning', 'Lewis Park', 'Acoustic Sessions', 205, 28, 2018),
    _s(28, 'Slow Dancing', 'Sunwich', 'Quiet Hours', 267, 29, 2021),
    _s(29, 'Paper Planes', 'Romantic Echoes', 'Solar Drift', 194, 30, 2023),
    _s(30, 'Colour Outside the Lines', 'Conan Gray', 'Superache', 219, 31, 2022),
    _s(31, 'Ceilings', 'LOLL', 'Ceilings', 176, 32, 2022),
  ];

  static Song _s(
    int i,
    String title,
    String artist,
    String album,
    int seconds,
    int track,
    int year,
  ) =>
      Song(
        id: 's$i',
        title: title,
        artist: artist,
        album: album,
        duration: Duration(seconds: seconds),
        cover: cover(i),
        trackNumber: track,
        releaseYear: year,
      );

  static Song songById(String id) =>
      songs.firstWhere((s) => s.id == id, orElse: () => songs.first);

  static List<Song> songsByIds(Iterable<String> ids) =>
      ids.map(songById).toList(growable: false);

  static final List<Artist> artists = <Artist>[
    Artist(
      id: 'a0',
      name: 'Ariana Grande',
      cover: 'assets/images/covers/artist_1.png',
      songIds: const ['s12', 's13', 's14', 's15'],
      albumIds: const ['al3', 'al4'],
    ),
    Artist(
      id: 'a1',
      name: 'The Weeknd',
      cover: 'assets/images/covers/artist_2.png',
      songIds: const ['s0', 's8', 's9', 's10', 's11', 's18'],
      albumIds: const ['al0', 'al1', 'al2'],
    ),
    Artist(
      id: 'a2',
      name: 'Acidrap',
      cover: 'assets/images/covers/artist_3.png',
      songIds: const ['s16', 's17'],
      albumIds: const ['al5'],
    ),
    Artist(
      id: 'a3',
      name: 'Conan Gray',
      cover: 'assets/images/covers/sug_4.png',
      songIds: const ['s1', 's30'],
      albumIds: const ['al6'],
    ),
    Artist(
      id: 'a4',
      name: 'Imagine Dragons',
      cover: 'assets/images/covers/sug_5.png',
      songIds: const ['s3'],
      albumIds: const ['al7'],
    ),
    Artist(
      id: 'a5',
      name: 'Ryan Jones',
      cover: 'assets/images/covers/sug_6.png',
      songIds: const ['s24', 's25'],
      albumIds: const ['al8'],
    ),
  ];

  static Artist artistById(String id) =>
      artists.firstWhere((a) => a.id == id, orElse: () => artists.first);

  static final List<Album> albums = <Album>[
    _album('al0', 'Starboy', 'a1', 1, const ['s0']),
    _album('al1', 'After Hours', 'a1', 8, const ['s8', 's9', 's11', 's18']),
    _album('al2', 'Echoes of Dawn', 'a1', 10, const ['s10']),
    _album('al3', 'positions', 'a0', 12, const ['s12']),
    _album('al4', 'thank u, next', 'a0', 13, const ['s13', 's14', 's15']),
    _album('al5', 'Acidrap', 'a2', 16, const ['s16', 's17']),
    _album('al6', 'Superache', 'a3', 1, const ['s1', 's30']),
    _album('al7', 'Loom', 'a4', 3, const ['s3']),
    _album('al8', 'Pain', 'a5', 24, const ['s24', 's25']),
  ];

  static Album _album(String id, String title, String artistId, int coverIndex,
      List<String> songIds) {
    final artist = artistById(artistId);
    return Album(
      id: id,
      title: title,
      artist: artist.name,
      cover: cover(coverIndex),
      songIds: songIds,
      year: MusicLibrary.songById(songIds.first).releaseYear,
    );
  }

  static Album albumById(String id) =>
      albums.firstWhere((a) => a.id == id, orElse: () => albums.first);

  /// The album that lists [song], falling back to a same-titled single.
  static Album albumOfSong(Song song) => albums.firstWhere(
        (a) => a.songIds.contains(song.id),
        orElse: () => Album(
          id: 'single-${song.id}',
          title: song.album,
          artist: song.artist,
          cover: song.cover,
          songIds: [song.id],
          year: song.releaseYear,
        ),
      );

  /// The artist whose name opens [song]'s credit line.
  static Artist artistOfSong(Song song) {
    final credit = song.artist.split(RegExp('[,&]')).first.trim().toLowerCase();
    return artists.firstWhere(
      (a) => a.name.toLowerCase() == credit,
      orElse: () => Artist(
        id: 'artist-${song.id}',
        name: song.artist,
        cover: song.cover,
        songIds: [song.id],
        albumIds: const [],
      ),
    );
  }

  static List<Album> albumsOf(String artistId) =>
      albums.where((a) => artistById(artistId).albumIds.contains(a.id)).toList();

  static List<Playlist> initialPlaylists() => <Playlist>[
        Playlist(
            id: 'p0',
            name: 'My Favorite Songs',
            cover: cover(13),
            songIds: const ['s2', 's6', 's12', 's19', 's22'],
            createdOrder: 0),
        Playlist(
            id: 'p1',
            name: '90s Old Song',
            cover: cover(7),
            songIds: const ['s20', 's21'],
            createdOrder: 1),
        Playlist(
            id: 'p2',
            name: 'Legend Rock Song',
            cover: cover(15),
            songIds: const ['s19', 's23'],
            createdOrder: 2),
        Playlist(
            id: 'p3',
            name: 'My Favorite Acoustic Song',
            cover: cover(3),
            songIds: const ['s27', 's28'],
            createdOrder: 3),
        Playlist(
            id: 'p4',
            name: 'Memories of Love',
            cover: cover(10),
            songIds: const ['s26', 's4'],
            createdOrder: 4),
        Playlist(
            id: 'p5',
            name: 'Pain - Ryan Jones',
            cover: cover(17),
            songIds: const ['s24', 's25'],
            createdOrder: 5),
      ];

  static List<Folder> get folders => const <Folder>[
        Folder(
            id: 'f0',
            name: 'Download',
            path: 'Internal storage/Download',
            songIds: ['s0', 's1', 's2', 's3'],
            subfolderCount: 2),
        Folder(
            id: 'f1',
            name: 'Music',
            path: 'Internal storage/Music',
            songIds: ['s4', 's5', 's6', 's7', 's8'],
            subfolderCount: 4),
        Folder(
            id: 'f2',
            name: 'Podcasts',
            path: 'Internal storage/Podcasts',
            songIds: ['s9', 's10'],
            subfolderCount: 0),
        Folder(
            id: 'f3',
            name: 'Ringtones',
            path: 'Internal storage/Ringtones',
            songIds: ['s11', 's12', 's13'],
            subfolderCount: 1),
        Folder(
            id: 'f4',
            name: 'Audiobooks',
            path: 'SD card/Audiobooks',
            songIds: ['s14', 's15'],
            subfolderCount: 3),
      ];

  static Folder folderById(String id) =>
      folders.firstWhere((f) => f.id == id, orElse: () => folders.first);

  /// The headline counts the artboards print; the seed list is a slice of them.
  static const songCountLabel = '560 songs';
  static const playlistCountLabel = '14 playlists';

  static List<Song> get recentlyPlayed =>
      songsByIds(const ['s7', 's8', 's0', 's12', 's3', 's19']);

  static List<Song> get mostPlayed =>
      songsByIds(const ['s0', 's8', 's13', 's22', 's18', 's26']);

  static List<Song> get suggested =>
      songsByIds(const ['s6', 's7', 's8', 's0', 's3', 's12']);

  static List<String> get initialRecentSearches => const [
        'Ariana Grande',
        'Morgan Wallen',
        'Justin Bieber',
        'Drake',
        'Olivia Rodrigo',
        'The Weeknd',
        'Taylor Swift',
        'Juice Wrld',
        'Memories',
      ];

  static List<String> lyricsFor(Song song) => switch (song.id) {
        's0' => _starboyLyrics,
        _ => _genericLyrics(song),
      };

  static const _starboyLyrics = <String>[
    "Let a nigga brag Pitt",
    'Legend of the fall took the year like a bandit',
    'Bought mama a crib and a brand new wagon',
    'Now she hit the grocery shop looking lavish',
    'Star Trek roof in that Wraith of Khan',
    'Girls get loose when they hear this song',
    'One hundred and fifteen in the Swish-Lo',
    'I got good things going on this evening',
    "I'm in the kitchen dancing to that swimming pool",
    'Oakwood diamonds on me is a sure sight',
    'Flowers from the rose because I like to bloomin',
  ];

  static List<String> _genericLyrics(Song song) => <String>[
        '${song.title} — ${song.artist}',
        'Turn the lights down low, let the record spin',
        'Every line you sing feels like it came from within',
        'We drive through the night with the windows down',
        'Chasing something we cannot name',
        'Hold on to the sound, hold on to the feeling',
        'Nothing here is what it seems to be',
        'So play it one more time before the morning',
        'Before the morning takes it all away',
      ];
}

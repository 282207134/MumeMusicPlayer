class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.cover,
    this.trackNumber = 0,
    this.releaseYear,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String cover;
  final int trackNumber;
  final int? releaseYear;

  String get durationLabel => formatClock(duration);
}

class Album {
  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.cover,
    required this.songIds,
    this.year,
  });

  final String id;
  final String title;
  final String artist;
  final String cover;
  final List<String> songIds;
  final int? year;
}

class Artist {
  const Artist({
    required this.id,
    required this.name,
    required this.cover,
    required this.songIds,
    required this.albumIds,
  });

  final String id;
  final String name;
  final String cover;
  final List<String> songIds;
  final List<String> albumIds;
}

class Playlist {
  Playlist({
    required this.id,
    required this.name,
    required this.cover,
    List<String>? songIds,
    this.createdOrder = 0,
  }) : songIds = songIds ?? <String>[];

  final String id;
  final String name;
  final String cover;
  final List<String> songIds;
  final int createdOrder;
}

class Folder {
  const Folder({
    required this.id,
    required this.name,
    required this.path,
    required this.songIds,
    required this.subfolderCount,
  });

  final String id;
  final String name;
  final String path;
  final List<String> songIds;
  final int subfolderCount;
}

/// `03:50` — the format every artboard uses for track lengths.
String formatClock(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$minutes:$seconds';
  return '$minutes:$seconds';
}

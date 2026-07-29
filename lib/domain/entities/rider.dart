class Rider {
  final int id;
  final String name;
  final String username;
  final String email;
  /// Account type, e.g. "rider". Informational only today.
  final String type;
  /// Absolute URL to the rider's photo, or empty when none is set.
  final String photoUrl;

  const Rider({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.type = '',
    this.photoUrl = '',
  });

  bool get hasPhoto => photoUrl.trim().isNotEmpty;
}

class Song {
  final String id;
  final String userId;
  final String title;
  final String artist;
  final String description;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Song({
    required this.id,
    required this.userId,
    required this.title,
    this.artist = '',
    required this.description,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'description': description,
      'image_url': imageUrl,
      if (userId.isNotEmpty) 'user_id': userId,
    };
  }

  Song copyWith({
    String? id,
    String? userId,
    String? title,
    String? artist,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Song(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

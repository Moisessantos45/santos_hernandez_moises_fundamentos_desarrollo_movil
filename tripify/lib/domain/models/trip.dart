class Trip {
  final String id;
  final String title;
  final String location;
  final String country;
  final double price;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String category;
  final String description;
  final List<String> highlights;
  final bool isFavorite;

  const Trip({
    required this.id,
    required this.title,
    required this.location,
    required this.country,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.highlights,
    this.isFavorite = false,
  });

  Trip copyWith({
    String? id,
    String? title,
    String? location,
    String? country,
    double? price,
    double? rating,
    int? reviewsCount,
    String? imageUrl,
    String? category,
    String? description,
    List<String>? highlights,
    bool? isFavorite,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      country: country ?? this.country,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

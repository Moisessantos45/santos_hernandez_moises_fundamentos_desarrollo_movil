import 'package:latlong2/latlong.dart';

class Place {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.createdAt,
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      imageUrl: json['image_url']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
    };
    if (!isUpdate && userId.isNotEmpty) {
      data['user_id'] = userId;
    }
    return data;
  }

  Place copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    double? latitude,
    double? longitude,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Place(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

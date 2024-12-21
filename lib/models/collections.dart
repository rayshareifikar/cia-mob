import 'place.dart';

class Collection {
  final int id;
  final String name;
  final String createdAt;
  final int userId;
  final List<Place> places; // Add places list

  Collection({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.userId,
    required this.places,
  });

  /// Factory constructor to parse JSON into a Collection object
  factory Collection.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>;
    return Collection(
      id: json['pk'] ?? 0, // Map `pk` to `id`
      name: fields['name'] ?? 'Unknown', // Extract `name` from `fields`
      createdAt: fields['created_at'] ?? '', // Extract `created_at` from `fields`
      userId: fields['user'] ?? 0, // Extract `user` from `fields`
      places: (fields['places'] as List<dynamic>?) // Parse nested places list
              ?.map((placeJson) => Place.fromJson(placeJson))
              .toList() ??
          [], // Default to empty list if null
    );
  }

  /// Convert Collection object to JSON
  Map<String, dynamic> toJson() {
    return {
      'pk': id, // Convert `id` to `pk`
      'fields': {
        'name': name,
        'created_at': createdAt,
        'user': userId,
        'places': places.map((place) => place.toJson()).toList(), // Include places
      },
    };
  }
}

class CollectionItem {
  final int collectionId;
  final int placeId;

  CollectionItem({
    required this.collectionId,
    required this.placeId,
  });

  /// Factory constructor to parse JSON into a CollectionItem object
  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      collectionId: json['collection'] ?? 0, // Extract `collection` ID
      placeId: json['place'] ?? 0, // Extract `place` ID
    );
  }

  /// Convert CollectionItem object to JSON
  Map<String, dynamic> toJson() {
    return {
      'collection': collectionId,
      'place': placeId,
    };
  }
}

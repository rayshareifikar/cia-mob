// To parse this JSON data, do
//
//     final place = placeFromJson(jsonString);

import 'dart:convert';

Place placeFromJson(String str) => Place.fromJson(json.decode(str));

String placeToJson(Place data) => json.encode(data.toJson());

class Place {
    int id;
    String name;
    String description;
    int averageRating;
    List<Comment> comments;
    List<Souvenir> souvenirs;

    Place({
        required this.id,
        required this.name,
        required this.description,
        required this.averageRating,
        required this.comments,
        required this.souvenirs,
    });

    factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        averageRating: json["average_rating"],
        comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
        souvenirs: List<Souvenir>.from(json["souvenirs"].map((x) => Souvenir.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "average_rating": averageRating,
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "souvenirs": List<dynamic>.from(souvenirs.map((x) => x.toJson())),
    };
}

class Comment {
    int id;
    String username;
    String content;
    int rating;
    DateTime createdAt;

    Comment({
        required this.id,
        required this.username,
        required this.content,
        required this.rating,
        required this.createdAt,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        username: json["username"],
        content: json["content"],
        rating: json["rating"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "content": content,
        "rating": rating,
        "created_at": createdAt.toIso8601String(),
    };
}

class Souvenir {
    int id;
    String name;
    int price;
    int stock;

    Souvenir({
        required this.id,
        required this.name,
        required this.price,
        required this.stock,
    });

    factory Souvenir.fromJson(Map<String, dynamic> json) => Souvenir(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        stock: json["stock"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "stock": stock,
    };
}

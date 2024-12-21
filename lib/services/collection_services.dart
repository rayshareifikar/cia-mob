import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import '../models/collections.dart';
import '../models/place.dart';
import 'package:http/http.dart' as http;

class CollectionService {
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<Collection>> fetchCollections(CookieRequest request) async {
    final response = await request.get('$baseUrl/placeCollection/json/');
    if (response.isNotEmpty && response is List) {
      return response.map((json) => Collection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch collections');
    }
  }

Future<void> createCollection(CookieRequest request, String name) async {
  try {
    print('Attempting to create collection with name: $name'); // Debug print

    final response = await request.post(
      '$baseUrl/placeCollection/create_collection_json/',
      {
        'name': name,
      },
    );

    print('Response received: $response'); // Debug print

    if (response['success'] == true) {
      print('Collection created: ${response['collection']}');
      // Handle successful creation
    } else {
      print('Failed to create collection: ${response['error']}');
      throw Exception(response['error'] ?? 'Unknown error');
    }
  } catch (e) {
    print('Error creating collection: $e');
    rethrow;
  }
}


  Future<void> deleteCollection(CookieRequest request, int collectionId) async {
    final response = await request.post(
      '$baseUrl/placeCollection/delete/$collectionId/',
      {'_method': 'DELETE'},
    );

    if (!response['success']) {
      throw Exception('Failed to delete collection: ${response['error']}');
    }
  }

Future<List<Place>> fetchCollectionPlaces(int collectionId, CookieRequest request) async {
  final response = await request.get('$baseUrl/placeCollection/$collectionId/places/json/');

  if (response['error'] == null) {
    // Assume the response is a list of places
    List<dynamic> jsonData = response['places']; // Adjust based on your API response
    return jsonData.map((placeJson) => Place.fromJson(placeJson)).toList();
  } else {
    throw Exception('Failed to load collection places: ${response['error']}');
  }
}

}

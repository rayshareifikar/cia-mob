// place_service.dart
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/place.dart';

class PlaceService {
  final CookieRequest request;

  PlaceService(this.request);

  Future<Place> fetchPlaceDetail(int placeId) async {
    final url = 'http://localhost:8000/places/$placeId/json/';
    final response = await request.get(url);
    return Place.fromJson(response);
  }

  Future<bool> addComment(int placeId, String content, int rating) async {
    // Set the AJAX header before calling post()
    request.headers['X-Requested-With'] = 'XMLHttpRequest';

    final response = await request.post(
      'http://localhost:8000/places/add_comment/$placeId/',
      {
        'comment': content,
        'rating': rating.toString(),
      },
    );

    if (response['error'] != null) {
      throw Exception(response['error']);
    }
    return true;
  }
}

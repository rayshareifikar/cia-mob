// lib/screens/place_detail_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:mlaku_mlaku/services/place_service.dart';
import 'package:mlaku_mlaku/models/place.dart';

class PlaceDetailPage extends StatefulWidget {
  final int placeId;

  const PlaceDetailPage({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  late PlaceService _placeService;
  Future<Place>? _placeFuture;

  final _commentController = TextEditingController();
  int _rating = 0; // rating from 1 to 5
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _placeService = PlaceService(request);
    _loadPlaceDetail();
  }

  void _loadPlaceDetail() {
    setState(() {
      _placeFuture = _placeService.fetchPlaceDetail(widget.placeId);
    });
  }

  Future<void> _submitComment() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      // Add print statements to debug
      final data = {
        'comment': _commentController.text.trim(),
        'rating': _rating,
      };
      print('Sending data: ${jsonEncode(data)}'); // Debug print

      final response = await request.postJson(
        "http://127.0.0.1:8000/places/add-comment-dart/${widget.placeId}/",
        jsonEncode(data),
      );
      print('Response received: $response'); // Debug print

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully!')),
      );
      _commentController.clear();
      _rating = 0;
      _loadPlaceDetail();
    } catch (e) {
      print('Error details: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            starIndex <= _rating ? Icons.star : Icons.star_border,
            color: Colors.yellow[700],
          ),
          onPressed: () {
            setState(() {
              _rating = starIndex;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context);
    final isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Detail'),
      ),
      body: FutureBuilder<Place>(
        future: _placeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading place: ${snapshot.error}'));
          }

          final place = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Average Rating: ${place.averageRating}/5'),
                  const SizedBox(height: 8),
                  Text(place.description),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (place.comments.isEmpty)
                    const Text('No comments yet. Be the first to comment!'),
                  for (var c in place.comments) ...[
                    ListTile(
                      title: Text(c.username),
                      subtitle: Text(c.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${c.rating}/5'),
                          Icon(Icons.star, color: Colors.yellow[700], size: 20),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                  const SizedBox(height: 16),
                  const Text('Souvenirs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (place.souvenirs.isEmpty)
                    const Text('No souvenirs available.'),
                  for (var s in place.souvenirs) ...[
                    ListTile(
                      title: Text(s.name),
                      subtitle: Text('Price: ${s.price}, Stock: ${s.stock}'),
                    ),
                    const Divider(),
                  ],
                  if (isLoggedIn) ...[
                    const SizedBox(height: 16),
                    const Text('Add a Comment', style: TextStyle(fontWeight: FontWeight.bold)),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Write your comment...',
                            ),
                            maxLines: 3,
                            validator: (value) => value!.isEmpty ? 'Comment cannot be empty' : null,
                          ),
                          const SizedBox(height: 8),
                          const Text('Your Rating:'),
                          _buildRatingStars(),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _submitComment,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const Text('Please log in to add a comment.'),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
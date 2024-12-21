import 'package:flutter/material.dart';
import '../../models/place.dart';
import '../../services/collection_services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CollectionPlacesScreen extends StatefulWidget {
  final int collectionId;
  final String collectionName;

  const CollectionPlacesScreen({
    Key? key,
    required this.collectionId,
    required this.collectionName,
  }) : super(key: key);

  @override
  _CollectionPlacesScreenState createState() => _CollectionPlacesScreenState();
}

class _CollectionPlacesScreenState extends State<CollectionPlacesScreen> {
  final CollectionService _collectionService = CollectionService();
  List<Place> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    final request = context.read<CookieRequest>(); // Get CookieRequest from Provider
    try {
      final places = await _collectionService.fetchCollectionPlaces(widget.collectionId, request);
      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _places.isEmpty
              ? const Center(child: Text('No places in this collection.'))
              : ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150', // Replace with actual image URL
                          ),
                        ),
                        title: Text(place.name),
                        subtitle: Text(place.description),
                      ),
                    );
                  },
                ),
    );
  }
}

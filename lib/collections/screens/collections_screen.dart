import 'package:flutter/material.dart';
import 'package:mlaku_mlaku/journal/screens/journal_home.dart';
import '../../models/collections.dart';
import 'collection_places_screen.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/collection_services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

extension ListExtensions<T> on List<T> {
  void addIf(bool condition, T value) {
    if (condition) add(value);
  }
}

class CollectionsScreen extends StatefulWidget {
  final List<Collection> collections;
  final CookieRequest request;

  const CollectionsScreen({super.key, required this.collections, required this.request});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  late List<Collection> collections;

  @override
  void initState() {
    super.initState();
    collections = widget.collections;
  }

  Future<void> _createNewCollection(BuildContext context) async {
    TextEditingController collectionNameController = TextEditingController();

    // Show dialog to input collection name
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Collection'),
          content: TextField(
            controller: collectionNameController,
            decoration: const InputDecoration(hintText: 'Enter collection name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = collectionNameController.text.trim();
                if (name.isNotEmpty) {
                  try {
                    await CollectionService().createCollection(widget.request, name);
                    // Refresh collections list
                    final updatedCollections =
                        await CollectionService().fetchCollections(widget.request);
                    setState(() {
                      collections = updatedCollections;
                    });
                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create collection: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Collections',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF282A3A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _createNewCollection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollectionPlacesScreen(
                            collectionId: collection.id,
                            collectionName: collection.name,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://via.placeholder.com/150', // Replace with your image URL
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collection.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created ${collection.createdAt}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: collection.places.take(3).map((place) {
                                    return Chip(
                                      label: Text(
                                        place.name,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList()
                                    ..addIf(
                                      collection.places.length > 3,
                                      Chip(
                                        label: Text(
                                          '+${collection.places.length - 3} more',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF282A3A),
      bottomNavigationBar: BottomNavBar(
        onTap: (index) {
          if (index == 2) {
            // Navigate to the journal home
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JournalHome()), // Replace with your journal screen
            );
          } else if (index == 0) {
            // Handle home navigation
            Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Page not available')),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mlaku_mlaku/widgets/bottom_navbar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:mlaku_mlaku/journal/screens/journal_entry_form.dart';
import 'dart:convert';
import 'package:provider/provider.dart'; // This is necessary for using context.read
import 'package:intl/intl.dart'; // Add this import
import 'package:mlaku_mlaku/models/journal_entry.dart';
import 'package:mlaku_mlaku/journal/screens/my_journal.dart';

class JournalHome extends StatefulWidget {
  @override
  _JournalHomeState createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  List<JournalEntry> _journals = [];
  int _selectedIndex = 0; // Track the selected tab

  @override
  void initState() {
    super.initState();
    _fetchJournals(); // Fetch journals when the widget is initialized
  }

  Future<void> _fetchJournals() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/get-journals/');
    setState(() {
      _journals = journalEntryFromJson(jsonEncode(response));
    });
  }

  Future<void> _handleLike(int journalId) async {
    try {
      final request = context.read<CookieRequest>();
      
      // Updated URL to match Django URL pattern
      final response = await request.post(
        "http://127.0.0.1:8000/like/$journalId/",
        {},
      );

      print('Like response: $response'); // Debug print

      if (response != null && (response['liked'] != null || response['error'] != null)) {
        await _fetchJournals(); // Refresh journals to update likes
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error liking journal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like journal. Please try again.')),
      );
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCreateEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JournalEntryFormPage()),
    );

    if (result != null) {
      result(); // Call the refresh method
    }
  }

  String _getFullImageUrl(String imagePath) {
    // Handle empty path
    if (imagePath == null || imagePath.isEmpty) {
      print('Warning: Empty image path provided');
      return ''; // Or return a default image URL
    }
  
    // Already a full URL
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
  
    // Clean up path
    String cleanPath = imagePath.trim();
    
    // Remove leading slash if exists
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
  
    // Construct full URL with media path
    try {
      return 'http://127.0.0.1:8000/$cleanPath';
    } catch (e) {
      print('Error constructing image URL: $e');
      return ''; // Or return default image URL
    }
  }

  Widget _buildJournalCard(JournalEntry journal) {
    final fields = journal.fields;
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(fields.createdAt);

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: fields.image != null && fields.image.isNotEmpty
                ? Image.network(
                    _getFullImageUrl(fields.image),
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Icon(Icons.person); // Fallback icon
                    },
                  )
                : Icon(Icons.person), // Default icon
            ),
            title: Text(fields.author.toString()),
            subtitle: Text(formattedDate),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fields.title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(fields.content),
              ],
            ),
          ),

          if (fields.placeName != null && fields.placeName!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16),
                  SizedBox(width: 4),
                  Text(fields.placeName!),
                  if (fields.souvenir != null) ...[
                    SizedBox(width: 16),
                    Icon(Icons.card_giftcard, size: 16),
                    SizedBox(width: 4),
                    Text('Souvenir ID: ${fields.souvenir}'),
                  ],
                ],
              ),
            ),

          // Update the image section
          if (fields.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                ),
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Default aspect ratio if needed
                  child: Image.network(
                    _getFullImageUrl(fields.image),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      print('Image path: ${fields.image}');
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error),
                            Text('Failed to load image'),
                            Text(_getFullImageUrl(fields.image)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _handleLike(journal.pk),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          fields.likes.isNotEmpty ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text('${fields.likes.length}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journals'),
      ),
      body: Column(
        children: [
          // Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _onTabSelected(0),
                child: Text('For You'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyJournal()),
                  );
                },
                child: Text('My Journal'),
              ),
              ElevatedButton(
                onPressed: _navigateToCreateEntry,
                child: Text('Publish'),
              ),
            ],
          ),
          // Journal List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchJournals,
              child: ListView.builder(
                itemCount: _journals.length,
                itemBuilder: (context, index) {
                  return _buildJournalCard(_journals[index]);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JournalHome()),
            );
          }
        },
      ),
    );
  }
}
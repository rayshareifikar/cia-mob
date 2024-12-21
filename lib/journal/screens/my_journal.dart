import 'package:flutter/material.dart';
import 'package:mlaku_mlaku/models/journal_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mlaku_mlaku/journal/screens/journal_home.dart';
import 'package:mlaku_mlaku/journal/screens/journal_entry_form.dart';

class MyJournal extends StatefulWidget {
  @override
  _MyJournalState createState() => _MyJournalState();
}

class _MyJournalState extends State<MyJournal> {
  List<JournalEntry> _myJournals = [];

  @override
  void initState() {
    super.initState();
    _fetchMyJournals(); // Fetch user's journals on init
  }

  Future<void> _fetchMyJournals() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/json/'); // Update with your endpoint
    setState(() {
      _myJournals = journalEntryFromJson(jsonEncode(response));
    });
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Or return a default image URL
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    String cleanPath = imagePath.trim();
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'http://127.0.0.1:8000/media/$cleanPath';
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
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(fields.content),
              ],
            ),
          ),
          // Additional fields can be added here
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Journals'),
        actions: [
          IconButton(
            icon: Icon(Icons.home), // Ikon untuk tombol "For You"
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalHome()), // Navigasi ke JournalHome
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add), // Ikon untuk tombol "Publish"
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalEntryFormPage()), // Navigasi ke JournalEntryForm
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _myJournals.length,
        itemBuilder: (context, index) {
          return _buildJournalCard(_myJournals[index]);
        },
      ),
    );
  }
}
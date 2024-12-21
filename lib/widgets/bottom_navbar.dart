import 'package:flutter/material.dart';
import 'package:mlaku_mlaku/collections/screens/collections_screen.dart';
import 'package:mlaku_mlaku/journal/screens/journal_home.dart';
import 'package:mlaku_mlaku/models/collections.dart';
import 'package:mlaku_mlaku/services/collection_services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onTap;

  const BottomNavBar({required this.onTap});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final CollectionService _collectionService = CollectionService();

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Navigate to Home
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      // Navigate to Journals
      // Ganti dengan halaman yang sesuai
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JournalHome()), // Ganti dengan halaman yang sesuai
      );
    } else if (index == 3) {
      final request = context.read<CookieRequest>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FutureBuilder(
            future: _collectionService.fetchCollections(request),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Failed to load collections: ${snapshot.error}'),
                  ),
                );
              } else if (snapshot.hasData) {
              final collections = snapshot.data as List<Collection>;
              final request = CookieRequest(); // Pastikan ini adalah instance yang valid
              return CollectionsScreen(
                collections: collections,
                request: request,
              );
              } else {
                return const Scaffold(
                  body: Center(child: Text('No collections available.')),
                );
              }
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Page belum tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list, color: Colors.black),
          label: 'Itinerary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book, color: Colors.black),
          label: 'Journal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections, color: Colors.black),
          label: 'Collection',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.redAccent,
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.black,
    );
  }
}

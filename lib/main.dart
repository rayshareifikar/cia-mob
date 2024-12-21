// lib/main.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Your login page import
import 'package:mlaku_mlaku/screens/login.dart';
// Your journal home import
import 'package:mlaku_mlaku/journal/screens/journal_home.dart';
// Import the place detail page you created
import 'package:mlaku_mlaku/place/screens/place_detail_page.dart';

// Bottom navigation bar widget import
import 'widgets/bottom_navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Mlaku-Mlaku',
        theme: ThemeData(
          primaryColor: Colors.blueAccent,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
          ).copyWith(secondary: Colors.redAccent),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
            bodyLarge: const TextStyle(color: Colors.black),
            bodyMedium: const TextStyle(color: Colors.black54),
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282A3A),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Mlaku-Mlaku',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.person, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'tesbaru',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                // Navigasi kembali ke halaman login
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Touring Across Yogyakarta',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Start your next unforgettable trip with MlakuMaku!',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A Hub for Local Excellence',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yogyakarta, where ancient heritage and vibrant culture intertwine, offers a captivating journey through Indonesia’s heart. Explore the majestic Borobudur and Prambanan temples, both UNESCO World Heritage Sites, that stand as timeless symbols of history. From traditional Javanese art to modern creativity, Yogyakarta is a melting pot of inspiration and innovation. Experience the warmth of its people and the rich flavors of its cuisine, making every visit unforgettable.',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildCard('Bukit Lintang Sewu', 'assets/bukit_lintang_sewu.jpg', placeId: 1),
                  _buildCard('Bunker Kaliadem Merapi', 'assets/bunker_kaliadem.jpg', placeId: 2),
                  _buildCard('De Mata Museum Jogja', 'assets/de_mata_museum.jpg', placeId: 3),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: (index) {
          // Handle navigation based on the index
          if (index == 0) {
            // Navigate to Home
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            // Navigate to Journals
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JournalHome()),
            );
          } else {
            // Show snackbar for other items
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Page belum tersedia')),
            );
          }
        },
      ),
    );
  }

  Widget _buildCard(String title, String imagePath, {required int placeId}) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detail page for this place
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(placeId: placeId),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

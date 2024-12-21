import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class JournalEntryFormPage extends StatefulWidget {
  const JournalEntryFormPage({super.key});

  @override
  State<JournalEntryFormPage> createState() => _JournalEntryFormPageState();
}

class _JournalEntryFormPageState extends State<JournalEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _content = "";
  String _placeName = "";
  String? _souvenirId; // Optional souvenir ID
  List<dynamic> _souvenirs = []; // List to hold souvenirs
  List<dynamic> _places = []; // List to hold places
  Uint8List? _imageBytes; // Replace File? _image with this
  String? _selectedSouvenirName; // Add this field

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _fetchPlaces();
      setState(() {
        _places = places;
      });
      print('Loaded places: $_places'); // Print the loaded places
    } catch (e) {
      print('Error loading places: $e'); // Debug print statement
    }
  }

  Future<List<dynamic>> _fetchPlaces() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get("http://127.0.0.1:8000/get-places/");
      print('Raw response: $response');
      
      if (response != null) {
        final places = response['places'];
        print('Fetched places: $places');
        return places ?? [];
      }
      return [];
    } catch (e) {
      print('Exception during fetch: $e');
      return [];
    }
  }

  Future<void> _fetchSouvenirs(String placeName) async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/get-souvenirs/?place_name=$placeName');
    print(response); // Check if souvenirs are fetched correctly
    setState(() {
      _souvenirs = response['souvenirs'] ?? []; // Access the 'souvenirs' key from response
      _souvenirId = null; // Reset souvenir selection
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Journal Entry'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Content'),
                  onChanged: (value) {
                    setState(() {
                      _content = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Place'),
                  items: _places.map((place) {
                    // Assuming place is already a string from the backend
                    return DropdownMenuItem<String>(
                      value: place, // Use place directly since it's a string
                      child: Text(place),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _placeName = value!;
                      _fetchSouvenirs(_placeName);
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Souvenir'),
                  value: _souvenirId,
                  items: _souvenirs.map((souvenir) {
                    return DropdownMenuItem<String>(
                      value: souvenir['id'].toString(), // Convert id to string
                      child: Text(souvenir['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _souvenirId = value;
                    });
                  },
                ),
                // Image Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_imageBytes == null ? 'No image selected' : 'Image selected'),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final request = context.read<CookieRequest>();
                        
                        String? imageBase64;
                        if (_imageBytes != null) {
                          imageBase64 = base64Encode(_imageBytes!);
                        }

                        // Create the request data
                        final requestData = jsonEncode({
                          'title': _title,
                          'content': _content,
                          'place_name': _placeName,
                          'souvenir': _souvenirId,
                          'image': imageBase64,
                        });

                        final response = await request.postJson(
                          "http://127.0.0.1:8000/create-journal-flutter/",
                          requestData,
                        );

                        print('Response: $response'); // Debug print

                        if (response != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Journal entry created!")),
                          );
                          Navigator.pop(context);
                        } else {
                          throw Exception('Failed to create journal');
                        }
                      } catch (e) {
                        print('Error: $e'); // Debug print
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
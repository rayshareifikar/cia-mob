// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mlaku_mlaku/collections/screens/collections_screen.dart';
// import 'package:mlaku_mlaku/models/collections.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';

// class CollectionFormPage extends StatefulWidget {
//   const CollectionFormPage({super.key});

//   @override
//   State<CollectionFormPage> createState() => _CollectionFormPageState();
// }

// class _CollectionFormPageState extends State<CollectionFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _name = "";
//   String _description = "";

//   @override
//   Widget build(BuildContext context) {
//     final request = context.watch<CookieRequest>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text('Form Tambah Koleksi'),
//         ),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     hintText: "Nama Koleksi",
//                     labelText: "Nama Koleksi",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   onChanged: (String? value) {
//                     setState(() {
//                       _name = value!;
//                     });
//                   },
//                   validator: (String? value) {
//                     if (value == null || value.isEmpty) {
//                       return "Nama Koleksi tidak boleh kosong!";
//                     }
//                     return null;
//                   },
//                 ),
//               ),
              
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     hintText: "Deskripsi Koleksi",
//                     labelText: "Deskripsi Koleksi",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   onChanged: (String? value) {
//                     setState(() {
//                       _description = value!;
//                     });
//                   },
//                   validator: (String? value) {
//                     if (value == null || value.isEmpty) {
//                       return "Deskripsi tidak boleh kosong!";
//                     }
//                     return null;
//                   },
//                 ),
//               ),
              
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(
//                           Theme.of(context).colorScheme.primary),
//                     ),
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         // Kirim ke Django dan tunggu respons
//                         final List<Collection> collections;
//                         final request = CookieRequest(); //
//                         final response = await request.postJson(
//                           "http://127.0.0.1:8000/create-collection/",
//                           jsonEncode(<String, String>{
//                             'name': _name,
//                             'description': _description,
//                           }), //  Pastikan ini adalah instance yang valid
//                         );

//                         if (context.mounted) {
//                           if (response['status'] == 'success') {

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text("Koleksi berhasil disimpan!")),
//                             );
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => CollectionsScreen(
//                                     collections: collections,
//                                     request: request,
//                                   )
//                               );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                     "Terjadi kesalahan, coba lagi."),
//                               ),
//                             );
//                           }
//                         }
//                       }
//                     },
//                     child: const Text(
//                       "Simpan",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

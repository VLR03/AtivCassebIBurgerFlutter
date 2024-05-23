import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Hamburguerias');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Uint8List? _imageData;
  String? _imageUrl;
  String _errorMessage = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageData = bytes;
      });
    }
  }

  Future<void> _registrarHamburgueria() async {
    if (_auth.currentUser == null) {
      setState(() {
        _errorMessage = 'Você precisa estar logado para registrar uma hamburgueria.';
      });
      return;
    }

    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || _imageData == null || description.isEmpty) {
      setState(() {
        _errorMessage = 'Todos os campos são obrigatórios.';
      });
      return;
    }

    final DatabaseEvent event = await _database.orderByChild('name').equalTo(name).once();
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      setState(() {
        _errorMessage = 'Hamburgueria já existe.';
      });
      return;
    }

    final String userId = _auth.currentUser!.uid;
    String imageBase64 = base64Encode(_imageData!);

    await _database.push().set({
      'name': name,
      'rating': 0.0,
      'image': imageBase64,
      'description': description,
      'userId': userId
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Hamburgueria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Escolha sua logo'),
            ),
            if (_imageData != null) 
              Image.memory(_imageData!, height: 200),
            if (_imageUrl != null)
              Image.network(_imageUrl!),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _registrarHamburgueria,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

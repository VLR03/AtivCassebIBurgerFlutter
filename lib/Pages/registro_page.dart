import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final TextEditingController _ratingController = TextEditingController();
  // final TextEditingController _imageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // File? _image;
  Uint8List? _imageData;
  String? _imageUrl;
  String _errorMessage = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        // _image = File(image.path);
        _imageData = bytes;
        // _imageUrl = image.path;
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
    final String ratingStr = _ratingController.text.trim();
    // final String image = _imageController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || ratingStr.isEmpty || _imageData == null /* || image.isEmpty */ || description.isEmpty) {
      setState(() {
        _errorMessage = 'Todos os campos são obrigatórios.';
      });
      return;
    }

    final double? rating = double.tryParse(ratingStr);
    if (rating == null || rating < 0 || rating > 5) {
      setState(() {
        _errorMessage = 'Avaliação deve ser um número entre 0 e 5.';
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
    // final String imageUrl = await _uploadImage(_imageData!);
    // final String imageUrl = _imageUrl!;
    String imageBase64 = base64Encode(_imageData!);

    await _database.push().set({
      'name': name,
      'rating': rating,
      // 'image': image,
      'image': imageBase64,
      'description': description,
      'userId': userId
    });

    Navigator.pop(context);
  }

  Future<String> _uploadImage(Uint8List imageData) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final String filePath = 'hamburguerias/${DateTime.now()}.png';
    final Reference ref = storage.ref().child(filePath);
    final UploadTask uploadTask = ref.putData(imageData);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    
    return await snapshot.ref.getDownloadURL();
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
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Avaliação (0-5)'),
              keyboardType: TextInputType.number,
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
            // const SizedBox(height: 16.0),
            // TextField(
            //   controller: _imageController,
            //   decoration: const InputDecoration(labelText: 'Imagem'),
            // ),
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

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> hamburgueria;

  const EditPage({super.key, required this.hamburgueria});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Hamburguerias');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _imageData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.hamburgueria['name'];
    _descriptionController.text = widget.hamburgueria['description'];
    _imageData = base64Decode(widget.hamburgueria['image']);
  }

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

  Future<void> _salvarEdicoes() async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || _imageData == null || description.isEmpty) {
      setState(() {
        _errorMessage = 'Todos os campos são obrigatórios.';
      });
      return;
    }

    String imageBase64 = base64Encode(_imageData!);

    await _database.child(widget.hamburgueria['id']).update({
      'name': name,
      'image': imageBase64,
      'description': description,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Hamburgueria'),
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
              child: const Text('Escolha uma nova logo'),
            ),
            if (_imageData != null) 
              Image.memory(_imageData!, height: 200),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _salvarEdicoes,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

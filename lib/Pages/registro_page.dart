import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Hamburguerias');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  Future<void> _registrarHamburgueria() async {
    if (_auth.currentUser == null) {
      setState(() {
        _errorMessage = 'Você precisa estar logado para registrar uma hamburgueria.';
      });
      return;
    }

    final String name = _nameController.text.trim();
    final String ratingStr = _ratingController.text.trim();
    final String image = _imageController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || ratingStr.isEmpty || image.isEmpty || description.isEmpty) {
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

    await _database.push().set({
      'name': name,
      'rating': rating,
      'image': image,
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
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Avaliação (0-5)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Imagem'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 16.0),
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

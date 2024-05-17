import 'package:flutter/material.dart';

class DetalhesPage extends StatelessWidget {
  final Map<String, dynamic> hamburgueria;

  const DetalhesPage({super.key, required this.hamburgueria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hamburgueria['name']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(hamburgueria['image']),
            const SizedBox(height: 20),
            Text(
              'Avaliação: ${hamburgueria['rating']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                hamburgueria['description'],
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Registrado por: ${hamburgueria['userId']}',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}
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
            Text('Avaliação: ${hamburgueria['rating']}'),
          ],
        ),
      ),
    );
  }
}
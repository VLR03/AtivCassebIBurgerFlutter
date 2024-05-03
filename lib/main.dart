import 'package:flutter/material.dart';
import 'detalhes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBurger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> hamburguerias = [
    {"name": "NuKanto Burger", "image": "assets/NuKanto.jpg", "rating": 4.5},
    {"name": "Burger Queen", "image": "assets/BurgerQueen.jpg", "rating": 4.0}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamburguerias'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Pokemon.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: hamburguerias.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(hamburguerias[index]['image']),
              ),
              title: Text(hamburguerias[index]['name']),
              subtitle: Text('Avaliação: ${hamburguerias[index]['rating']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesPage(
                      hamburgueria: hamburguerias[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // body: ListView.builder(
      //   itemCount: hamburguerias.length,
      //   itemBuilder: (context, index) {
      //     return ListTile(
      //       leading: CircleAvatar(
      //         backgroundImage: AssetImage(hamburguerias[index]['image']),
      //       ),
      //       title: Text(hamburguerias[index]['name']),
      //       subtitle: Text('Avaliação: ${hamburguerias[index]['rating']}'),
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => DetalhesPage(
      //               hamburgueria: hamburguerias[index],
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}

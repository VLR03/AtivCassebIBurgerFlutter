import 'dart:html';

import 'package:flutter/material.dart';
import 'package:iburger/detalhes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Hamburguerias');

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
        child: StreamBuilder<DatabaseEvent>(
          stream: _database.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<String, dynamic> values = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
              List<Map<String, dynamic>> hamburguerias = [];
              values.forEach((key, value) {
                hamburguerias.add({
                  'id': key,
                  'name': value['name'],
                  'image': value['image'],
                  'rating': value['rating'].toDouble(),
                });
              });
              return ListView.builder(
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
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

// #region Versão 2 (comentada)
// class HomePage extends StatelessWidget {
//   final List<Map<String, dynamic>> hamburguerias = [
//     {"name": "NuKanto Burger", "image": "assets/NuKanto.jpg", "rating": 4.5},
//     {"name": "Burger Queen", "image": "assets/BurgerQueen.jpg", "rating": 4.0},
//     {"name": "Geek Burger", "image": "assets/GeekBurger.jpg", "rating": 5.0},
//     {"name": "Porpino Burger", "image": "assets/Porpino.jpg", "rating": 5.0},
//     {"name": "Terraco Burger", "image": "assets/Terraco.jpg", "rating": 3.5},
//     {"name": "KomBurger", "image": "assets/Komburger.jpg", "rating": 3.0},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Hamburguerias'),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/Pokemon.jpg"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: ListView.builder(
//           itemCount: hamburguerias.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: AssetImage(hamburguerias[index]['image']),
//               ),
//               title: Text(hamburguerias[index]['name']),
//               subtitle: Text('Avaliação: ${hamburguerias[index]['rating']}'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DetalhesPage(
//                       hamburgueria: hamburguerias[index],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
      // #region Versão 1 (comentada)
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
      // #endregion
//     );
//   }
// }
// #endregion

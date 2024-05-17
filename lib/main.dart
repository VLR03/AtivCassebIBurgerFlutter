import 'package:firebase_database/firebase_database.dart';
import 'package:iburger/Pages/registro_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iburger/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:iburger/Pages/detalhes_page.dart';
import 'firebase_options.dart';
import 'dart:html';

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
      // home: LoginPage(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Hamburguerias');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IBurger'),
        actions: [
          IconButton(
            icon: _auth.currentUser != null ? const Icon(Icons.person) : const Icon(Icons.person_outline),
            color: _auth.currentUser != null ? Colors.green : Colors.grey,
            onPressed: () {
              _handleUserIconClick(context);
            },
          ),
        ],
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
              Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
              List<Map<String, dynamic>> hamburguerias = [];
              values.forEach((key, value) {
                hamburguerias.add({
                  'id': key,
                  'name': value['name'],
                  'image': value['image'],
                  'rating': value['rating'].toDouble(),
                  'description': value['description'],
                  'userId': value['userId'],
                });
              });
              return Column(
                children: [
                  Expanded(
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
                  _auth.currentUser != null ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistroPage()),
                      );
                    },
                    child: const Text('Registrar Hamburgueria'),
                  ) : Container(),
                ],
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

  void _handleUserIconClick(BuildContext context) {
    if (_auth.currentUser == null) {
      print('Você não está logado');
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      _logout(context);
    }
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    print('Você estava logado e deslogou');
  }
}

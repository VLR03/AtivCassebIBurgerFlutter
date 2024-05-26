import 'package:firebase_database/firebase_database.dart';
import 'package:iburger/Pages/registro_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iburger/Pages/detalhes_page.dart';
import 'package:iburger/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'dart:typed_data';
import 'dart:convert';
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Hamburguerias');
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // _statusLogin();
  }

  void _statusLogin() {
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _paginaLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    
  }

  void _paginaDetalhes(Map<String, dynamic> hamburgueria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesPage(hamburgueria: hamburgueria),
      ),
    );
  }

  void _paginaRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IBurger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _paginaRegistro,
          ),
          _currentUser != null
          ? IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
            )
          : IconButton(
            icon: const Icon(Icons.person),
            onPressed: _paginaLogin,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Pokemon.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          StreamBuilder<DatabaseEvent>(
            stream: _database.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                List<Map<String, dynamic>> hamburguerias = [];
                values.forEach((key, value) {
                  hamburguerias.add({
                    'id': key,
                    'name': value['name'],
                    'rating': value['rating'].toDouble(),
                    'image': value['image'],
                    'description': value['description'],
                    'userId': value['userId'],
                  });
                });
                return ListView.builder(
                  itemCount: hamburguerias.length,
                  itemBuilder: (context, index) {
                    Uint8List imageBytes = base64Decode(hamburguerias[index]['image']);
                    return ListTile(
                      leading: Image.memory(imageBytes, width: 50, height: 50),
                      title: Text(hamburguerias[index]['name']),
                      subtitle: Row(
                        children: [
                          for (var i = 0; i < 5; i++)
                            Icon(
                              i < hamburguerias[index]['rating'] ? Icons.star : Icons.star_border,
                              color: Colors.yellow,
                            ),
                        ],
                      ),
                      onTap: () => _paginaDetalhes(hamburguerias[index]),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('Nenhuma hamburgueria encontrada.'),
                );
              }
            },
          ),
        ],
      )
    );
  }
}

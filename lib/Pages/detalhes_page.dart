import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

class DetalhesPage extends StatefulWidget {
  final Map<String, dynamic> hamburgueria;

  const DetalhesPage({super.key, required this.hamburgueria});

  @override
  _DetalhesPageState createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Avaliacoes');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _mensagemController = TextEditingController();
  int _rating = 0;
  String _errorMessage = '';

  Future<void> _submitAvaliacao() async {
    if (_auth.currentUser == null) {
      setState(() {
        _errorMessage = 'Você precisa estar logado para deixar uma avaliação.';
      });
      return;
    }

    final String mensagem = _mensagemController.text.trim();

    if (_rating == 0 || mensagem.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
      return;
    }

    final String userId = _auth.currentUser!.uid;

    await _database.push().set({
      'hamburgueriaId': widget.hamburgueria['id'],
      'rating': _rating,
      'mensagem': mensagem,
      'userId': userId,
    });

    await _updateHamburgueriaRating();

    _mensagemController.clear();
    setState(() {
      _rating = 0;
    });
  }

  Future<void> _updateHamburgueriaRating() async {
    final DatabaseEvent event = await _database.orderByChild('hamburgueriaId').equalTo(widget.hamburgueria['id']).once();
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.value as Map);
      double totalRating = 0;
      int count = 0;

      values.forEach((key, value) {
        totalRating += value['rating'];
        count++;
      });

      double averageRating = totalRating / count;

      DatabaseReference hamburgueriaRef = FirebaseDatabase.instance.ref().child('Hamburguerias').child(widget.hamburgueria['id']);
      await hamburgueriaRef.update({
        'rating': averageRating,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(widget.hamburgueria['image']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hamburgueria['name']),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Pokemon5.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    image: DecorationImage(
                      image: MemoryImage(imageBytes),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hamburgueria['name'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < 5; i++)
                              Icon(
                                i < widget.hamburgueria['rating'] ? Icons.star : Icons.star_border,
                                color: Colors.yellow,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.hamburgueria['description'],
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.justify,
                      ),
                      // const SizedBox(height: 16),
                      // Text(
                      //   'Registrado por: ${widget.hamburgueria['userId']}',
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     fontStyle: FontStyle.italic,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      if (_auth.currentUser != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Deixe sua Avaliação',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var i = 1; i <= 5; i++)
                              IconButton(
                                icon: Icon(
                                  i <= _rating ? Icons.star : Icons.star_border,
                                  color: Colors.yellow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rating = i;
                                  });
                                },
                              ),
                          ],
                        ),
                        TextField(
                          controller: _mensagemController,
                          decoration: const InputDecoration(
                            labelText: 'Mensagem',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _submitAvaliacao,
                          child: const Text('Enviar Avaliação'),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Avaliações',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<DatabaseEvent>(
                        stream: _database.orderByChild('hamburgueriaId').equalTo(widget.hamburgueria['id']).onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                            Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                            List<Map<String, dynamic>> avaliacoes = [];
                            values.forEach((key, value) {
                              avaliacoes.add({
                                'rating': value['rating'],
                                'mensagem': value['mensagem'],
                                'userId': value['userId'],
                              });
                            });
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: avaliacoes.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.person, color: Colors.white),
                                  title: Row(
                                    children: [
                                      for (var i = 0; i < 5; i++)
                                        Icon(
                                          i < avaliacoes[index]['rating'] ? Icons.star : Icons.star_border,
                                          color: Colors.yellow,
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(avaliacoes[index]['mensagem']),
                                  // trailing: Text(avaliacoes[index]['userId']),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Nenhuma avaliação encontrada.',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// #region Organização original (comentada)
// Widget build(BuildContext context) {
//     Uint8List imageBytes = base64Decode(hamburgueria['image']);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(hamburgueria['name']),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/Pokemon5.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 250,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(0),
//                       bottomRight: Radius.circular(0),
//                     ),
//                     image: DecorationImage(
//                       image: MemoryImage(imageBytes),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         hamburgueria['name'],
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 10.0,
//                               color: Colors.black,
//                               offset: Offset(3.0, 3.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           for (var i = 0; i < 5; i++)
//                             Icon(
//                               i < hamburgueria['rating'] ? Icons.star : Icons.star_border,
//                               color: Colors.yellow,
//                               size: 28,
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Descrição',
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         hamburgueria['description'],
//                         style: const TextStyle(fontSize: 18, color: Colors.white),
//                         textAlign: TextAlign.justify,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Registrado por: ${hamburgueria['userId']}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontStyle: FontStyle.italic,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// #endregion
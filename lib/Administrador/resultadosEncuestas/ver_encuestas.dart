import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerEncuestas extends StatefulWidget {
  const VerEncuestas({super.key});

  @override
  State<VerEncuestas> createState() => _VerEncuestasState();
}

class _VerEncuestasState extends State<VerEncuestas> {
  List<Map<String, dynamic>> encuestas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerEncuestas();
  }

  Future<void> obtenerEncuestas() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse("http://localhost:3000/encuestas/all"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          encuestas = data.map((e) => {
            'id': e['id'],
            'proyecto': e['proyecto'],
            'titulo': e['titulo']
          }).toList();
        });
        print('Encuestas obtenidas con éxito');
      } else {
        print('Error al obtener las encuestas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Encuestas Disponibles',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : encuestas.isEmpty
              ? const Center(child: Text('No hay encuestas disponibles'))
              : ListView.builder(
                  itemCount: encuestas.length,
                  itemBuilder: (context, index) {
                    final encuesta = encuestas[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: const Icon(Icons.star_border, color: Colors.blue, size: 25),
                          title: Text(
                            encuesta['titulo'] ?? 'Sin Título',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            encuesta['proyecto'] != null
                            ? '${encuesta['proyecto']}'
                            : 'Sin proyecto'
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              print('Ver respuestas para: ${encuesta['titulo']}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Ver respuestas'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: obtenerEncuestas,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.refresh, color: Colors.white,),
                ),
    );
  }
}
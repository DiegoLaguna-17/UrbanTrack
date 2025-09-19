import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cardEncuesta.dart';

class EncuestasPage extends StatefulWidget {
  final int clienteId; // Se lo pasas desde login/home

  const EncuestasPage({Key? key, required this.clienteId}) : super(key: key);

  @override
  _EncuestasPageState createState() => _EncuestasPageState();
}

class _EncuestasPageState extends State<EncuestasPage> {
  List<dynamic> encuestas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEncuestas();
  }

  Future<void> fetchEncuestas() async {
    final url = Uri.parse('http://localhost:3000/encuestas/cliente/${widget.clienteId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          encuestas = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Error al cargar encuestas");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (encuestas.isEmpty) {
      return const Center(child: Text("No hay encuestas disponibles"));
    }

    return ListView.builder(
      itemCount: encuestas.length,
      itemBuilder: (context, index) {
        final encuesta = encuestas[index];
        return CardEncuesta(
          titulo: encuesta['titulo'],
          proyecto: encuesta['proyecto'] ?? "Sin proyecto",
          onResponder: () {
            // Aquí navegas a la pantalla de responder encuesta
            print("Responder encuesta ${encuesta['id']}");
          },
        );
      },
    );
  }
}

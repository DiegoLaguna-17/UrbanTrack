import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ------------------ Modelo ------------------
class Respuesta {
  final String tipo;
  final String pregunta;
  final String? respuestaTexto;
  final String? opcionSeleccionada;

  Respuesta({
    required this.tipo,
    required this.pregunta,
    this.respuestaTexto,
    this.opcionSeleccionada,
  });

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
      tipo: json['tipo'],
      pregunta: json['pregunta'],
      respuestaTexto: json['respuestaTexto'],
      opcionSeleccionada: json['opcionSeleccionada'],
    );
  }
}

// ------------------ Página ------------------
class RespuestasPage extends StatefulWidget {
  final int idCliente;
  final int idEncuesta;
  final String titulo; // 🔹 nuevo campo

  const RespuestasPage({
    super.key,
    required this.idCliente,
    required this.idEncuesta,
    required this.titulo,
  });

  @override
  State<RespuestasPage> createState() => _RespuestasPageState();
}

class _RespuestasPageState extends State<RespuestasPage> {
  late Future<List<Respuesta>> futureRespuestas;

  @override
  void initState() {
    super.initState();
    futureRespuestas = fetchRespuestas(widget.idEncuesta, widget.idCliente);
  }

  // ----------- Llamada al endpoint -----------
  Future<List<Respuesta>> fetchRespuestas(int idEncuesta, int idCliente) async {
    final url = Uri.parse(
        "https://utbackend-xn26.onrender.com/encuestas/respuestas/$idEncuesta/$idCliente");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Respuesta.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar respuestas");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,
        toolbarHeight: 0,),
      body: FutureBuilder<List<Respuesta>>(
        future: futureRespuestas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final respuestas = snapshot.data ?? [];
          if (respuestas.isEmpty) {
            return const Center(child: Text("No hay respuestas"));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Aquí se muestra el título
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255,10,128,251)
                  ),
                ),
              ),

              // 🔹 Lista de respuestas expandida
              Expanded(
                child: ListView.builder(
                  itemCount: respuestas.length,
                  itemBuilder: (context, index) {
                    final r = respuestas[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}. ${r.pregunta}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (r.tipo == "abierta")
                              Text("Respuesta: ${r.respuestaTexto ?? '-'}"),
                            if (r.tipo == "escala")
                              Text("Seleccionado: ${r.opcionSeleccionada ?? '-'}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

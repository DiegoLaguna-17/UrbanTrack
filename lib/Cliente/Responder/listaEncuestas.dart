import 'package:flutter/material.dart';
import 'package:urban_track/Cliente/Responder/cardEncuesta.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EncuestasTab extends StatefulWidget {
  final int idCliente;
  const EncuestasTab({required this.idCliente, super.key});

  @override
  State<EncuestasTab> createState() => _EncuestasTabState();
}

class _EncuestasTabState extends State<EncuestasTab> {
  String searchQuery = "";
  List<Map<String, String>> encuestas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEncuestas(); // Traer datos al iniciar la pestaña
  }

  Future<void> fetchEncuestas() async {
    int id = widget.idCliente;
    final url = 'https://utbackend-xn26.onrender.com/encuestas/cliente/$id'; 

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          encuestas = data.map<Map<String, String>>((e) {
            return {
              "id": e['id'].toString(),
              "titulo": e['titulo'] ?? '',
              "proyecto": e['proyecto'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Error al obtener encuestas: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredEncuestas = encuestas
        .where((e) =>
            e["titulo"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            e["proyecto"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Buscar encuestas...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),
        const SizedBox(height: 5),
        const Divider(thickness: 2, indent: 16, endIndent: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Encuestas disponibles",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(thickness: 2, indent: 16, endIndent: 16),
        const SizedBox(height: 8),
        Expanded(
  child: filteredEncuestas.isEmpty
      ? const Center(
          child: Text(
            "No hay encuestas por responder",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        )
      : ListView.builder(
          itemCount: filteredEncuestas.length,
          itemBuilder: (context, index) {
            final encuesta = filteredEncuestas[index];
            return EncuestaCard(
              idCliente: widget.idCliente,
              idEncuesta: encuesta["id"]!, // ✅ sigue como String
              titulo: encuesta["titulo"]!,
              descripcion: encuesta["proyecto"]!,
              onTap: () {
                setState(() => isLoading = true);
                fetchEncuestas();
              },
            );
          },
        ),
)

      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:urban_track/Administrador/resultadosEncuestas/ver_resultados.dart';

class Proyecto {
  final int id;
  final String nombre;
  Proyecto({required this.id, required this.nombre});
}

class Encuesta {
  final int id;
  final String titulo;
  final String? proyecto;
  Encuesta({required this.id, required this.titulo, this.proyecto});
}


class VerEncuestas extends StatefulWidget {
  const VerEncuestas({super.key});

  @override
  State<VerEncuestas> createState() => _VerEncuestasState();
}

class _VerEncuestasState extends State<VerEncuestas> {
  List<Encuesta> _encuestas = [];
  List<Proyecto> _proyectos = [];
  int? _selectedProjectId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProyectos();
    _fetchEncuestas(); 
  }

  Future<void> _fetchProyectos() async {
    try {
      final response = await http.get(Uri.parse("https://utbackend-xn26.onrender.com/proyectos"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _proyectos = data.map((p) => Proyecto(id: p['id'], nombre: p['nombre'])).toList();
        });
      } else {
        print('Error al obtener los proyectos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al obtener proyectos: $e');
    }
  }

  Future<void> _fetchEncuestas({int? projectId}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String url = "https://utbackend-xn26.onrender.com/encuestas/all";
      if (projectId != null) {
        url += "?proyectoId=$projectId";
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _encuestas = data.map((e) => Encuesta(
            id: e['id'],
            titulo: e['titulo'],
            proyecto: e['proyecto'],
          )).toList();
        });
        print('Encuestas obtenidas con éxito');
      } else {
        print('Error al obtener las encuestas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Encuestas Disponibles',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: DropdownButtonFormField<int?>(
              value: _selectedProjectId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Filtrar por Proyecto',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              hint: const Text('Todos los proyectos'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos los proyectos'),
                ),
                ..._proyectos.map((proyecto) {
                  return DropdownMenuItem<int?>(
                    value: proyecto.id,
                    child: Text(proyecto.nombre),
                  );
                }),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedProjectId = newValue;
                  _fetchEncuestas(projectId: _selectedProjectId);
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : _encuestas.isEmpty
                    ? const Center(child: Text('No hay encuestas para el filtro seleccionado'))
                    : ListView.builder(
                        itemCount: _encuestas.length,
                        itemBuilder: (context, index) {
                          final encuesta = _encuestas[index];
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
                                  encuesta.titulo,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  encuesta.proyecto ?? 'Sin proyecto',
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => VerResultados(encuestaId: encuesta.id, encuestaTitulo: encuesta.titulo,)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 95, 255, 18),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchEncuestas(projectId: _selectedProjectId),
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white,),
      ),
    );
  }
}
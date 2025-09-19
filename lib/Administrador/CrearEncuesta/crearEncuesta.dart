import 'package:flutter/material.dart';
import 'package:urban_track/Administrador/CrearEncuesta/pregunta_abierta.dart';
import 'package:urban_track/Administrador/CrearEncuesta/pregunta_escala.dart';
import 'package:urban_track/Administrador/CrearEncuesta/pregunta_multiple.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';


class CrearEncuestaPage extends StatefulWidget {
  final int idAdmin;
  const CrearEncuestaPage({required this.idAdmin});

  @override
  State<CrearEncuestaPage> createState() => _CrearEncuestaPageState();
  
}

class _CrearEncuestaPageState extends State<CrearEncuestaPage> {
  bool _isSubmitting = false;
  String? selectedProject;
  final TextEditingController tituloController = TextEditingController();

  List<Widget> preguntasWidgets = [];
  List<TextEditingController> _preguntasControllers = [];

  List<Map<String, dynamic>> proyectos = [];
  bool loadingProyectos = true;

  @override
  void initState() {
    super.initState();
    fetchProyectos();
  }

  @override
  void dispose() {
    tituloController.dispose();
    for (var c in _preguntasControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> fetchProyectos() async {
    try {
      final response =
          await http.get(Uri.parse('https://utbackend-xn26.onrender.com/proyectos'));
      if (response.statusCode == 200) {

        final List data = jsonDecode(response.body);
        setState(() {
          proyectos = data.map((e) => {'id': e['id'], 'nombre': e['nombre']}).toList();
          loadingProyectos = false;
        });
      } else {
        print('Error al cargar proyectos: ${response.statusCode}');
        setState(() => loadingProyectos = false);
      }
    } catch (e) {

       AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al obtener proyectos',
          btnOkOnPress: () {},
        ).show();
      setState(() => loadingProyectos = false);
    }
  }

  void _agregarPregunta(String tipo) {
    final controller = TextEditingController();
    _preguntasControllers.add(controller);
    final key = UniqueKey();

    late Widget preguntaWidget;

    if (tipo == "Abierta") {
      preguntaWidget = PreguntaAbiertaWidget(
        key: key,
        controller: controller,
        onDelete: () {
          setState(() {
            preguntasWidgets.removeWhere((w) => w.key == key);
            _preguntasControllers.remove(controller);
          });
        },
      );
    } else if (tipo == "Opción Múltiple") {
      preguntaWidget = PreguntaMultipleWidget(
        key: key,
        controller: controller,
        onDelete: () {
          setState(() {
            preguntasWidgets.removeWhere((w) => w.key == key);
            _preguntasControllers.remove(controller);
          });
        },
      );
    } else if (tipo == "Escala") {
      preguntaWidget = PreguntaEscalaWidget(
        key: key,
        controller: controller,
        onDelete: () {
          setState(() {
            preguntasWidgets.removeWhere((w) => w.key == key);
            _preguntasControllers.remove(controller);
          });
        },
      );
    }

    setState(() {
      preguntasWidgets.add(preguntaWidget);
    });
  }

  void _showAgregarPreguntaDialog() {
    String? tipoSeleccionado;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Selecciona tipo de pregunta"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text("Pregunta Abierta"),
                  value: "Abierta",
                  groupValue: tipoSeleccionado,
                  onChanged: (value) {
                    setDialogState(() {
                      tipoSeleccionado = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Opción Múltiple"),
                  value: "Opción Múltiple",
                  groupValue: tipoSeleccionado,
                  onChanged: (value) {
                    setDialogState(() {
                      tipoSeleccionado = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Escala"),
                  value: "Escala",
                  groupValue: tipoSeleccionado,
                  onChanged: (value) {
                    setDialogState(() {
                      tipoSeleccionado = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tipoSeleccionado != null) {
                        _agregarPregunta(tipoSeleccionado!);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Agregar"),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> crearEncuesta() async {

    
    if (_isSubmitting) return;
    if (selectedProject == null || tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proyecto y un título')),
      );
      return;
    }

       List<Map<String, dynamic>> preguntasData = preguntasWidgets.map((w) {
                  if (w is PreguntaAbiertaWidget) {
                    return w.toMap() as Map<String, dynamic>;
                  } else if (w is PreguntaMultipleWidget) {
                    return w.toMap() as Map<String, dynamic>;
                  } else if (w is PreguntaEscalaWidget) {
                    return w.toMap() as Map<String, dynamic>;
                  }
                  return <String, dynamic>{};
                }).toList();
    if(preguntasData.isEmpty){
       AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'La encuesta no tiene preguntas',
          btnOkOnPress: () {},
        ).show();
        return;
    }

    final body = {
      "titulo": tituloController.text,
      "proyectoId": int.parse(selectedProject!),
      "administradorId":widget.idAdmin,//ESTO SE HA DE CAMBIAR LUEGO DEL LOGIN PARA LOS ADMIN
      "preguntas": preguntasData,
    };

    try {
      final response = await http.post(
        Uri.parse("https://utbackend-xn26.onrender.com/encuestas"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '¡Éxito!',
          desc: 'Encuesta Creada Correctamente',
          btnOkOnPress: () {
          },
        ).show(); // éxito
        preguntasWidgets.clear();
        tituloController.clear();
        selectedProject=null;
      } else {
         AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al crear encuesta:',
          btnOkOnPress: () {},
        ).show();
        // error
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Error de conexión: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar"),
            )
          ],
        ),
      );
      print("Error de conexión: $e");
    } finally {
      setState(() => _isSubmitting = false); // habilitar botón de nuevo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Crear Encuesta",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 10, 128, 251)),
          ),
          const SizedBox(height: 16),
          const Text("Seleccionar proyecto", style: TextStyle(fontSize: 20)),
          DropdownButton<String>(
            value: selectedProject,
            hint: loadingProyectos
                ? const Text("Cargando proyectos...")
                : const Text("Selecciona un proyecto"),
            items: proyectos
                .map((p) => DropdownMenuItem(
                      value: p['id'].toString(),
                      child: Text(p['nombre']),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedProject = value),
          ),
          const SizedBox(height: 16),
          const Text("Título", style: TextStyle(fontSize: 20)),
          TextField(
            controller: tituloController,
            decoration: const InputDecoration(
              hintText: "Ingresa el título de la encuesta",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _showAgregarPreguntaDialog,
            label: const Text(
              "Agregar pregunta",
              style: TextStyle(color: Color.fromARGB(255, 10, 128, 251)),
            ),
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 10, 128, 251),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: preguntasWidgets.length,
              itemBuilder: (context, index) => preguntasWidgets[index],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: crearEncuesta,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color.fromARGB(255, 95, 255, 18)),
              child: const Text(
                "Crear Encuesta",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


void showCustomDialog(BuildContext context, bool success) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              success ? "Encuesta creada correctamente" : "Error al crear encuesta",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

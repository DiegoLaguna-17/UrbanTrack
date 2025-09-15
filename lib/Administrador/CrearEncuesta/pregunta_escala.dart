import 'package:flutter/material.dart';

class PreguntaEscalaWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onDelete;

  final List<TextEditingController> opcionesControllers = [];

  PreguntaEscalaWidget({
    super.key,
    required this.controller,
    required this.onDelete,
  });
   Map<String, dynamic> toMap() {
    return {
      'tipo': 'escala',
      'pregunta': controller.text,
      'opciones': opcionesControllers.map((c) => c.text).toList(),
    };
  }
  @override
  State<PreguntaEscalaWidget> createState() => _PreguntaEscalaWidgetState();
}

class _PreguntaEscalaWidgetState extends State<PreguntaEscalaWidget> {

  void _agregarOpcion() {
    final controller = TextEditingController();
    widget.opcionesControllers.add(controller);
    setState(() {});
  }

  void _eliminarOpcion(int index) {
    widget.opcionesControllers[index].dispose();
    widget.opcionesControllers.removeAt(index);
    setState(() {});
  }

  @override
  void dispose() {
    for (var c in widget.opcionesControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pregunta + botón eliminar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: "Ingresa la pregunta de escala",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Lista de opciones
            ...List.generate(widget.opcionesControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.opcionesControllers[index],
                        decoration: InputDecoration(
                          hintText: "Opción ${index + 1}",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarOpcion(index),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _agregarOpcion,
              icon: const Icon(Icons.add),
              label: const Text("Agregar opción"),
            ),
          ],
        ),
      ),
    );
  }
}

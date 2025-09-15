import 'package:flutter/material.dart';

class PreguntaAbiertaWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDelete;

  const PreguntaAbiertaWidget({
    super.key,
    required this.controller,
    required this.onDelete,
  });
    Map<String, dynamic> toMap() {
    return {
      'tipo': 'abierta',
      'pregunta': controller.text,
      'opciones': [], // vacía porque es abierta
    };
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Pregunta abierta",
            border: InputBorder.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

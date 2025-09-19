import 'package:flutter/material.dart';

class CardEncuesta extends StatelessWidget {
  final String titulo;
  final String proyecto;
  final VoidCallback onResponder;

  const CardEncuesta({
    Key? key,
    required this.titulo,
    required this.proyecto,
    required this.onResponder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.star_border, color: Colors.blue),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(proyecto),
        trailing: ElevatedButton(
          onPressed: onResponder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text("Responder"),
        ),
      ),
    );
  }
}

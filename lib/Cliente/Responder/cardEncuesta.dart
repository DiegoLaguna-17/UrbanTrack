import 'package:flutter/material.dart';
import 'package:urban_track/Cliente/Responder/responder.dart';
class EncuestaCard extends StatelessWidget {
  final int idCliente;
  final String idEncuesta;
  final String titulo;
  final String descripcion;
  final VoidCallback? onTap;
  final VoidCallback? onButtonPressed; // acción del botón


  const EncuestaCard({
    super.key,
    required this.idCliente,
    required this.idEncuesta,
    required this.titulo,
    required this.descripcion,
    this.onTap,
    this.onButtonPressed
  });

  @override
Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.star_border, color:Color.fromARGB(255, 10, 128, 251)),
        title: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(descripcion),
        onTap: onTap,
       trailing: ElevatedButton(
          onPressed: onButtonPressed ?? () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EncuestaPage(
          idEncuesta: this.idEncuesta,
          proyecto: this.descripcion,
          idCliente: this.idCliente,
        ),
      ),
    );

    if (result == true) {
      // Llamamos al callback del card o recargamos desde el padre
      if (onTap != null) {
        onTap!(); // podemos usar onTap para notificar al padre
      }
    }
  },
 // asegura que NO sea null
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 95,255,18), // fondo azul
            foregroundColor: Colors.white,                             // texto blanco
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child:Text("Resumen",style: TextStyle(color: Colors.black),),
        ),
      ),
    );
  }
}

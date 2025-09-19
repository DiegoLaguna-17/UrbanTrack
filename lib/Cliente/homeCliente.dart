import 'package:flutter/material.dart';
import 'package:urban_track/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'listaEncuestas/encuestas.dart';

class HomeCliente extends StatelessWidget {
  final int clienteId; //OJO PARA PRODUCTO FINAL ELIMINAR ESTA LINEA
  const HomeCliente({super.key, required this.clienteId}); //OJO PARA PRODUCTO FINAL ELIMINAR EL CAMPO ID -> const HomeCliente({super.key});

  void _cerrarSesion(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: 'Cerrar Sesión',
      desc: '¿Estás seguro de que quieres salir?',
      btnCancelText: 'Cancelar',
      btnCancelOnPress: () {},
      btnOkText: 'Salir',
      btnOkOnPress: () {
        // Navegar al login y limpiar el stack de navegación
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      },
      btnOkColor: Colors.red,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente - UrbanTrack'),
        backgroundColor: const Color.fromARGB(255, 74, 175, 76),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: EncuestasPage(clienteId: clienteId),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:urban_track/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Bienvenido Cliente',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí verás tus encuestas disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:urban_track/Administrador/CrearEncuesta/crearEncuesta.dart';
// import 'package:urbantrack/Admin/encuestas_data.dart'; // ya no hace falta aquí
// import 'package:urbantrack/Admin/card_encuesta.dart'; // tampoco

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Ahora solo usamos el widget importado
    Widget body;
    if (_currentIndex == 0) {
      body = const Center(child: Text("Encuestas publicadas", style: TextStyle(fontSize: 24))); // <--- aquí
    } else if (_currentIndex == 1) {
      body=const CrearEncuestaPage();
    } else if (_currentIndex == 2) {
      body = const Center(child: Text("⚙️ Configuración", style: TextStyle(fontSize: 24)));
    } else {
      body = const Center(child: Text("Otra pestaña", style: TextStyle(fontSize: 24)));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color.fromARGB(255, 10, 128, 251),
        selectedItemColor: const Color.fromARGB(255, 10, 128, 251),
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: "Encuestas"),
          BottomNavigationBarItem(icon: Icon(Icons.file_download), label: "Crear"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Agregar"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Salir"),
        ],
      ),
    );
  }
}

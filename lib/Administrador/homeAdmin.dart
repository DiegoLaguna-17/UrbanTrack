import 'package:flutter/material.dart';
import 'package:urban_track/Administrador/CrearEncuesta/crearEncuesta.dart';
import 'package:urban_track/Administrador/agregarUsuario/agregar_usuario.dart';
import 'package:urban_track/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class HomeAdmin extends StatefulWidget {
  final int idAdmin;
  const HomeAdmin({required this.idAdmin});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _currentIndex = 0;

  void _handleBottomNavTap(int index) {
    if (index == 3) {
      _cerrarSesion(context);
    } else {
      setState(() => _currentIndex = index);
    }
  }

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

    Widget body;
    if (_currentIndex == 0) {
      body = const Center(child: Text("Encuestas publicadas", style: TextStyle(fontSize: 24)));
    } else if (_currentIndex == 1) {
      body = CrearEncuestaPage(idAdmin:widget.idAdmin);
    } else if (_currentIndex == 2) {
      body = const AgregarUsuarioPage();
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
        currentIndex: _currentIndex < 3 ? _currentIndex : 0, 
        onTap: _handleBottomNavTap, 
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

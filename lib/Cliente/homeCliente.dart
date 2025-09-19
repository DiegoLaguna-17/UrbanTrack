import 'package:flutter/material.dart';
import 'package:urban_track/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:urban_track/Cliente/Responder/listaEncuestas.dart';
import 'package:urban_track/Cliente/Respuestas/respuestas.dart';
class HomeCliente extends StatefulWidget {
  final int idCliente;
  const HomeCliente({required this.idCliente});

  @override
  State<HomeCliente> createState() => _HomeClienteState();
}

class _HomeClienteState extends State<HomeCliente> {
    int _currentIndex = 0;

  void _handleBottomNavTap(int index) {
    if (index == 2) {
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
      body =EncuestasTab(idCliente:widget.idCliente);
    } else if (_currentIndex == 1) {
      body = RespuestasTab(idCliente: widget.idCliente);
    } 
    else {
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
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 10, 128, 251),
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: "Responder"),
          BottomNavigationBarItem(icon: Icon(Icons.file_download), label: "Respuestas"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Salir"),
        ],
      ),
      
    );
  }
}
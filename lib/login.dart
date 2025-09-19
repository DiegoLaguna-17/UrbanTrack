import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:urban_track/Administrador/homeAdmin.dart';
import 'package:urban_track/Cliente/homeCliente.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_isLoading) return;
    
    if (_usuarioController.text.isEmpty || _contrasenaController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Usuario y contraseña son requeridos';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final Map<String, dynamic> loginData = {
        "usuario": _usuarioController.text,
        "contraseña": _contrasenaController.text,
      };
      
      final response = await http.post(
        Uri.parse('https://utbackend-xn26.onrender.com/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final user = responseData['user'];
        final userType = user['tipo'];
        int id=user['id'];
        // Mostrar diálogo de éxito
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Éxito',
          desc: 'Inicio de sesión exitoso',
          btnOkOnPress: () {
            // Navegar a la pantalla correspondiente después de cerrar el diálogo
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                if (userType == 'administrador') {
                  return  HomeAdmin(idAdmin:id);
                } else if (userType == 'cliente') {
                  return  HomeCliente(idCliente:id);
                } else {
                  return const LoginPage();
                }
              }),
            );
          },
        ).show();
        
      } else {
        // Mostrar diálogo de error
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al iniciar sesión, verifique sus datos',
          btnOkOnPress: () {},
        ).show();
        
        setState(() {
          _errorMessage = responseData['error'] ?? 'Error en el login';
        });
      }
    } catch (e) {
      // Mostrar diálogo de error de conexión
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error de conexión',
        desc: 'No se pudo conectar con el servidor',
        btnOkOnPress: () {},
      ).show();
      
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 128, 251),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo - Reemplazar con imagen
                    // Guarda tu imagen en: assets/images/logo_urban_track.png
                    Image.asset(
                      'assets/images/logo_urban_track.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    
                    // Título con "Urban" en verde y "Track" en azul
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Urban',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: 'Track',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 10, 128, 251),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Campo Usuario con label encima
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Usuario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _usuarioController,
                          decoration: const InputDecoration(
                            hintText: 'Ingrese su usuario',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo Contraseña con label encima
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Contraseña',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _contrasenaController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Ingrese su contraseña',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Mensaje de error
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 10, 128, 251),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
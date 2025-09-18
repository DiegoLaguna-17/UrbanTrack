import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class AgregarAdminForm extends StatefulWidget {
  const AgregarAdminForm({super.key});

  @override
  State<AgregarAdminForm> createState() => _AgregarAdminFormState();
}

class _AgregarAdminFormState extends State<AgregarAdminForm> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _registrarAdministrador() async {
    if (_isSubmitting) return;
    
    // Validaciones
    if (_usuarioController.text.isEmpty || 
        _contrasenaController.text.isEmpty || 
        _confirmarContrasenaController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Campos requeridos',
        desc: 'Todos los campos son obligatorios',
        btnOkOnPress: () {},
      ).show();
      return;
    }
    
    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Contraseñas no coinciden',
        desc: 'Las contraseñas no coinciden',
        btnOkOnPress: () {},
      ).show();
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    final Map<String, dynamic> adminData = {
      "usuario": _usuarioController.text,
      "contraseña": _contrasenaController.text,
    };
    
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/users/admin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(adminData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '¡Éxito!',
          desc: 'Administrador registrado correctamente',
          btnOkOnPress: () {
            // Limpiar formulario después de cerrar el diálogo
            _usuarioController.clear();
            _contrasenaController.clear();
            _confirmarContrasenaController.clear();
          },
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al registrar administrador: ${response.statusCode}',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error de conexión',
        desc: 'No se pudo conectar con el servidor: $e',
        btnOkOnPress: () {},
      ).show();
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _limpiarFormulario() {
    _usuarioController.clear();
    _contrasenaController.clear();
    _confirmarContrasenaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Celeste muy claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)), // Azul oscuro
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete los datos del administrador:',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1), // Azul oscuro
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo Usuario
              const Text(
                'Usuario:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1), // Azul oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre de usuario',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1976D2)), // Azul oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2), // Azul oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo Contraseña
              const Text(
                'Contraseña:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1), // Azul oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingrese la contraseña',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1976D2)), // Azul oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2), // Azul oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo Confirmar Contraseña
              const Text(
                'Confirmar Contraseña:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1), // Azul oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmarContrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirme la contraseña',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1976D2)), // Azul oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2), // Azul oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 30),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón Limpiar
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _limpiarFormulario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Limpiar', 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Botón Registrar
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _registrarAdministrador,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1), // Azul oscuro
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrar', 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
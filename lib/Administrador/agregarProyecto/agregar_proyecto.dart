import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class AgregarProyectoPage extends StatefulWidget {
  const AgregarProyectoPage({super.key});

  @override
  State<AgregarProyectoPage> createState() => _AgregarProyectoPageState();
}

class _AgregarProyectoPageState extends State<AgregarProyectoPage> {
  final TextEditingController _nombreController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _registrarProyecto() async {
    if (_isSubmitting) return;
    
    // Validaciones
    if (_nombreController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Campo requerido',
        desc: 'El nombre del proyecto es obligatorio',
        btnOkOnPress: () {},
      ).show();
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final Map<String, dynamic> proyectoData = {
        "nombre": _nombreController.text,
      };
      
      final response = await http.post(
        Uri.parse('https://utbackend-xn26.onrender.com/proyectos'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(proyectoData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mostrar diálogo de éxito
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '¡Éxito!',
          desc: 'Proyecto registrado correctamente',
          btnOkOnPress: () {
            // Limpiar formulario después de cerrar el diálogo
            _nombreController.clear();
          },
        ).show();
      } else {
        final errorData = jsonDecode(response.body);
        // Mostrar diálogo de error
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al registrar proyecto: ${errorData['error'] ?? response.statusCode}',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      // Mostrar diálogo de error de conexión
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
    _nombreController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1B5E20), // Verde oscuro
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Registrar Nuevo Proyecto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255,10,128,251), // Verde oscuro
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo Nombre
              const Text(
                'Nombre del proyecto:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre del proyecto',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF388E3C)), // Verde oscuro brillante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2), // Verde oscuro brillante
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
                  
                  // Botón Registrar (verde oscuro)
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _registrarProyecto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255,95,255,18), // Verde oscuro
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
                              color: Colors.black,
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
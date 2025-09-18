import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class AgregarClienteForm extends StatefulWidget {
  const AgregarClienteForm({super.key});

  @override
  State<AgregarClienteForm> createState() => _AgregarClienteFormState();
}

class _AgregarClienteFormState extends State<AgregarClienteForm> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _proyectos = [];
  String? _selectedProyectoId;
  bool _loadingProyectos = true;

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _cargarProyectos() async {
    try {
      final response = await http.get(
        Uri.parse('https://utbackend-xn26.onrender.com/proyectos'),
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _proyectos = data.map((e) => {'id': e['id'], 'nombre': e['nombre']}).toList();
          _loadingProyectos = false;
        });
      } else {
        setState(() {
          _loadingProyectos = false;
        });
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al cargar proyectos',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      setState(() {
        _loadingProyectos = false;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error de conexión',
        desc: 'Error al cargar proyectos: $e',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> _registrarCliente() async {
    if (_isSubmitting) return;
    
    // Validaciones
    if (_usuarioController.text.isEmpty || 
        _contrasenaController.text.isEmpty || 
        _confirmarContrasenaController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _selectedProyectoId == null) {
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
    
    try {
      final Map<String, dynamic> clienteData = {
        "nombre": _nombreController.text,
        "apellido": _apellidoController.text,
        "usuario": _usuarioController.text,
        "contraseña": _contrasenaController.text,
        "rol": "cliente",
        "proyectoId": int.parse(_selectedProyectoId!)
      };
      
      final response = await http.post(
        Uri.parse('http://localhost:3000/users/cliente'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(clienteData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '¡Éxito!',
          desc: 'Cliente registrado correctamente',
          btnOkOnPress: () {
            _limpiarFormulario();
          },
        ).show();
      } else {
        final errorData = jsonDecode(response.body);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al registrar cliente: ${errorData['error'] ?? response.statusCode}',
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
    _nombreController.clear();
    _apellidoController.clear();
    setState(() {
      _selectedProyectoId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Verde claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1B5E20), // Verde oscuro
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar Cliente',
          style: TextStyle(
            color: const Color(0xFF1B5E20), // Verde oscuro
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete los datos del cliente:',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo Usuario
              const Text(
                'Usuario:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre de usuario',
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
              const SizedBox(height: 16),
              
              // Campo Contraseña
              const Text(
                'Contraseña:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingrese la contraseña',
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
              const SizedBox(height: 16),
              
              // Campo Confirmar Contraseña
              const Text(
                'Confirmar Contraseña:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmarContrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirme la contraseña',
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
              const SizedBox(height: 16),
              
              // Campo Nombre
              const Text(
                'Nombre:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre',
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
              const SizedBox(height: 16),
              
              // Campo Apellido
              const Text(
                'Apellido:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apellidoController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el apellido',
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
              const SizedBox(height: 16),
              
              // Campo Proyecto (Dropdown)
              const Text(
                'Proyecto:', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 8),
              _loadingProyectos
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedProyectoId,
                      hint: const Text('Seleccione un proyecto'),
                      items: _proyectos.map((proyecto) {
                        return DropdownMenuItem<String>(
                          value: proyecto['id'].toString(),
                          child: Text(
                            proyecto['nombre'],
                            style: const TextStyle(color: Color(0xFF1B5E20)), // Verde oscuro
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProyectoId = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF388E3C)), // Verde oscuro brillante
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2), // Verde oscuro brillante
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
              const SizedBox(height: 30),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón Cancelar
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
                      'Cancelar', 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Botón Registrar
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _registrarCliente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20), // Verde oscuro
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
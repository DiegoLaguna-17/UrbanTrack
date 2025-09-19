import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Data Model Tests', () {

    test('Encuesta model should parse JSON correctly', () {
      final Map<String, dynamic> json = {
        'id': 101,
        'titulo': 'Test Survey Title',
        'proyecto': 'Community Park Project'
      };

      final encuesta = Encuesta.fromJson(json);

      expect(encuesta.id, 101);
      expect(encuesta.titulo, 'Test Survey Title');
      expect(encuesta.proyecto, 'Community Park Project');
    });

    test('Proyecto model should parse JSON correctly', () {
      final Map<String, dynamic> json = {
        'id': 22,
        'nombre': 'Downtown Revitalization'
      };

      final proyecto = Proyecto.fromJson(json);

      expect(proyecto.id, 22);
      expect(proyecto.nombre, 'Downtown Revitalization');
    });

  });
}

class Encuesta {
  final int id;
  final String titulo;
  final String? proyecto;
  Encuesta({required this.id, required this.titulo, this.proyecto});

  factory Encuesta.fromJson(Map<String, dynamic> json) {
    return Encuesta(
      id: json['id'],
      titulo: json['titulo'],
      proyecto: json['proyecto'],
    );
  }
}

class Proyecto {
  final int id;
  final String nombre;
  Proyecto({required this.id, required this.nombre});

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
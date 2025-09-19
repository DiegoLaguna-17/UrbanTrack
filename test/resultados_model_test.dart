import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VerResultados Data Models', () {
    test('PreguntaOpcionMultipleData should parse JSON correctly', () {
      final Map<String, dynamic> json = {
        "idpregunta": 7,
        "pregunta": "What is your favorite color?",
        "tipo": "opcion_multiple",
        "total_respuestas": 10,
        "opciones": [
          {
            "opcion": "Blue",
            "conteo": 5,
            "porcentaje": 50.0
          },
          {
            "opcion": "Red",
            "conteo": 5,
            "porcentaje": 50.0
          }
        ]
      };

      final pregunta = PreguntaOpcionMultipleData.fromJson(json);

      expect(pregunta.id, 7);
      expect(pregunta.titulo, "What is your favorite color?");
      expect(pregunta.tipo, "opcion_multiple");
      expect(pregunta.totalRespuestas, 10);
      expect(pregunta.opciones.length, 2);
      expect(pregunta.opciones[0].opcion, "Blue");
      expect(pregunta.opciones[0].conteo, 5);
      expect(pregunta.opciones[0].porcentaje, 50.0);
    });

    test('PreguntaAbiertaData should parse JSON correctly', () {
      final Map<String, dynamic> json = {
        "idpregunta": 8,
        "pregunta": "Any suggestions?",
        "respuestas": [
          "More features please.",
          "Great app!"
        ]
      };

      final pregunta = PreguntaAbiertaData.fromJson(json);

      expect(pregunta.id, 8);
      expect(pregunta.titulo, "Any suggestions?");
      expect(pregunta.respuestas.length, 2);
      expect(pregunta.respuestas[0], "More features please.");
    });
  });
}

class OpcionData {
  final String opcion;
  final int conteo;
  final double porcentaje;

  OpcionData({
    required this.opcion,
    required this.conteo,
    required this.porcentaje,
  });

  factory OpcionData.fromJson(Map<String, dynamic> json) {
    return OpcionData(
      opcion: json['opcion'],
      conteo: json['conteo'],
      porcentaje: (json['porcentaje'] ?? 0.0).toDouble(),
    );
  }
}

class PreguntaOpcionMultipleData {
  final int id;
  final String titulo;
  final String tipo;
  final int totalRespuestas;
  final List<OpcionData> opciones;

  PreguntaOpcionMultipleData({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.totalRespuestas,
    required this.opciones,
  });

  factory PreguntaOpcionMultipleData.fromJson(Map<String, dynamic> json) {
    return PreguntaOpcionMultipleData(
      id: json['idpregunta'],
      titulo: json['pregunta'],
      tipo: json['tipo'],
      totalRespuestas: json['total_respuestas'],
      opciones: (json['opciones'] as List)
          .map((op) => OpcionData.fromJson(op))
          .toList(),
    );
  }
}

class PreguntaAbiertaData {
  final int id;
  final String titulo;
  final List<String> respuestas;

  PreguntaAbiertaData({
    required this.id,
    required this.titulo,
    required this.respuestas,
  });

  factory PreguntaAbiertaData.fromJson(Map<String, dynamic> json) {
    return PreguntaAbiertaData(
      id: json['idpregunta'],
      titulo: json['pregunta'],
      respuestas: List<String>.from(json['respuestas']),
    );
  }
}
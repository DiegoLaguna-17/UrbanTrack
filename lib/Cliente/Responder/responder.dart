import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
Future<Encuesta> fetchEncuesta(String idEncuesta) async {
  final url = Uri.parse('https://utbackend-xn26.onrender.com/encuesta/preguntas/$idEncuesta');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return Encuesta.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error al cargar la encuesta');
  }
}

class EncuestaPage extends StatefulWidget {
  final int idCliente;
  final String idEncuesta;
  final String proyecto;
  const EncuestaPage({Key? key, required this.idEncuesta, required this.proyecto,required this.idCliente}) : super(key: key);

  @override
  _EncuestaPageState createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  late Future<Encuesta> encuestaFuture;
  Map<int, dynamic> respuestas = {}; // idPregunta -> respuesta (texto o idOpcion)

  @override
  void initState() {
    super.initState();
    encuestaFuture = fetchEncuesta(widget.idEncuesta);
  }

  Widget buildPregunta(Pregunta p, int numero) {
    switch (p.tipo) {
      case 'abierta':
        return Column(

            crossAxisAlignment: CrossAxisAlignment.start,
          children:[
                        SizedBox(height: 10,),

            Text('$numero. ${p.pregunta}', style: TextStyle(fontSize: 20),),
            SizedBox(height: 8,),
             TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => respuestas[p.idPregunta] = val,
            ),
          ]
        );
      case 'opcion_multiple':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Text('$numero. ${p.pregunta}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ...p.opciones.map((o) => RadioListTile<int>(
                  title: Text(o.opcion),
                  value: o.idOpcion,
                  groupValue: respuestas[p.idPregunta],
                  onChanged: (val) => setState(() => respuestas[p.idPregunta] = val),
                ))
          ],
        );
     case 'escala':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            '$numero. ${p.pregunta}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 8),
          Row(
            children: p.opciones.map((o) {
              return Expanded( // Para que se reparta el espacio
                child: Row(
                  children: [
                    Radio<int>(
                      value: o.idOpcion,
                      groupValue: respuestas[p.idPregunta],
                      onChanged: (value) {
                        setState(() {
                          respuestas[p.idPregunta] = value;
                        });
                      },
                    ),
                    Flexible(child: Text(o.opcion, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );

      default:
        return SizedBox();
    }
  }
void enviarRespuestas() async {
  final url = Uri.parse("https://utbackend-xn26.onrender.com/encuesta/responder");

  // Adaptamos el Map<int,dynamic> a una lista de objetos para enviar
  final respuestasList = respuestas.entries.map((entry) {
    final idPregunta = entry.key;
    final value = entry.value;
    if (value is int) {
      // es idOpcion
      return {
        "idPregunta": idPregunta,
        "idOpcion": value,
      };
    } else {
      // es texto
      return {
        "idPregunta": idPregunta,
        "contenido_texto": value,
      };
    }
  }).toList();

  final body = {
    "idEncuesta": int.parse(widget.idEncuesta),
    "idCliente": widget.idCliente, // 👈 aquí pones el cliente logueado
    "respuestas": respuestasList,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    await AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '¡Éxito!',
          desc: 'Respuesta registrada correctamente',
          btnOkOnPress: () {
          },
        ).show();
    Navigator.pop(context,true); // volver atrás si quieres
  } else {
   await AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error al registrar respuesta',
          btnOkOnPress: () {},
        ).show();

  }

}

void confirmarYEnviar() {
  // Chequear que todas las preguntas tengan respuesta
  encuestaFuture.then((encuesta) {
    final totalPreguntas = encuesta.preguntas.length;
    final totalRespondidas = respuestas.keys.length;

    // Revisamos que no falte ninguna respuesta
    bool todasRespondidas = encuesta.preguntas.every((p) => respuestas[p.idPregunta] != null && respuestas[p.idPregunta].toString().trim().isNotEmpty);

    if (!todasRespondidas) {
      // Mostrar diálogo de error
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Faltan respuestas',
        desc: 'Debes responder todas las preguntas antes de enviar.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    // Si todo está respondido, mostramos diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar envío"),
        content: Text("¿Estás seguro de enviar tus respuestas?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255,95,255,18),

            ),
            onPressed: () {
              Navigator.pop(context); // cerrar diálogo
              enviarRespuestas();     // llamar al POST real
            },
            child: Text("Enviar",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( elevation: 0,
        toolbarHeight: 0,),
      body: FutureBuilder<Encuesta>(
        future: encuestaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final encuesta = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(encuesta.titulo,
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromARGB(255,10,128,251))),
                SizedBox(height: 20),
                 Text(widget.proyecto,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color.fromARGB(255,10,128,251))),
                SizedBox(height: 10),
                ...encuesta.preguntas.asMap().entries.map((entry) {
                  int index = entry.key;        // índice: 0, 1, 2...
                  Pregunta p = entry.value;     // la pregunta en sí
                  return buildPregunta(p, index + 1); // +1 para que empiece en 1
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: confirmarYEnviar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255,95,255,18), // Color de fondo personalizado
                    foregroundColor: Colors.black,       // Color del texto
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // tamaño más grande
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // bordes un poco redondeados
                    ),
                    textStyle: TextStyle(
                      fontSize: 20, // tamaño de letra más grande
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text("Enviar"),
                ),

              ],
            );
          } else {
            return Center(child: Text("No hay datos"));
          }
        },
      ),
    );
  }
  
}


class Encuesta {
  final String titulo;
  final List<Pregunta> preguntas;

  Encuesta({required this.titulo, required this.preguntas});

  factory Encuesta.fromJson(Map<String, dynamic> json) {
    return Encuesta(
      titulo: json['titulo'],
      preguntas: (json['preguntas'] as List)
          .map((p) => Pregunta.fromJson(p))
          .toList(),
    );
  }
}

class Pregunta {
  final int idPregunta;
  final String pregunta;
  final String tipo;
  final List<Opcion> opciones;

  Pregunta({
    required this.idPregunta,
    required this.pregunta,
    required this.tipo,
    this.opciones = const [],
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      idPregunta: json['idpregunta'],
      pregunta: json['pregunta'],
      tipo: json['tipo'],
      opciones: json['opciones'] != null
          ? (json['opciones'] as List)
              .map((o) => Opcion.fromJson(o))
              .toList()
          : [],
    );
  }
}

class Opcion {
  final int idOpcion;
  final String opcion;

  Opcion({required this.idOpcion, required this.opcion});

  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(
      idOpcion: json['idopcion'],
      opcion: json['opcion'],
    );
  }
}

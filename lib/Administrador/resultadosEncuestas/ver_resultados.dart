import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class PreguntaData {
  final int id;
  final String titulo;
  final String tipo;
  final int totalRespuestas;
  final List<OpcionData> opciones;

  PreguntaData({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.totalRespuestas,
    required this.opciones,
  });

  factory PreguntaData.fromJson(Map<String, dynamic> json) {
    return PreguntaData(
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
      porcentaje: json['porcentaje'] is int
          ? (json['porcentaje'] as int).toDouble()
          : json['porcentaje'],
    );
  }
}

class VerResultados extends StatefulWidget {
  final int encuestaId;
  final String encuestaTitulo;

  const VerResultados({
    super.key,
    required this.encuestaId,
    required this.encuestaTitulo,
  });

  @override
  State<VerResultados> createState() => _VerResultadosState();
}

class _VerResultadosState extends State<VerResultados> {
  int totalRespuestas = 0;
  List<PreguntaData> preguntas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResultados();
  }

  Future<void> fetchResultados() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/encuestas/${widget.encuestaId}/resultados'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          totalRespuestas = data['totalRespuestas'];
          preguntas = (data['preguntas'] as List)
              .map((p) => PreguntaData.fromJson(p))
              .toList();
        });
        print('Resultados obtenidos con éxito');
      } else {
        print('Error al cargar resultados: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión o datos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildPieChart(PreguntaData pregunta) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: pregunta.opciones.asMap().entries.map((entry) {
                    final index = entry.key;
                    final opcion = entry.value;
                    return PieChartSectionData(
                      color: Colors.primaries[index % Colors.primaries.length],
                      value: opcion.porcentaje,
                      title: '${opcion.opcion}\n${opcion.porcentaje.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBarChart(PreguntaData pregunta) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barGroups: pregunta.opciones.asMap().entries.map((entry) {
                      final index = entry.key;
                      final opcion = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: opcion.porcentaje,
                            color: Colors.primaries[index % Colors.primaries.length],
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, TitleMeta meta) {
                            final opcion = pregunta.opciones[value.toInt()];
                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: Text(opcion.opcion, style: const TextStyle(fontSize: 10)),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 20, reservedSize: 44),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0xffececec),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final opcion = pregunta.opciones[groupIndex];
                          return BarTooltipItem(
                            '${opcion.opcion}\n${opcion.porcentaje.toStringAsFixed(1)}%',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        title: Text(widget.encuestaTitulo),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total de Respuestas',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            totalRespuestas.toString(),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (preguntas.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No hay respuestas de opción múltiple para mostrar.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                  ...preguntas.map((pregunta) {
                    if (pregunta.opciones.isEmpty || pregunta.totalRespuestas == 0) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        Text(
                          pregunta.titulo,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          width: 500, 
                          child: buildPieChart(pregunta),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          width: 500,
                          child: buildBarChart(pregunta),
                        ),
                        const Divider(height: 40),
                      ],
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
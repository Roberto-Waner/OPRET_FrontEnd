import 'package:flutter/material.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_Respuestas.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphicRespScreen extends StatefulWidget {
  final List<SpFiltrarRespuestas> data;
  
  const GraphicRespScreen({super.key, required this.data});

  @override
  State<GraphicRespScreen> createState() => _GraphicRespScreenState();
}

class _GraphicRespScreenState extends State<GraphicRespScreen> {
  // bool _showLegend = true;

  @override
  Widget build(BuildContext context) {
    // Datos para la primera gráfica
    Map<String, int> frecuencias = obtenerFrecuencias(widget.data);
    List<ChartData> chartData = frecuencias.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    // Datos para la segunda gráfica (subpreguntas)
    Map<String, int> subFrecuencias = obtenerSubFrecuencias(widget.data);
    List<ChartData> subChartData = subFrecuencias.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    return Scaffold(
      appBar: AppBar( title: const Text('Gráfica de Respuestas'), ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Primera gráfica: Pie chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 1150, // Ajustar altura según sea necesario
              child: SfCircularChart(
                //texto del título
                title: const ChartTitle(
                  text: 'Preguntas y Respuestas',
                  textStyle: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  )
                ),
                //texto de la leyenda
                legend: const Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.scroll, // Ajusta el orden de los item de la leyendas
                  textStyle: TextStyle(fontSize: 18), // Tamaño del texto de la leyenda
                  position: LegendPosition.bottom, // posiciona la Leyendas en cualquier parte de la gráfico
                  orientation: LegendItemOrientation.vertical, // para organizar las leyendas en horizontal
                  isResponsive: true,
                  iconHeight: 20.0,
                  iconWidth: 20.0,
                  
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  textStyle: const TextStyle(
                    fontSize: 18, // Aumentar el tamaño del texto del tooltip
                    fontWeight: FontWeight.bold,
                  )
                ),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.respuesta,
                    yValueMapper: (ChartData data, _) => data.frecuencia,
                    //texto de las etiquetas
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    explode: true, // Resalta las secciones
                    explodeIndex: 0, // Primera sección explotada por defecto
                    enableTooltip: true,
                    animationDuration: 1000,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Segunda gráfica: Radial bar chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 1150,
              child: SfCircularChart(
                title: const ChartTitle(
                  text: 'Subpreguntas',
                  textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                legend: const Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.scroll,
                  textStyle: TextStyle(fontSize: 18),
                  position: LegendPosition.bottom,
                  orientation: LegendItemOrientation.vertical,
                  isResponsive: true,
                  iconHeight: 20.0,
                  iconWidth: 20.0,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  textStyle: const TextStyle(
                    fontSize: 18, // Aumentar el tamaño del texto del tooltip
                    fontWeight: FontWeight.bold,
                  )
                ),
                series: <DoughnutSeries>[
                  DoughnutSeries<ChartData, String>(
                    dataSource: subChartData,
                    xValueMapper: (ChartData data, _) => data.respuesta,
                    yValueMapper: (ChartData data, _) => data.frecuencia,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    innerRadius: '50%', // Tamaño del hueco central del doughnut
                    explode: true,
                    enableTooltip: true,
                    
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}

class ChartData {
  final String respuesta;
  final int frecuencia;

  ChartData(this.respuesta, this.frecuencia);
}

// Obtener frecuencias para la primera gráfica (preguntas principales)
Map<String, int> obtenerFrecuencias(List<SpFiltrarRespuestas> data) {
  Map<String, int> frecuencias = {};
  for (var respuesta in data) {
    if (respuesta.sp_Respuestas != null && respuesta.sp_Respuestas!.isNotEmpty) {
      String preguntaRespuesta = '${respuesta.sp_NoEncuesta}: ${respuesta.sp_Preguntas}: ${respuesta.sp_Respuestas}';
      frecuencias[preguntaRespuesta] = (frecuencias[preguntaRespuesta] ?? 0) + 1;
    }
  }
  return frecuencias;
}

// Obtener frecuencias para la segunda gráfica (subpreguntas)
Map<String, int> obtenerSubFrecuencias(List<SpFiltrarRespuestas> data) {
  Map<String, int> frecuencias = {};
  for (var respuesta in data) {
    if (respuesta.sp_Respuestas != null && respuesta.sp_Respuestas!.isNotEmpty) {
      String subPregunta = '${respuesta.sp_NoEncuesta}: ${respuesta.sp_SupPreguntas}: ${respuesta.sp_Respuestas}';
      frecuencias[subPregunta] = (frecuencias[subPregunta] ?? 0) + 1;
    }
  }
  return frecuencias;
}
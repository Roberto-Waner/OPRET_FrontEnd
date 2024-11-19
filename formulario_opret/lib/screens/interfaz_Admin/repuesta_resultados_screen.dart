import 'package:flutter/material.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_Respuestas.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/respuestas_services.dart';

class RepuestaResultadosScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const RepuestaResultadosScreen({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<RepuestaResultadosScreen> createState() => _RepuestaResultadosScreenState();
}

class _RepuestaResultadosScreenState extends State<RepuestaResultadosScreen> {
  final ApiServiceRespuesta _apiServiceRespuesta =  ApiServiceRespuesta('https://10.0.2.2:7190');
  late Future<List<SpFiltrarRespuestas>> _respuestaData;

  @override
  void initState() {
    super.initState();
    _refreshRespuesta();
  }

  Future<void> _refreshRespuesta() async {
    setState(() {
      _respuestaData = _apiServiceRespuesta.getRespuestas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(
        filtrarUsuarioController: widget.filtrarUsuarioController,
        filtrarEmailController: widget.filtrarEmailController,
        filtrarId: widget.filtrarId,
        filtrarCedula: widget.filtrarCedula,
      ),

      appBar: AppBar(
        title: const Text('Tablas de Respuestas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() {
                _refreshRespuesta();
              });
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: FutureBuilder<List<SpFiltrarRespuestas>>(
          future: _respuestaData, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }else if (snapshot.hasError){
              return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
            } else {
              final answerData = snapshot.data ?? [];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID del Usuario', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Cedula de Identida', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Nombre y Apellido', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Usuarios', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('No. Encuesta', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Nomero de Sesion', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Nomero de Pregunta', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Pregunta', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Nomero de Sub-Pregunta', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Sub-Pregunta', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Respuesta', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Comentarios', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Justificacion', style: TextStyle(fontSize: 23.0))),
                  ], 
                  rows: answerData.map((answer) {
                    return DataRow(
                      cells: [
                        DataCell(Text(answer.sp_IdUsuarios!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_Cedula!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_NombreApellido!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_Usuarios!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_NoEncuesta!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_IdSesion.toString(), style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_CodPreguntas.toString(), style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(answer.sp_Preguntas!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(answer.sp_CodSupPreguntas != null ? Text(answer.sp_CodSupPreguntas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                        DataCell(answer.sp_SupPreguntas != null ? Text(answer.sp_SupPreguntas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                        DataCell(answer.sp_Respuestas != null ? Text(answer.sp_Respuestas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                        DataCell(answer.sp_Comentarios != null ? Text(answer.sp_Comentarios!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                        DataCell(answer.sp_Justificacion != null ? Text(answer.sp_Justificacion!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                      ]
                    );
                  }).toList(),
                ),
              );
            }
          }
        ),
      ),
    );
  }
}
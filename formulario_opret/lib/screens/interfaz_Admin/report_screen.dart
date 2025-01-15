import 'package:flutter/material.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/screens/interfaz_Admin/report_Formulario.dart';
import 'package:formulario_opret/screens/interfaz_Admin/repuesta_resultados_screen.dart';

class ReportScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;

  const ReportScreen({
    super.key,
    required this.filtrarId,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        drawer: Navbar(
          filtrarUsuarioController: widget.filtrarUsuarioController,
          filtrarEmailController: widget.filtrarEmailController,
          filtrarId: widget.filtrarId,
        ),

        appBar: AppBar(title: const Text('Tablas de Reportes')),

        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.assessment, size: 30.0),
              title: const Text(
                'Reportes de Formularios',
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportFormulario(
                    filtrarUsuarioController: widget.filtrarUsuarioController,
                    filtrarEmailController: widget.filtrarEmailController,
                    filtrarId: widget.filtrarId,
                    // // filtrarCedula: widget.filtrarCedula,
                  ))
                );
              }
            ),

            ListTile(
              leading: const Icon(Icons.summarize, size: 30.0),
              title: const Text(
                'Reporte de Respuestas',
                style: TextStyle(fontSize: 20.0), // Aquí se cambia el tamaño del texto
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RepuestaResultadosScreen(
                    filtrarUsuarioController: widget.filtrarUsuarioController,
                    filtrarEmailController: widget.filtrarEmailController,
                    filtrarId: widget.filtrarId,
                    // // filtrarCedula: widget.filtrarCedula,
                  ))
                );
              }
            ),
          ],
        ),
      )
    );
  }
}
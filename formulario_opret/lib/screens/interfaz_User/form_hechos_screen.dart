import 'package:flutter/material.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_FormRegistro.dart';
import 'package:formulario_opret/screens/interfaz_User/navbarUser/navbar_Empl.dart';
import 'package:formulario_opret/services/form_Registro_services.dart';

class FormHechosScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const FormHechosScreen({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<FormHechosScreen> createState() => _FormHechosScreenState();
}

class _FormHechosScreenState extends State<FormHechosScreen> {
  final ApiServiceFormRegistro _apiServiceFormRegistro = ApiServiceFormRegistro('https://10.0.2.2:7190');
  late Future<List<SpFiltrarFormRegistro>> _formRegistroData;

  @override
  void initState() {
    super.initState();
    _refreshFormularios();
  }

  Future<void> _refreshFormularios() async {
    setState(() {
      _formRegistroData = _apiServiceFormRegistro.getFormRegistro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavbarEmpl(
        filtrarUsuarioController: widget.filtrarUsuarioController,  
        filtrarEmailController: widget.filtrarEmailController,
        filtrarId: widget.filtrarId,
        filtrarCedula: widget.filtrarCedula,
      ),

      appBar: AppBar(
        title: const Text('Tablas de Formularios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() {
                _refreshFormularios();
              });
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: FutureBuilder<List<SpFiltrarFormRegistro>>(
          future: _formRegistroData, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }else if (snapshot.hasError){
              return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
            } else {
              final formularioData = snapshot.data ?? [];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID del Usuario', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Cedula de Identidad', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Usuarios', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Nombre y Apellido', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Fecha de form. Realizado', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Hora', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Linea de metro', style: TextStyle(fontSize: 23.0))),
                    DataColumn(label: Text('Estacion de metro', style: TextStyle(fontSize: 23.0))),
                    // DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                  ], 
                  rows: formularioData.map((form) {
                    return DataRow(
                      cells: [
                        DataCell(Text(form.sp_IdUsuarios!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_Cedula!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_Usuarios!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_NombreApellido!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_FechaEncuesta!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_HoraEncuesta!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_NombreLinea!, style: const TextStyle(fontSize: 20.0))),
                        DataCell(Text(form.sp_NombrEstacion!, style: const TextStyle(fontSize: 20.0))),
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
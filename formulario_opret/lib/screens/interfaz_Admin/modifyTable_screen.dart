import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/estacion_services.dart';
import 'package:formulario_opret/services/linea_services.dart';

class ModifyTable extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const ModifyTable({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<ModifyTable> createState() => _ModifyTableState();
}

class _ModifyTableState extends State<ModifyTable> {
  final _formKey = GlobalKey<FormFieldState>();
  final ApiServiceLineas _apiServiceLineas = ApiServiceLineas('https://10.0.2.2:7190');
  late Future<List<Linea>> _linea;
  final ApiServiceEstacion _apiServiceEstacion = ApiServiceEstacion('https://10.0.2.2:7190');
  late Future<List<Estacion>> _estacion;

  @override
  void initState() {
    super.initState();
    _linea = _apiServiceLineas.getLinea();
    _estacion = _apiServiceEstacion.getEstacion();
  }

  void _refreshLinea() {
    setState(() {
      _linea = _apiServiceLineas.getLinea();
    });
  }

  void _refreshEstacion() {
    setState(() {
      _estacion = _apiServiceEstacion.getEstacion();
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

      appBar: AppBar(title: const Text('Modificar tabla')),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Tablas de Lineas de Metro',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<Linea>>(
              future: _linea, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }else if(snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la Linea de metro.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                } else {
                  final lineTable = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Id Linea metro', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Tipo de Linea', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Nombre de la Linea', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                      ], 
                      rows: lineTable.map((linasDatos) {
                        return DataRow(
                          cells: [
                            DataCell(Text(linasDatos.idLinea, style: const TextStyle(fontSize: 20.0))), // Conversión explícita de int a String usando .toString()
                            DataCell(Text(linasDatos.tipo, style: const TextStyle(fontSize: 20.0))),
                            DataCell(Text(linasDatos.nombreLinea, style: const TextStyle(fontSize: 20.0))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // _showEditDialog(ask);
                                    }, 
                                    icon: const Icon(Icons.edit)
                                  ),
                                  
                                  IconButton(
                                    onPressed: () {
                                      // _showDeleteDialog(ask);
                                    },
                                    icon: const Icon(Icons.delete)
                                  )
                                ],
                              )
                            )
                          ]
                        );
                      }).toList(),
                    ),
                  );
                }
              }
            ),

            const SizedBox(height: 20),
            const Text(
              'Tablas de Estaciones del Metro',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<Estacion>>(
              future: _estacion, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la tabla de Estaciones del metro.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                } else {
                  final station = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('NO', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Id Linea de metro a la que pertenece', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Estacion', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                      ],
                      rows: station.map((estacion) {
                        return DataRow(
                          cells: [
                            DataCell(Text(estacion.idEstacion.toString(), style: const TextStyle(fontSize: 20.0))),
                            DataCell(Text(estacion.idLinea, style: const TextStyle(fontSize: 20.0))),
                            DataCell(Text(estacion.nombreEstacion, style: const TextStyle(fontSize: 20.0))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // _showEditDialogSubPregunta(sub);
                                    }, 
                                    icon: const Icon(Icons.edit)
                                  ),
                                  
                                  IconButton(
                                    onPressed: () {
                                      // _showDeleteDialogSubPregunta(sub);
                                    },
                                    icon: const Icon(Icons.delete)
                                  )
                                ],
                              )
                            )
                          ]
                        );
                      }).toList(),
                    )
                  );
                }
              }
            )
          ]
        ),
      ),
    );
  }
}
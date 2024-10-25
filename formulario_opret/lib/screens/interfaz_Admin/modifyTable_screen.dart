import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/estacion_services.dart';
import 'package:formulario_opret/services/linea_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';

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
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiServiceLineas _apiServiceLineas = ApiServiceLineas('https://10.0.2.2:7190');
  late Future<List<Linea>> _linea;
  final ApiServiceEstacion _apiServiceEstacion = ApiServiceEstacion('https://10.0.2.2:7190');
  late Future<List<Estacion>> _estacion;
  String _selectedLinea = 'Linea Metro';
  String? _savedLinea;
  Offset position = const Offset(700, 1090); // Posición inicial del botón
  
  List<Linea> _lineas = [];
  // List<Estacion> _estaciones = [];

  @override
  void initState() {
    super.initState();
    _linea = _apiServiceLineas.getLinea();
    _estacion = _apiServiceEstacion.getEstacion();
    _fetchData();
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

  Future<void> _fetchData() async {
    try{
      List<Linea> lineas = await _apiServiceLineas.getLinea();

      setState(() {
        _lineas = lineas;
        print('Lineas obtenidas: $_lineas');
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
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

      body: Stack(
        children: [
          SingleChildScrollView(
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
                                          _showEditDialogLinea(linasDatos);
                                        }, 
                                        icon: const Icon(Icons.edit)
                                      ),
                                      
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteDialogLinea(linasDatos);
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
                                          _showEditDialogEstacion(estacion);
                                        }, 
                                        icon: const Icon(Icons.edit)
                                      ),
                                      
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteDialogEstacion(estacion);
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
                ),
              ],
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: _bottonSaveSpeedDial(),
              childWhenDragging: Container(), // Widget que aparece en la posición original mientras se arrastra
              onDragEnd: (details) {
                setState(() {
                  // Limitar la posición del botón a los límites de la pantalla
                  double dx = details.offset.dx;
                  double dy = details.offset.dy;

                  if (dx < 0) dx = 0;
                  if (dx > MediaQuery.of(context).size.width - 56) { // 56 es el tamaño del FAB
                      dx = MediaQuery.of(context).size.width - 56;
                  }

                  if (dy < 0) dy = 0;
                  if (dy > MediaQuery.of(context).size.height - kToolbarHeight - 200) { // Ajusta para la altura del AppBar y del SpeedDial desplegado
                      dy = MediaQuery.of(context).size.height - kToolbarHeight - 200;
                  }

                  position = Offset(dx, dy);
                });
              },
              child: _bottonSaveSpeedDial(),
            )
          )
        ],
      ),
      // floatingActionButton: _bottonSaveSpeedDial(),
    );
  }

  SpeedDial _bottonSaveSpeedDial(){
    ValueNotifier<bool> isDialOpen = ValueNotifier(false);

    return SpeedDial(
      openCloseDial: isDialOpen,
      direction: SpeedDialDirection.up,
      icon: Icons.menu_open,
      activeIcon: Icons.close,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.red,
      activeForegroundColor: Colors.white,
      buttonSize: const Size(60.0, 60.0),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add, size: 20),
          backgroundColor: const Color.fromARGB(255, 10, 212, 27),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar Linea',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialogLinea()
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, size: 20),
          backgroundColor: const Color.fromARGB(255, 193, 239, 10),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar Estación',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialogEstacion()
        ),
      ],
    );
  }

  void _showCreateDialogLinea() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar una nueva Linea', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            width: 600,
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FormBuilderTextField(
                    name: 'id',
                    // keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Id de la Linea',
                      labelFrontSize: 30.5,
                      hintext: 'ID Linea (ej. LM1 o LM001)',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el ID de la Linea';
                      }

                      if (!RegExp(r'^(LM|LT)\d{1,3}$').hasMatch(value)){
                        return 'Por favor ingrese un ID-Empleado valido';
                      }

                      return null;
                    },
                  ),

                  FormBuilderDropdown<String>(
                    name: 'tipo',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Tipo de Linea',
                      labelFrontSize: 30.0,
                      icono: const Icon(Icons.list_rounded, size: 30.0)
                    ),
                    initialValue: 'Linea Metro',
                    items: const [
                      DropdownMenuItem(value: 'Linea Metro', child: Text('Linea Metro', style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1)))),
                      DropdownMenuItem(value: 'Linea Teleferico', child: Text('Linea Teleferico', style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1)))),
                    ],
                    style: const TextStyle(fontSize: 30.0),
                    onChanged: (value) {
                      setState(() {
                        _selectedLinea = value!;
                      });
                    },
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'nombre',
                    // keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Nombre de Linea',
                      labelFrontSize: 30.5,
                      hintext: 'Linea 1',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),
                ]
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataLinea = _formKey.currentState!.value;
                  final newIdLinea = dataLinea['id'];

                  // Verificar si el idLinea ya existe
                  if (_lineas.any((existingLine) => existingLine.idLinea == newIdLinea)) {
                    // Mostrar cuadro de diálogo si el ID ya existe
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('ID de Línea ya existente', style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold)),
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
                            child: const Text('El ID de la línea ingresado ya está en uso. Por favor ingrese otro.', style: TextStyle(fontSize: 28.0))
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                              },
                              child: const Text('Aceptar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );
                    return; // Salir del método para evitar continuar la creación
                  }

                  // Si el idLinea no existe, continuar con la creación
                  Linea newLinea = Linea(
                    idLinea: newIdLinea, 
                    tipo: _selectedLinea, 
                    nombreLinea: dataLinea['nombre']
                  );

                  try{
                    final response = await ApiServiceLineas('https://10.0.2.2:7190').postLinea(newLinea);

                    if(response.statusCode == 201) {
                      print('La linea fue creado con éxito');
                      Navigator.of(context).pop();
                      _refreshLinea();
                      _fetchData();
                    } else {
                      print('Error al crear la linea: ${response.body}');
                    }
                  } catch (e) {
                    print('Error al crear la linea: $e');
                  }
                }
              },
              child: const Text('Crear', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _showEditDialogLinea(Linea lineaUpload) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar La Linea', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'tipo': lineaUpload.tipo,
                'nombre': lineaUpload.nombreLinea
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FormBuilderDropdown<String>(
                    name: 'tipo',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Tipo de Linea',
                      labelFrontSize: 30.0,
                      icono: const Icon(Icons.list_rounded, size: 30.0)
                    ),
                    // initialValue: 'Linea Metro',
                    items: const [
                      DropdownMenuItem(value: 'Linea Metro', child: Text('Linea Metro', style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1)))),
                      DropdownMenuItem(value: 'Linea Teleferico', child: Text('Linea Teleferico', style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1)))),
                    ],
                    style: const TextStyle(fontSize: 30.0),
                    onChanged: (value) {
                      setState(() {
                        _selectedLinea = value!;
                      });
                    },
                  ),

                  FormBuilderTextField(
                    name: 'nombre',
                    // keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Nombre de Linea',
                      labelFrontSize: 30.5,
                      hintext: 'Linea 1',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),
                ]
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataLinea = _formKey.currentState!.value;

                  Linea upLoadLinea = Linea(
                    idLinea: lineaUpload.idLinea, 
                    tipo: _selectedLinea, 
                    nombreLinea: dataLinea['nombre']
                  );

                  try{
                    final response = await ApiServiceLineas('https://10.0.2.2:7190').putLinea(lineaUpload.idLinea, upLoadLinea);

                    if(response.statusCode == 204) {
                      print('La linea fue modificada con éxito');
                      Navigator.of(context).pop();
                      _refreshLinea();
                      _fetchData();
                    } else {
                      print('Error al modificar la linea: ${response.body}');
                    }
                  } catch (e) {
                    print('Excepción al modificar la linea: $e');
                  }
                }
              }, 
              child: const Text('Editar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _showDeleteDialogLinea(Linea lineaDelete) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Linea', style: TextStyle(fontSize: 33.0)),
          content: Text('¿Estás seguro de que deseas eliminar la linea no. ${lineaDelete.idLinea} - ${lineaDelete.nombreLinea}?', style: const TextStyle(fontSize: 30)),
          actions: [
            buttonStop(context),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () async {
                try{
                  final response = await ApiServiceLineas('https://10.0.2.2:7190').deleteLineas(lineaDelete.idLinea);

                  if (response.statusCode == 204) {
                    print('Linea eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _refreshLinea();
                    _fetchData();
                  } else {
                    print('Error al eliminar la Linea: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar la Linea: $e');
                }
              },
            )
          ]
        );
      }
    );
  }

  void _showCreateDialogEstacion() {
    if (_lineas.isEmpty) { // se verifica si la lista de la linea del metro esta vacia en caso de ser asi entonces este debe de dar un error
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: const Text('No hay líneas disponibles', style: TextStyle(fontSize: 33.0)),
            content: const Text('Debe agregar una línea primero para poder agregar estaciones.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                },
                child: const Text('Aceptar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      );
    } else { // en caso de no ser asi entonces se procedera a abrir un cuadro de dialogo para agregar las Estacones de acuerdo a la linea existente
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: const Text('Agregar una nueva Linea', style: TextStyle(fontSize: 33.0)),
            contentPadding: EdgeInsets.zero,
            content: Container(
              margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
              width: 600,
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FormBuilderTextField(
                      name: 'No',
                      keyboardType: TextInputType.number,
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Numero de la Estacion',
                        labelFrontSize: 30.5,
                        hintext: '#',
                        hintFrontSize: 30.0,
                        icono: const Icon(Icons.numbers,size: 30.0),
                      ),
                      style: const TextStyle(fontSize: 30.0),
                      validator: FormBuilderValidators.numeric(errorText: 'Este campo es requerido')
                    ),

                    selectorLinea(),

                    labelEstacion(),
                  ],
                )
              ),
            ),
            actions: [
              buttonStop(context),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.saveAndValidate()) {
                    final dataStation = _formKey.currentState!.value;
                    final newIdEstacion = int.parse(dataStation['No']);

                    // Verificamos si la estación ya existe
                    Estacion? existingStation = await ApiServiceEstacion('https://10.0.2.2:7190').getOneEstacion(newIdEstacion);

                    if (existingStation != null) {
                      // La estación ya existe
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('La estación con ID $newIdEstacion ya existe.'))
                      );
                      return; // Salimos del método si la estación existe
                    }

                    // Crear la estación si la línea existe
                    Estacion newStation = Estacion(
                      idEstacion: newIdEstacion, 
                      idLinea: _savedLinea!, 
                      nombreEstacion: dataStation['Estacion']
                    );

                    print('Resultados de newStation: $newStation');

                    try{
                      final response = await ApiServiceEstacion('https://10.0.2.2:7190').postEstacion(newStation);

                      if(response.statusCode == 201) {
                        print('La estacion fue creado con éxito');
                        Navigator.of(context).pop();
                        _refreshEstacion();
                        _fetchData();
                      } else {
                        print('Error al crear la estacion: ${response.body}');
                      }
                    } catch (e) {
                      print('Error al crear la estacion: $e');
                    }
                  }
                },
                

                child: const Text('Crear', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
              )
            ],
          );
        }
      );
    }
  }

  //Widget controladores de interacion--------------------------------------------------------------------------
  FormBuilderTextField labelEstacion() {
    return FormBuilderTextField(
                  name: 'Estacion',
                  // keyboardType: TextInputType.number,
                  decoration: InputDecorations.inputDecoration(
                    labeltext: 'Nombre de Estacion',
                    labelFrontSize: 30.5,
                    hintext: 'Parada del Metro',
                    hintFrontSize: 30.0,
                    icono: const Icon(Icons.numbers,size: 30.0),
                  ),
                  style: const TextStyle(fontSize: 30.0),
                  // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                );
  }

  FormBuilderDropdown<String> selectorLinea() {
    return FormBuilderDropdown<String>(
                  name: 'idLinea',
                  decoration: InputDecorations.inputDecoration(
                    labeltext: 'Elige Linea de metro',
                    labelFrontSize: 30.0,
                    icono: const Icon(Icons.list_rounded, size: 30.0)
                  ),
                  // initialValue: _savedLinea,
                  items: _lineas.map((linea) {
                    return DropdownMenuItem(
                      value: linea.idLinea,
                      child: Text(linea.nombreLinea, style: const TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1))),
                    );
                  }).toList(),
                  style: const TextStyle(fontSize: 30.0),
                  onChanged: (value) {
                    setState(() {
                      _savedLinea = value!;
                      print('Línea seleccionada: $_savedLinea'); // Depuración
                    });
                  },
                );
  }
  //-----------------------------------------------------------------------------------------------------------------------------

  void _showEditDialogEstacion(Estacion estacionUpload) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar La Estacion', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            width: 600,
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'idLinea': estacionUpload.idLinea,
                'Estacion': estacionUpload.nombreEstacion
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  selectorLinea(),
                  labelEstacion(),
                ],
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataStation = _formKey.currentState!.value;

                  Estacion stationUpload = Estacion(
                    idEstacion: estacionUpload.idEstacion, 
                    idLinea: estacionUpload.idLinea, 
                    nombreEstacion: dataStation['Estacion']
                  );

                  try{
                    final response = await ApiServiceEstacion('https://10.0.2.2:7190').putEstacion(estacionUpload.idEstacion, stationUpload);

                    if(response.statusCode == 204) {
                      print('La Estacion fue modificada con éxito');
                      Navigator.of(context).pop();
                      _refreshEstacion();
                      _fetchData();
                    } else {
                      print('Error al modificar la Estacion: ${response.body}');
                    }
                  } catch (e) {
                    print('Excepción al modificar la Estacion: $e');
                  }
                }
              }, 
              child: const Text('Editar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
            )
          ]
        );
      }
    );
  }

  void _showDeleteDialogEstacion(Estacion estacionDelete) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Estacion', style: TextStyle(fontSize: 33.0)),
          content: Text('¿Estás seguro de que deseas eliminar la sesion no. ${estacionDelete.idEstacion} - ${estacionDelete.nombreEstacion}?', style: const TextStyle(fontSize: 30)),
          actions: [
            buttonStop(context),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () async {
                try{
                  final response = await ApiServiceEstacion('https://10.0.2.2:7190').deleteEstacion(estacionDelete.idEstacion);

                  if (response.statusCode == 204) {
                    print('Estacion eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _refreshEstacion();
                    _fetchData();
                  } else {
                    print('Error al eliminar la Estacion: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar la Estacion: $e');
                }
              }
            )
          ]
        );
      }
    );
  }

  TextButton buttonStop(BuildContext context) {
    return TextButton(
            child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
            },
          );
  }
}

/*onPressed: () async {
    if (_formKey.currentState!.saveAndValidate()) {
      final dataStation = _formKey.currentState!.value;
      final newIdEstacion = int.parse(dataStation['No']);
      final newNombreEstacion = dataStation['Estacion'];

      // Verificar si la línea seleccionada existe
      if (_savedLinea == null) {
        // Mostrar cuadro de diálogo si no hay una línea seleccionada
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Línea no seleccionada'),
              content: const Text('Debe seleccionar una línea antes de agregar una estación.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Verificar si el idEstacion ya existe
      try {
        final existsResponse = await ApiServiceEstacion('https://10.0.2.2:7190').getOneEstacion(newIdEstacion);

        if (existsResponse.statusCode == 200) {
          var responseBody = jsonDecode(existsResponse.body);
          if (responseBody['exists'] == true) {
            // Mostrar cuadro de diálogo si el ID ya existe
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('ID de Estación ya existente'),
                  content: const Text('El ID de la estación ingresado ya está en uso.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                );
              },
            );
            return;
          }
        }

        // Crear la estación si no existe
        Estacion newStation = Estacion(
          idEstacion: newIdEstacion,
          idLinea: _savedLinea!,
          nombreEstacion: newNombreEstacion,
        );

        final response = await ApiServiceEstacion('https://10.0.2.2:7190').postEstacion(newStation);

        if (response.statusCode == 201) {
          print('La estación fue creada con éxito');
          Navigator.of(context).pop();
          _refreshEstacion();
          _fetchData();
        } else {
          print('Error al crear la estación: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
    },*/

// // Verificar si la línea seleccionada existe
// if (!_lineas.any((linea) => linea.idLinea == _savedLinea)) {
//   // Mostrar cuadro de diálogo si la línea no existe
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Línea no existente', style: TextStyle(fontSize: 33.0)),
//         content: const Text('La línea seleccionada no existe. Debe agregarla primero.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
//             },
//             child: const Text('Aceptar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//           )
//         ],
//       );
//     },
//   );
//   return; // Salir para evitar que se ejecute el código siguiente
// }

// // Verificar si el idEstacion ya existe
// if (_estaciones.any((estacion) => estacion.idEstacion == newIdEstacion)) {
//   // Mostrar cuadro de diálogo si el ID ya existe
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('ID de Estación ya existente', style: TextStyle(fontSize: 33.0)),
//         content: const Text('El ID de la estación ingresado ya está en uso. Por favor ingrese otro.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
//             },
//             child: const Text('Aceptar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       );
//     },
//   );
//   return; // Salir del método para evitar continuar la creación
// }
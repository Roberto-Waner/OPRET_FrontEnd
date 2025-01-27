import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  // final TextEditingController filtrarCedula;

  const ModifyTable({
    super.key,
    required this.filtrarId,
    // required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<ModifyTable> createState() => _ModifyTableState();
}

class _ModifyTableState extends State<ModifyTable> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiServiceLineas _apiServiceLineas = ApiServiceLineas('http://wepapi.somee.com');
  late Future<List<Linea>> _lineaData;
  final ApiServiceEstacion _apiServiceEstacion = ApiServiceEstacion('http://wepapi.somee.com');
  late Future<List<Estacion>> _estacionData;
  String _selectedLinea = 'Linea Metro';
  String? _savedLinea;
  Offset position = const Offset(500, 800); // Posición inicial del botón
  //---------------------------------------------------------Filtrar-Linea--------------------------------------------------------
  final TextEditingController searchLineaController = TextEditingController();
  List<Linea> _lineaFiltrada = [];
  List<Linea> _todosCampLinea = [];
  String selectedFilterLinea = 'Id Linea metro';
  //-----------------------------------------------------------Filtrar-Estacion-------------------------------------------------------
  final TextEditingController searchEstacionController = TextEditingController();
  List<Estacion> _estacionFiltrada = [];
  List<Estacion> _todosCampEstacion = [];
  String selectedFilterEstacion = 'No de Estacion';
  //---------------------------------------------------------------------------------------------------------------------------------

  List<Linea> _lineas = [];
  // List<Estacion> _estaciones = [];

  @override
  void initState() {
    super.initState();
    _lineaData = Future.value([]);
    _lineaData = _apiServiceLineas.getLinea();

    _estacionData = Future.value([]);
    _estacionData = _apiServiceEstacion.getEstacion();
    _fetchData();
  }

  void _refreshLinea() {
    setState(() {
      _lineaData = _apiServiceLineas.getLinea();
    });
  }

  void _refreshEstacion() {
    setState(() {
      _estacionData = _apiServiceEstacion.getEstacion();
    });
  }

  Future<void> _fetchData() async {
    try{
      List<Linea> lineas = await _apiServiceLineas.getLinea();

      final line = await _apiServiceLineas.getLinea();
      final station = await _apiServiceEstacion.getEstacion();

      setState(() {
        _lineaFiltrada = line;
        _todosCampLinea = line;
        _lineaData = Future.value(line);
        //---------------------------------------
        _estacionFiltrada = station;
        _todosCampEstacion = station;
        _estacionData = Future.value(station);

        _lineas = lineas;
        print('Lineas obtenidas: $_lineas');
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _filtrarLinea (String query) async {
    final queryLower = query.toLowerCase();
    final filtrar = _todosCampLinea.where((ln) {
      switch (selectedFilterLinea) {
        case 'Id Linea metro':
          return ln.idLinea.toLowerCase().contains(queryLower);
        case 'Tipo de Linea':
          return ln.tipo.toLowerCase().contains(queryLower);
        case 'Nombre de la Linea':
          return ln.nombreLinea.toLowerCase().contains(queryLower);
        default:
          return false;
      }
    }).toList();

    setState(() {
      _lineaFiltrada = filtrar;
    });
  }

  void _filtrarEstacion (String query) async {
    final queryLower = query.toLowerCase();
    final filtrar = _todosCampEstacion.where((et) {
      switch (selectedFilterEstacion) {
        case 'No de Estacion':
          return et.idEstacion.toString().toLowerCase().contains(queryLower);
        case 'Id Linea del metro':
          return et.idLinea.toLowerCase().contains(queryLower);
        case 'Nombre de Estacion':
          return et.nombreEstacion.toLowerCase().contains(queryLower);
        default:
          return false;
      }
    }).toList();

    setState(() {
      _estacionFiltrada = filtrar;
    });
  }

  void _limpiarBusqueda() {
    searchLineaController.clear();
    searchEstacionController.clear();
    setState(() {
      _lineaFiltrada = _todosCampLinea;
      _estacionFiltrada = _todosCampEstacion;
    });
  }

  //En caso de ser un table
  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletWidth = size.width > 600;
    final isTabletHeight = size.height > 800;
    return isTabletWidth && isTabletHeight;
  }

  @override
  Widget build(BuildContext context) {
    final isTabletDevice = isTablet(context);

    return ScreenUtilInit(
      designSize: const Size(360, 740),
      builder: (context, child) => Scaffold(
        drawer: Navbar(
          filtrarUsuarioController: widget.filtrarUsuarioController,
          filtrarEmailController: widget.filtrarEmailController,
          filtrarId: widget.filtrarId,
          // // filtrarCedula: widget.filtrarCedula,
        ),
      
        appBar: AppBar(
          title: const Text('Modificar tabla'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 30.0),
              tooltip: 'Recargar',
              onPressed: () {
                setState(() {
                  _refreshLinea();
                  _refreshEstacion();
                });
              },
            )
          ],
        ),
      
        body: Stack(
          children: [
            // Cuerpo principal con las tablas
            SingleChildScrollView(
              child: Column(
                children: [
                  // Sección de filtros y tabla de Líneas de Metro
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        const Text(
                          'Tablas de Lineas de Metro',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                    
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderDropdown<String>(
                                name: 'filtrarLineas',
                                initialValue: selectedFilterLinea,
                                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)),
                                decoration: const InputDecoration(
                                  labelText: 'Filtrar por',
                                  labelStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  'Id Linea metro',
                                  'Tipo de Linea',
                                  'Nombre de la Linea',
                                ].map((filter) => DropdownMenuItem(
                                      value: filter,
                                      child: Text(filter),
                                    )).toList(),
                                onChanged: (value) => setState(() {
                                  selectedFilterLinea = value!;
                                }),
                              ),
                            ),
                            const SizedBox(width: 16),
                  
                            Expanded(
                              flex: 2,
                              child: FormBuilderTextField(
                                name: 'searchLinea',
                                controller: searchLineaController,
                                style: const TextStyle(fontSize: 20.0),
                                decoration: InputDecoration( 
                                  labelText: 'Buscar', 
                                  labelStyle: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: searchLineaController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: _limpiarBusqueda,
                                      )
                                    : null 
                                ),
                                onChanged: (value) {
                                  if (value!.isNotEmpty) {
                                    _filtrarLinea(value);
                                  } else {
                                    setState(() { 
                                      _lineaFiltrada = []; 
                                    }); 
                                  }
                                },
                              )
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        FutureBuilder<List<Linea>>(
                          future: _lineaData, 
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }else if(snapshot.hasError) {
                              print('Error al cargar la Línea de metro: ${snapshot.error}');
                              return Center(child: Text('"Lo sentimos, no pudimos cargar la información en este momento. \nPor favo, inténtalo nuevamente presionando el (botón Refrescar)"', style: TextStyle(fontSize: isTabletDevice ? 11.sp : 9.sp, fontWeight: FontWeight.bold)));
                            } else {
                              final lineTable = _lineaFiltrada.isNotEmpty 
                                  ? _lineaFiltrada
                                  : snapshot.data ?? [];
                              
                              return Container(
                                margin: const EdgeInsets.all(2.0),
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color.fromARGB(255, 74, 71, 71)),
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 9, 9, 9).withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    textTheme: Theme.of(context).textTheme.copyWith(
                                      bodySmall: TextStyle(
                                        fontSize: isTabletDevice ? 9.sp : 9.sp,           // Ajusta el tamaño del número
                                        color: Colors.black,    // Cambia el color del texto (ajústalo según tu preferencia)
                                        fontWeight: FontWeight.bold, // Hace el texto más visible
                                      ),
                                    ),
                                  ),
                                  child: PaginatedDataTable(
                                    headingRowColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 2, 37, 4)), // Fondo de encabezado
                                    columns: [
                                      DataColumn(label: Text('Id Línea metro', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Tipo de Línea', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Nombre de \nla Línea', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Acción', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold)))
                                    ],
                                    source: _LineaDataSource(lineTable, _showEditDialogLinea, _showDeleteDialogLinea),
                                    rowsPerPage: 5, //numeros de filas
                                    columnSpacing: 50, //espacios entre columnas
                                    horizontalMargin: 50, //para aplicarle un margin horizontal a los campo de la tabla
                                    showCheckboxColumn: false, //oculta la columna de checkboxes
                                    dataRowMinHeight: 60.0,  // Altura mínima de fila
                                    dataRowMaxHeight: 80.0,  // Altura máxima de fila
                                    showFirstLastButtons: true,
                                    headingRowHeight: 100.0, // Ajusta la altura del encabezado
                                  ),
                                ),
                              );
                            }
                          }
                        ),
                        // const SizedBox(height: 20),
                        const Divider(),
                              
                        const SizedBox(height: 20),
                        const Text(
                          'Tablas de Estaciones del Metro',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
      
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderDropdown<String>(
                                name: 'filtrarEstaciones',
                                initialValue: selectedFilterEstacion,
                                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)),
                                decoration: const InputDecoration(
                                  labelText: 'Filtrar por',
                                  labelStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  'No de Estacion',
                                  'Id Linea del metro',
                                  'Nombre de Estacion',
                                ].map((filter) => DropdownMenuItem(
                                      value: filter,
                                      child: Text(filter),
                                    )).toList(),
                                onChanged: (value) => setState(() {
                                  selectedFilterEstacion = value!;
                                }),
                              ),
                            ),
                            const SizedBox(width: 16),
      
                            Expanded(
                              flex: 2,
                              child: FormBuilderTextField(
                                name: 'searchEstacion',
                                controller: searchEstacionController,
                                style: const TextStyle(fontSize: 20.0),
                                decoration: InputDecoration( 
                                  labelText: 'Buscar', 
                                  labelStyle: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: searchEstacionController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: _limpiarBusqueda,
                                      )
                                    : null 
                                ),
                                onChanged: (value) {
                                  if (value!.isNotEmpty) {
                                    _filtrarEstacion(value);
                                  } else {
                                    setState(() { 
                                      _estacionFiltrada = []; 
                                    }); 
                                  }
                                },
                              )
                            )                          
                          ]
                        ),
                        const SizedBox(width: 16),
                        const Divider(),
                              
                        FutureBuilder<List<Estacion>>(
                          future: _estacionData, 
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }else if (snapshot.hasError) {
                              print('Error al cargar la tabla de Estaciones del metro.: ${snapshot.error}');
                              return Center(child: Text('"Lo sentimos, no pudimos cargar la información en este momento. \nPor favo, inténtalo nuevamente presionando el (botón Refrescar)"', style: TextStyle(fontSize: isTabletDevice ? 11.sp : 9.sp, fontWeight: FontWeight.bold)));
                            } else {
                              final station = _estacionFiltrada.isNotEmpty 
                                    ? _estacionFiltrada
                                    : snapshot.data ?? [];
                              
                              return Container(
                                margin: const EdgeInsets.all(2.0),
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color.fromARGB(255, 74, 71, 71)),
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 9, 9, 9).withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    textTheme: Theme.of(context).textTheme.copyWith(
                                      bodySmall: TextStyle(
                                        fontSize: isTabletDevice ? 9.sp : 9.sp,           // Ajusta el tamaño del número
                                        color: Colors.black,    // Cambia el color del texto (ajústalo según tu preferencia)
                                        fontWeight: FontWeight.bold, // Hace el texto más visible
                                      ),
                                    ),
                                  ),
                                  child: PaginatedDataTable(
                                    headingRowColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 2, 37, 4)), // Fondo de encabezado
                                    columns: [
                                      DataColumn(label: Text('NO', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Id Línea de metro \na la que pertenece', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Estación', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Acción', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp, color: Colors.white, fontWeight: FontWeight.bold)))
                                    ],
                                    source: _EstacionDataSource(station, _showEditDialogEstacion, _showDeleteDialogEstacion),
                                    rowsPerPage: 5, //numeros de filas
                                    columnSpacing: 50, //espacios entre columnas
                                    horizontalMargin: 50, //para aplicarle un margin horizontal a los campo de la tabla
                                    showCheckboxColumn: false, //oculta la columna de checkboxes
                                    dataRowMinHeight: 60.0,  // Altura mínima de fila
                                    dataRowMaxHeight: 80.0,  // Altura máxima de fila
                                    showFirstLastButtons: true,
                                    headingRowHeight: 100.0, // Ajusta la altura del encabezado
                                  ),
                                ),
                              );
                            }
                          }
                        ),
                      ],
                    ),
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
      ),
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
          label: 'Agregar Línea',
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
    final isTabletDevice = isTablet(context);

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar una nueva Línea', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: isTabletDevice ? const EdgeInsets.fromLTRB(90, 20, 90, 50) : const EdgeInsets.fromLTRB(30, 20, 30, 50),
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
                      labeltext: 'Id de la Línea',
                      labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                      hintext: 'ID Linea (ej. LM1 o LM001)',
                      hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                      icono: Icon(Icons.verified, size: isTabletDevice ? 15.sp : 15.sp),
                      errorSize: isTabletDevice ? 10.sp : 10.sp,
                    ),
                    style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el ID de la Linea';
                      }

                      if (!RegExp(r'^(LM|LT)\d{1,3}$').hasMatch(value)){
                        return 'Por favor ingrese un ID-Linea valido y en mayuscula';
                      }

                      return null;
                    },
                  ),

                  FormBuilderDropdown<String>(
                    name: 'tipo',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Tipo de Línea',
                      labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                      icono: Icon(Icons.list_rounded, size: isTabletDevice ? 15.sp : 15.sp),
                      hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                    ),
                    initialValue: 'Linea Metro',
                    items: const [
                      DropdownMenuItem(value: 'Linea Metro', child: Text('Linea Metro')),
                      DropdownMenuItem(value: 'Linea Teleferico', child: Text('Linea Teleferico')),
                    ],
                    style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                    onChanged: (value) {
                      setState(() {
                        _selectedLinea = value!;
                      });
                    },
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'nombre',
                    keyboardType: TextInputType.name,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Nombre de Línea',
                      labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                      hintext: 'Ej: Linea 1, 2 ...',
                      hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                      icono: Icon(Icons.text_fields, size: isTabletDevice ? 15.sp : 15.sp),
                      errorSize: isTabletDevice ? 10.sp : 10.sp,
                    ),
                    style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
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
                          title: Text('ID de Línea ya existente', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold)),
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            margin: isTabletDevice ? const EdgeInsets.fromLTRB(90, 20, 90, 50) : const EdgeInsets.fromLTRB(30, 20, 30, 50),
                            child: Text('El ID: $newIdLinea de la línea ingresado ya está en uso. Por favor ingrese otro.', style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)))
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                              },
                              child: Text('Aceptar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 18.2.sp, fontWeight: FontWeight.bold)),
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
                    final response = await ApiServiceLineas('http://wepapi.somee.com').postLinea(newLinea);

                    if(response.statusCode == 201) {
                      print('La linea fue creado con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'Línea del metro fue creado con éxito');
                      _refreshLinea();
                      _fetchData();
                    } else {
                      print('Error al crear la linea: ${response.body}');
                      _showErrorDialog(context, 'Error al crear la Línea');
                    }
                  } catch (e) {
                    print('Error al crear la linea: $e');
                  }
                }
              },
              child: Text('Crear', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 18.2.sp, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _showEditDialogLinea(Linea lineaUpload) {
    final isTabletDevice = isTablet(context);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar La Línea', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: isTabletDevice ? const EdgeInsets.fromLTRB(90, 20, 90, 50) : const EdgeInsets.fromLTRB(30, 20, 30, 50),
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
                      labeltext: 'Tipo de Línea',
                      labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                      icono: Icon(Icons.list_rounded, size: isTabletDevice ? 15.sp : 15.sp)
                    ),
                    // initialValue: 'Linea Metro',
                    items: const [
                      DropdownMenuItem(value: 'Linea Metro', child: Text('Linea Metro')),
                      DropdownMenuItem(value: 'Linea Teleferico', child: Text('Linea Teleferico')),
                    ],
                    style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                    onChanged: (value) {
                      setState(() {
                        _selectedLinea = value!;
                      });
                    },
                  ),

                  FormBuilderTextField(
                    name: 'nombre',
                    keyboardType: TextInputType.name,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Nombre de Línea',
                      labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                      hintext: 'Línea 1',
                      hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                      icono: Icon(Icons.text_fields, size: isTabletDevice ? 15.sp : 15.sp),
                    ),
                    style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
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
                    final response = await ApiServiceLineas('http://wepapi.somee.com').putLinea(lineaUpload.idLinea, upLoadLinea);

                    if(response.statusCode == 204) {
                      print('La linea fue modificada con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'Línea del metro fue modificada con éxito');
                      _refreshLinea();
                      _fetchData();
                    } else {
                      print('Error al modificar la Línea: ${response.body}');
                      _showErrorDialog(context, 'Error al modificar la linea');
                    }
                  } catch (e) {
                    print('Excepción al modificar la linea: $e');
                  }
                }
              }, 
              child: Text('Editar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _showDeleteDialogLinea(Linea lineaDelete) {
    final isTabletDevice = isTablet(context);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Línea', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
          content: Text('¿Estás seguro de que deseas eliminar la Línea: ${lineaDelete.idLinea} - ${lineaDelete.nombreLinea}?', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
          actions: [
            buttonStop(context),
            TextButton(
              child: Text('Eliminar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold)),
              onPressed: () async {
                try{
                  final response = await ApiServiceLineas('http://wepapi.somee.com').deleteLineas(lineaDelete.idLinea);

                  if (response.statusCode == 204) {
                    print('Linea eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _showSuccessDialog(context, 'Línea del metro fue eliminado con éxito');
                    _refreshLinea();
                    _fetchData();
                  } else if (response.statusCode == 400) {
                    final responseBody = jsonDecode(response.body);
                    _showErrorDialog(context, responseBody['message']);
                  } else {
                    print('Error al eliminar la Linea: ${response.body}');
                    _showErrorDialog(context, 'Error al eliminar la Línea: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar la Linea: $e');
                  _showErrorDialog(context, 'Error al eliminar la Línea: $e');
                }
              },
            )
          ]
        );
      }
    );
  }

  void _showCreateDialogEstacion() {
    final isTabletDevice = isTablet(context);
    if (_lineas.isEmpty) { // se verifica si la lista de la linea del metro esta vacia en caso de ser asi entonces este debe de dar un error
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: Text('No hay líneas disponibles', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
            content: const Text('Debe agregar una línea primero para poder agregar estaciones.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                },
                child: Text('Aceptar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold)),
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
            title: Text('Agregar una nueva Estación', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
            contentPadding: EdgeInsets.zero,
            content: Container(
              margin: isTabletDevice ? const EdgeInsets.fromLTRB(90, 20, 90, 50) : const EdgeInsets.fromLTRB(30, 20, 30, 50),
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
                        labeltext: 'Numero de la Estación',
                        labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                        hintext: '#',
                        hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                        icono: Icon(Icons.numbers, size: isTabletDevice ? 15.sp : 15.sp),
                        errorSize: isTabletDevice ? 10.sp : 10.sp,
                      ),
                      style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
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
                    Estacion? existingStation = await ApiServiceEstacion('http://wepapi.somee.com').getOneEstacion(newIdEstacion);

                    if (existingStation != null) {

                      showDialog(
                        context: context, 
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'La estación con el no. $newIdEstacion ya existe.', 
                              style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold)
                            ),
                            contentPadding: EdgeInsets.zero,
                            content: Container(
                              margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
                              child: Text('El no. $newIdEstacion, ya existe asi que no lo puedes usar para identificar esta estacion. Por favor ingrese otro.', style: const TextStyle(fontSize: 28.0)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                                },
                                child: Text('Aceptar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          );
                        }
                      );
                    }

                    // Crear la estación si la línea existe
                    Estacion newStation = Estacion(
                      idEstacion: newIdEstacion, 
                      idLinea: _savedLinea!, 
                      nombreEstacion: dataStation['Estacion']
                    );

                    print('Resultados de newStation: $newStation');

                    try{
                      final response = await ApiServiceEstacion('http://wepapi.somee.com').postEstacion(newStation);

                      if(response.statusCode == 201) {
                        print('La estacion fue creado con éxito');
                        Navigator.of(context).pop();
                        _showSuccessDialog(context, 'La Estación fue creado con éxito');
                        _refreshEstacion();
                        _fetchData();
                      } else {
                        print('Error al crear la estacion: ${response.body}');
                        _showErrorDialog(context, 'Error al crear la Estación');
                      }
                    } catch (e) {
                      print('Error al crear la estacion: $e');
                    }
                  }
                },
                
                child: Text('Crear', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold))
              )
            ],
          );
        }
      );
    }
  }

  //Widget controladores de interacion--------------------------------------------------------------------------
  FormBuilderTextField labelEstacion() {
    final isTabletDevice = isTablet(context);
    return FormBuilderTextField(
                  name: 'Estacion',
                  // keyboardType: TextInputType.number,
                  decoration: InputDecorations.inputDecoration(
                    labeltext: 'Nombre de Estación',
                    labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                    hintext: 'Ingrese la nueva Estación',
                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                    icono: Icon(Icons.text_fields, size: isTabletDevice ? 15.sp : 15.sp),
                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                  ),
                  style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                );
  }

  FormBuilderDropdown<String> selectorLinea() {
    final isTabletDevice = isTablet(context);
    return FormBuilderDropdown<String>(
                  name: 'idLinea',
                  menuMaxHeight: 200.0,
                  decoration: InputDecorations.inputDecoration(
                    labeltext: 'Elige Linea de metro',
                    labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                    icono: Icon(Icons.list_rounded, size: isTabletDevice ? 15.sp : 15.sp),
                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                  ),
                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                  // initialValue: _savedLinea,
                  items: _lineas.map((linea) {
                    return DropdownMenuItem(
                      value: linea.idLinea,
                      child: Text(linea.nombreLinea),
                    );
                  }).toList(),
                  style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
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
    final isTabletDevice = isTablet(context);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar La Estación', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: isTabletDevice ? const EdgeInsets.fromLTRB(90, 20, 90, 50) : const EdgeInsets.fromLTRB(30, 20, 30, 50),
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
                    final response = await ApiServiceEstacion('http://wepapi.somee.com').putEstacion(estacionUpload.idEstacion, stationUpload);

                    if(response.statusCode == 204) {
                      print('La Estación fue modificada con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'La Estación fue modificada con éxito');
                      _refreshEstacion();
                      _fetchData();
                    } else {
                      print('Error al modificar la Estacion: ${response.body}');
                      _showErrorDialog(context, 'Error al modificar la Estación');
                    }
                  } catch (e) {
                    print('Excepción al modificar la Estacion: $e');
                  }
                }
              }, 
              child: Text('Editar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold))
            )
          ]
        );
      }
    );
  }

  void _showDeleteDialogEstacion(Estacion estacionDelete) {
    final isTabletDevice = isTablet(context);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Estación', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, )),
          content: Text('¿Estás seguro de que deseas eliminar la Estación no. ${estacionDelete.idEstacion} - ${estacionDelete.nombreEstacion}?', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp)),
          actions: [
            buttonStop(context),
            TextButton(
              child: Text('Eliminar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold)),
              onPressed: () async {
                try{
                  final response = await ApiServiceEstacion('http://wepapi.somee.com').deleteEstacion(estacionDelete.idEstacion);

                  if (response.statusCode == 204) {
                    print('Estación eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _showSuccessDialog(context, 'La Estación fue agregado con éxito');
                    _refreshEstacion();
                    _fetchData();
                  } else {
                    print('Error al eliminar la Estacion: ${response.body}');
                    _showErrorDialog(context, 'Error al eliminar la Estación');
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
    final isTabletDevice = isTablet(context);
    return TextButton(
            child: Text('Cancelar', style: TextStyle(fontSize: isTabletDevice ? 15.sp : 18.2.sp, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
            },
          );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error", style: TextStyle(fontSize: isTabletDevice ? 15.sp : 18.2.sp, fontWeight: FontWeight.bold)),
          contentPadding: EdgeInsets.zero,  // Elimina el padding por defecto
          content: Container(
            margin: const EdgeInsets.fromLTRB(70, 20, 70, 50),  // Aplica margen
            child: Text(message, style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))
          ),
          actions: [ 
            TextButton( 
              child: Text("OK", style: TextStyle(fontSize: isTabletDevice ? 15.sp : 18.2.sp, fontWeight: FontWeight.bold, color: Colors.blue)), 
              onPressed: () { 
                Navigator.of(context).pop(); 
              }, 
            ), 
          ],
        );
      }
    );
  }

  // cuadro de acceso exito
  void _showSuccessDialog(BuildContext context, String message) {
    // final isTabletDevice = isTablet(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3)
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60.0),
                const SizedBox(height: 20),
                const Text( 
                  '¡Éxito!', 
                  style: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold), 
                ),
                const SizedBox(height: 8.0),
                Text( 
                  message, 
                  style: const TextStyle(fontSize: 25.0), 
                  textAlign: TextAlign.center, 
                ), 
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: const Text('OK', style: TextStyle(fontSize: 18.0)),
                )
              ]
            )
          )
        );
      }
    );
  }
}

class _LineaDataSource extends DataTableSource {
  final List<Linea> lineasData;
  final Function(Linea) onEdit;
  final Function(Linea) onDelete;

  _LineaDataSource(this.lineasData, this.onEdit, this.onDelete);

  @override
  DataRow getRow(int index) {
    if (index >= lineasData.length) return const DataRow(cells: []);

    final linasDatos = lineasData[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>((states) {
        // Color alterno para las filas
        return (lineasData.indexOf(linasDatos) % 2 == 0)
              ? Colors.blueGrey.shade50
              : Colors.white;
      }),
      cells: [
        DataCell(Text(linasDatos.idLinea, style: const TextStyle(fontSize: 20.0))), // Conversión explícita de int a String usando .toString()
        DataCell(Text(linasDatos.tipo, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(linasDatos.nombreLinea, style: const TextStyle(fontSize: 20.0))),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // _showEditDialogLinea(linasDatos);
                  onEdit(linasDatos);
                }, 
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              
              IconButton(
                onPressed: () {
                  // _showDeleteDialogLinea(linasDatos);
                  onDelete(linasDatos);
                },
                icon: const Icon(Icons.delete, color: Colors.red)
              )
            ],
          )
        )
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => lineasData.length;

  @override
  int get selectedRowCount => 0;
}

class _EstacionDataSource extends DataTableSource {
  final List<Estacion> estacionData;
  final Function(Estacion) onEdit;
  final Function(Estacion) onDelete;

  _EstacionDataSource(this.estacionData, this.onEdit, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= estacionData.length) return const DataRow(cells: []);

    final estacion = estacionData[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>((states) {
        // Color alterno para las filas
        return (estacionData.indexOf(estacion) % 2 == 0)
              ? Colors.blueGrey.shade50
              : Colors.white;
      }),
      cells: [
        /*
        DataCell(Text(estacion.idEstacion.toString(), style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(estacion.idLinea, style: const TextStyle(fontSize: 20.0))),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 420, minWidth: 420), // Ancho fijo para la celda
            child: Text(estacion.nombreEstacion, style: const TextStyle(fontSize: 20.0), softWrap: true)
          )
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // _showEditDialogEstacion(estacion);
                  onEdit(estacion);
                }, 
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              
              IconButton(
                onPressed: () {
                  // _showDeleteDialogEstacion(estacion);
                  onDelete(estacion);
                },
                icon: const Icon(Icons.delete, color: Colors.red)
              )
            ],
          )
        )
        */
        buildTextCell(estacion.idEstacion.toString()),
        buildTextCell(estacion.idLinea),
        buildTextCell(estacion.nombreEstacion),
        buildActionCell(
          onEdit: onEdit, 
          onDelete: onDelete, 
          estacion: estacion
        )
      ]
    );
  }

  DataCell buildTextCell(String? text) {
    return DataCell(
      text != null
          ? Container(
              constraints: const BoxConstraints(maxWidth: 420, minWidth: 170),
              child: Text(
                text,
                style: const TextStyle(fontSize: 20.0),
                softWrap: true,
              )
            )
          : const Text('')
    );
  }

  DataCell buildActionCell({
    required Function(Estacion) onEdit,
    required Function(Estacion) onDelete,
    required Estacion estacion, // Objeto que será pasado a las funciones
  }) {
    return DataCell(
      Row(
        children: [
          IconButton(
            onPressed: () => onEdit(estacion), // Pasa el objeto `estacion` a la función de edición
            icon: const Icon(Icons.edit, color: Colors.blue),
          ),
          IconButton(
            onPressed: () => onDelete(estacion), // Pasa el objeto `estacion` a la función de eliminación
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ]
      )
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => estacionData.length;

  @override
  int get selectedRowCount => 0;
}
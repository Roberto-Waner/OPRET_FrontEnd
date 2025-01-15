import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/pregunta.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/pregunta_services.dart';
import 'package:formulario_opret/services/sesion_services.dart';
import 'package:formulario_opret/services/subPreguntas_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'package:flutter_switch/flutter_switch.dart';

class PreguntaScreenNavbar extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;

  const PreguntaScreenNavbar({
    super.key,
    required this.filtrarId,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<PreguntaScreenNavbar> createState() => _PreguntaScreenNavbarState();
}

class _PreguntaScreenNavbarState extends State<PreguntaScreenNavbar> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiServicePreguntas _apiServicePreguntas = ApiServicePreguntas('http://wepapi.somee.com');
  late Future<List<Preguntas>> _preguntasData;
  final ApiServiceSubPreguntas  _apiServiceSubPreguntas = ApiServiceSubPreguntas('http://wepapi.somee.com');
  late Future<List<SubPregunta>> _subPreguntasData;
  final ApiServiceSesion _apiServiceSesion = ApiServiceSesion('http://wepapi.somee.com');
  late Future<List<Sesion>> _sesionData;
  String selectedTipRespuestas = 'Respuesta Abierta';
  final tipoRespuestaController = TextEditingController();
  Offset position = const Offset(700, 1150);
  List<Preguntas> _questions = [];
  int? _savedQuestion;
  List<SubPregunta> _subQuestions = [];
  //--------------------------------------------------------Filtrar-Preguntas-----------------------------------------------
  final TextEditingController searchPreguntaController = TextEditingController();
  List<Preguntas> _preguntaFiltrada = [];
  List<Preguntas> _todosCampPreguntas = [];
  String selectedFilterPregunta = 'No de pregunta';
  //-------------------------------------------------------Filtrar-SubPreguntas---------------------------------------------
  final TextEditingController searchSubPreguntaController = TextEditingController();
  List<SubPregunta> _subPreguntaFiltrada = [];
  List<SubPregunta> _todosCampSubPreguntas = [];
  String selectedFilterSubPregunta = 'Id de Sub pregunta';
  //----------------------------------------------------------Filtrar-Sesion------------------------------------------------
  final TextEditingController searchSesionController = TextEditingController();
  List<Sesion> _sesionFiltrada = [];
  List<Sesion> _todosCampSesion = [];
  String selectedFilterSesion = 'Numero de Seccion';
  //------------------------------------------------------------------------------------------------------------------------

  @override
  void initState(){
    super.initState();
    _preguntasData = _apiServicePreguntas.getPreguntas();
    _subPreguntasData = _apiServiceSubPreguntas.getSubPreg();
    _sesionData = _apiServiceSesion.getSesion();
    _fetchData();
    _fetchDataSubPregu();
    _refreshSesion();
    // initializeRango();
    //-------------------------------------------------
    // _preguntasData = Future.value([]);
    // _subPreguntasData = Future.value([]);
    // _sesionData = Future.value([]);
  }

  Future<void> _fetchData() async {
    try{
      List<Preguntas> questions = await _apiServicePreguntas.getPreguntas();
      final preg = await _apiServicePreguntas.getPreguntas();

      setState(() {
        _preguntaFiltrada = preg;
        _todosCampPreguntas = preg;
        _preguntasData = Future.value(preg);
        //-------------------------------------------------

        _questions = questions;
        print('Lineas obtenidas: $_questions');
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _filtrarPreguntas (String query) async {
    final queryLower = query.toLowerCase();
    final filtrar = _todosCampPreguntas.where((pg) {
      switch (selectedFilterPregunta) {
        case 'No de pregunta':
          return pg.codPregunta.toString().toLowerCase().contains(queryLower);
        case 'Pregunta':
          return pg.pregunta.toLowerCase().contains(queryLower);
        default:
          return false;
      }
    }).toList();

    setState(() {
      _preguntaFiltrada = filtrar;
    });
  }

  Future<void> _fetchDataSubPregu() async {
    try{
      List<SubPregunta>  subPreguntas = await _apiServiceSubPreguntas.getSubPreg();
      final subPreg = await _apiServiceSubPreguntas.getSubPreg();

      setState(() {
        _subPreguntaFiltrada = subPreg;
        _todosCampSubPreguntas = subPreg;
        _subPreguntasData = Future.value(subPreg);
        //-------------------------------------------------

        _subQuestions = subPreguntas;
        print('Lineas obtenidas: $_subQuestions');
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _filtrarSubPreguntas (String query) async {
    final queryLower = query.toLowerCase();
    final filtrar = _todosCampSubPreguntas.where((spg) {
      switch (selectedFilterSubPregunta) {
        case 'Id de Sub pregunta':
          return spg.codSubPregunta.toLowerCase().contains(queryLower);
        case 'Sup Pregunta':
          return spg.subPreguntas?.toLowerCase().contains(queryLower) ?? false;
        default:
          return false;
      }
    }).toList();

    setState(() {
      _subPreguntaFiltrada = filtrar;
    });
  }

  Future<void> _refreshSesion() async {
    final se = await _apiServiceSesion.getSesion();

    setState(() {
      _sesionFiltrada = se;
      _todosCampSesion = se;
      _sesionData = Future.value(se);
      //-----------------------------------------

      _sesionData = _apiServiceSesion.getSesion();
    });
  }

  void _filtrarSesion (String query) async {
    final queryLower = query.toLowerCase();
    final filtrar = _todosCampSesion.where((setion) {
      switch (selectedFilterSesion) {
        case 'Numero de Seccion':
          return setion.idSesion?.toString().toLowerCase().contains(queryLower) ?? false;
        case 'Tipo de Respuesta':
          return setion.tipoRespuesta.toLowerCase().contains(queryLower);
        // case 'Tema':
        //   return setion.grupoTema?.toLowerCase().contains(queryLower) ?? false;
        case 'Numero de Pregunta':
          return setion.codPregunta.toString().toLowerCase().contains(queryLower);
        case 'No. de Sup Pregunta':
          return setion.codSubPregunta?.toLowerCase().contains(queryLower) ?? false;
        default:
          return false;
      }
    }).toList();

    setState(() {
      _sesionFiltrada = filtrar;
    });
  }

  void _limpiarBusqueda() {
    searchPreguntaController.clear();
    searchSubPreguntaController.clear();
    searchSesionController.clear();
    setState(() {
      _preguntaFiltrada = _todosCampPreguntas;
      _subPreguntaFiltrada = _todosCampSubPreguntas;
      _sesionFiltrada = _todosCampSesion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( //Widget utilizado para evitar que el usuario pueda retroceder por medio del boton o gesto para ir atras
      canPop: false, // Retorna `false` para evitar que la pantalla retroceda
      child: Scaffold(
        drawer: Navbar(
          filtrarUsuarioController: widget.filtrarUsuarioController,
          filtrarEmailController: widget.filtrarEmailController,
          filtrarId: widget.filtrarId,
          // // filtrarCedula: widget.filtrarCedula,
        ),
        appBar: AppBar(
          title: const Text('Sección de Preguntas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 30.0),
              tooltip: 'Recargar',
              onPressed: () {
                setState(() {
                  _fetchData();
                  _fetchDataSubPregu();
                  _refreshSesion();
                  
                });
              },
            )
          ],
        ),
      
        body: Stack(
          children: [
            // Cuerpo principal con las tablas
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tablas de Preguntas',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
      
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown<String>(
                            name: 'filtrarPregunta',
                            menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                            initialValue: selectedFilterPregunta,
                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)),
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por',
                              labelStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              'No de pregunta',
                              'Pregunta'
                            ].map((filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                )).toList(),
                            onChanged: (value) => setState(() {
                              selectedFilterPregunta = value!;
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
      
                        Expanded(
                          flex: 2,
                          child: FormBuilderTextField(
                            name: 'searchPregunta',
                            controller: searchPreguntaController,
                            style: const TextStyle(fontSize: 20.0),
                            decoration: InputDecoration( 
                              labelText: 'Buscar', 
                              labelStyle: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchPreguntaController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _limpiarBusqueda,
                                  )
                                : null 
                            ),
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                _filtrarPreguntas(value);
                              } else {
                                setState(() { 
                                  _preguntaFiltrada = []; 
                                }); 
                              }
                            },
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                          
                    FutureBuilder<List<Preguntas>>(
                      future: _preguntasData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }else if(snapshot.hasError) {
                          return const Center(child: Text('Error al cargar la Sesion de Preguntas.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                        }else {
                          final questionTable = _preguntaFiltrada.isNotEmpty 
                                ? _preguntaFiltrada
                                : snapshot.data ?? [];
                    
                          return Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(7.0),
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
                                  bodySmall: const TextStyle(
                                    fontSize: 20,           // Ajusta el tamaño del número
                                    color: Colors.black,    // Cambia el color del texto (ajústalo según tu preferencia)
                                    fontWeight: FontWeight.bold, // Hace el texto más visible
                                  ),
                                ),
                              ),
                              child: PaginatedDataTable(
                                columns: const [
                                  DataColumn(label: Text('No', style: TextStyle(fontSize: 27.0, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Preguntas', style: TextStyle(fontSize: 27.0, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Accion', style: TextStyle(fontSize: 27.0, color: Colors.white, fontWeight: FontWeight.bold)))
                                ],
                                source: _PreguntasDataSource(questionTable, _showEditDialog, _showDeleteDialog),
                                headingRowColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 2, 37, 4)), // Fondo de encabezado
                                rowsPerPage: 10, //numeros de filas
                                columnSpacing: 50, //espacios entre columnas
                                horizontalMargin: 50, //para aplicarle un margin horizontal a los campo de la tabla
                                showCheckboxColumn: false, //oculta la columna de checkboxes
                                dataRowMinHeight: 60.0,  // Altura mínima de fila
                                dataRowMaxHeight: 80.0,  // Altura máxima de fila
                                showFirstLastButtons: true,
                              ),
                            ),
                          );
                        }
                      }
                    ),
                    const Divider(),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Tablas de Sub Preguntas',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
      
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown<String>(
                            name: 'filtrarSubPregunta',
                            menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                            initialValue: selectedFilterSubPregunta,
                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)),
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por',
                              labelStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              'Id de Sub pregunta',
                              'Sup Pregunta',
                            ].map((filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                )).toList(),
                            onChanged: (value) => setState(() {
                              selectedFilterSubPregunta = value!;
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
      
                        Expanded(
                          flex: 2,
                          child: FormBuilderTextField(
                            name: 'searchSubPregunta',
                            controller: searchSubPreguntaController,
                            style: const TextStyle(fontSize: 20.0),
                            decoration: InputDecoration( 
                              labelText: 'Buscar', 
                              labelStyle: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchSubPreguntaController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _limpiarBusqueda,
                                  )
                                : null 
                            ),
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                _filtrarSubPreguntas(value);
                              } else {
                                setState(() { 
                                  _subPreguntaFiltrada = []; 
                                }); 
                              }
                            },
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                          
                    FutureBuilder<List<SubPregunta>>(
                      future: _subPreguntasData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }else if (snapshot.hasError) {
                          return const Center(child: Text('Error al cargar la Sub - Preguntas.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                        } else {
                          final subPregTabla = _subPreguntaFiltrada.isNotEmpty 
                                ? _subPreguntaFiltrada
                                : snapshot.data ?? [];
                          
                          return Container(
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(7.0),
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
                                  bodySmall: const TextStyle(
                                    fontSize: 20,           // Ajusta el tamaño del número
                                    color: Colors.black,    // Cambia el color del texto (ajústalo según tu preferencia)
                                    fontWeight: FontWeight.bold, // Hace el texto más visible
                                  ),
                                ),
                              ),
                              child: PaginatedDataTable(
                                columns: const [
                                  DataColumn(label: Text('NO', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Sub Preguntas', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Acción', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold)))
                                ], 
                                source: _SubPreguntasDataSource(subPregTabla, _showEditDialogSubPregunta, _showDeleteDialogSubPregunta),
                                headingRowColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 2, 37, 4)), // Fondo de encabezado
                                rowsPerPage: 7, //numeros de filas
                                columnSpacing: 50, //espacios entre columnas
                                horizontalMargin: 30, //para aplicarle un margin horizontal a los campo de la tabla
                                showCheckboxColumn: false, //oculta la columna de checkboxes
                                dataRowMinHeight: 60.0,  // Altura mínima de fila
                                dataRowMaxHeight: 80.0,  // Altura máxima de fila
                                showFirstLastButtons: true,
                              ),
                            ),
                          );
                        }
                      }
                    ),
                    const Divider(),
                          
                    const SizedBox(height: 20),
                    const Text(
                      'Tablas administrativa para gestionar las preguntas',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
      
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown<String>(
                            name: 'filtrarSesion',
                            menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                            initialValue: selectedFilterSesion,
                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)),
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por',
                              labelStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              'Numero de Seccion',
                              'Tipo de Respuesta',
                              'Numero de Pregunta',
                              'No. de Sup Pregunta'
                            ].map((filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                )).toList(),
                            onChanged: (value) => setState(() {
                              selectedFilterSesion = value!;
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
      
                        Expanded(
                          flex: 2,
                          child: FormBuilderTextField(
                            name: 'searchSesion',
                            controller: searchSesionController,
                            style: const TextStyle(fontSize: 20.0),
                            decoration: InputDecoration( 
                              labelText: 'Buscar', 
                              labelStyle: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchSesionController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _limpiarBusqueda,
                                  )
                                : null 
                            ),
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                _filtrarSesion(value);
                              } else {
                                setState(() { 
                                  _sesionFiltrada = []; 
                                }); 
                              }
                            },
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                          
                    FutureBuilder<List<Sesion>>(
                      future: _sesionData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }else if (snapshot.hasError) {
                          return const Center(child: Text('Error al cargar la Sección.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                        } else if (snapshot.hasData) {
                          final sesionTable = _sesionFiltrada.isNotEmpty 
                                ? _sesionFiltrada
                                : snapshot.data ?? [];
                          
                          bool estadoActivo = sesionTable.every((sesion) => sesion.estado);
                          
                          return Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(7.0),
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
                                  bodySmall: const TextStyle(
                                    fontSize: 20,           // Ajusta el tamaño del número
                                    color: Colors.black,    // Cambia el color del texto (ajústalo según tu preferencia)
                                    fontWeight: FontWeight.bold, // Hace el texto más visible
                                  ),
                                ),
                              ),
                              child: PaginatedDataTable(
                                header: const Text('Tabla de Recopilación para Encuesta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                columns: const [
                                  DataColumn(label: Text('No. de Sección', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Tipo de Respuesta.', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Número de \nPregunta en la \nEncuesta.', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('No. Pregunta.', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('No. Sub Pregunta.', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Requerimiento (Opcional).', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Enviar esta \npregunta a la \nencuesta.', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Acción', style: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold)))
                                ],
                                source: _SesionDataSource(sesionTable, _showEditDialogSesion, _showDeleteDialogSesion, _actualizarEstado),
                                headingRowColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 2, 37, 4)), // Fondo de encabezado
                                rowsPerPage: 10, //numeros de filas
                                columnSpacing: 50, //espacios entre columnas
                                horizontalMargin: 40, //para aplicarle un margin horizontal a los campo de la tabla
                                showCheckboxColumn: false, //oculta la columna de checkboxes
                                dataRowMinHeight: 60.0,  // Altura mínima de fila
                                dataRowMaxHeight: 80.0,  // Altura máxima de fila
                                showFirstLastButtons: true,
                                headingRowHeight: 135.0, // Altura del encabezado
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _actualizarEstadoTodasSesiones(!estadoActivo);
                                      setState(() {
                                        for (var sesion in sesionTable) {
                                          sesion.estado = !estadoActivo;
                                        }
                                      });                                    
                                    }, 
                                    child: Text(
                                      estadoActivo ? 'Deshabilitar Encuestas' : 'Habilitar Encuestas',
                                      style: const TextStyle(fontSize: 25, color: Color.fromARGB(255, 1, 133, 14), fontWeight: FontWeight.bold),
                                    )
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Center(child: Text('No hay datos disponibles.'));
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Stack(
          children: [
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
                    if (dy > MediaQuery.of(context).size.height - kToolbarHeight - 60) { // Ajusta para la altura del AppBar y del SpeedDial desplegado
                        dy = MediaQuery.of(context).size.height - kToolbarHeight - 60;
                    }
      
                    position = Offset(dx, dy);
                  });
                },
                child: _bottonSaveSpeedDial(),
              )
            )
          ]
        ),
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
          backgroundColor: const Color.fromARGB(255, 6, 171, 20),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar Pregunta',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialog()
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, size: 20),
          backgroundColor: const Color.fromARGB(255, 10, 239, 159),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar SubPregunta',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialogSubPregunta()
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, size: 20),
          backgroundColor: const Color.fromARGB(255, 125, 240, 119),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar Sección',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialogSesion()
        ),
      ],
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),  // Aplica margen
            width: 600,
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'noPregunta',
                    keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Número de la Pregunta',
                      labelFrontSize: 30.5,
                      hintext: '#',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.numeric(errorText: 'Este campo es requerido')
                  ),
                  
                  FormBuilderTextField(
                    name: 'pregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Ingresar la Pregunta',
                      labelFrontSize: 30.5,
                      hintext: '¿Agregar preguntas?',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.question_mark_outlined,size: 30.0),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),
                ],
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataPreg = _formKey.currentState!.value;
                  final newQuestion = int.parse(dataPreg['noPregunta']);

                  Preguntas? existingQuestion = await ApiServicePreguntas('http://wepapi.somee.com').getOnePregunta(newQuestion);

                  if (existingQuestion != null) {
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Número de la pregunta ya existente', style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold)),
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
                            child: Text('El No. $newQuestion ya está en uso. Por favor ingrese otro.', style: const TextStyle(fontSize: 28.0))
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
                      }
                    );
                    return;
                  }

                  Preguntas nuevaPregunta = Preguntas(
                    codPregunta: newQuestion, 
                    pregunta: dataPreg['pregunta'],
                  ); // Para verificar el valor antes de la asignación

                  try{
                    final response = await ApiServicePreguntas('http://wepapi.somee.com').postPreguntas(nuevaPregunta);

                    if(response.statusCode == 201) {
                      print('La pregunta fue creado con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'La pregunta fue creado con éxito');
                      // Future.delayed(const Duration(seconds: 2), () { Navigator.of(context).pop(); });
                      _fetchData();
                    } else {
                      print('Error al crear la pregunta: ${response.body}');
                      _showErrorDialog(context, 'Error al crear la pregunta.');
                      Future.delayed(const Duration(seconds: 2), () { Navigator.of(context).pop(); });
                    }
                  } catch (e) {
                    print('Excepción al crear la pregunta: $e');
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

  void _showEditDialog(Preguntas questionUpLoad) {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'pregunta': questionUpLoad.pregunta,
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'pregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Ingresar la Pregunta',
                      labelFrontSize: 30.5,
                      hintext: '¿Agregar preguntas?',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.question_mark_outlined,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  )
                ],
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()){
                  final formData = _formKey.currentState!.value;
                  Preguntas askUpLoad = Preguntas(
                    codPregunta: questionUpLoad.codPregunta.toInt(),
                    pregunta: formData['pregunta'],
                  );

                  try{
                    final response = await ApiServicePreguntas('http://wepapi.somee.com')
                      .putPreguntas(questionUpLoad.codPregunta, askUpLoad);

                    if(response.statusCode == 204) {
                      print('La pregunta fue modificada con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'La pregunta fue actualizado con éxito');
                      _fetchData();
                    } else {
                      print('Error al modificar la pregunta: ${response.body}');
                      _showErrorDialog(context, 'Error al modificar la pregunta');
                    }
                  } catch (e) {
                    print('Excepción al modificar la pregunta: $e');
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

  void _showDeleteDialog(Preguntas questionDelete) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: const EdgeInsets.fromLTRB(70, 30, 70, 50),
          content: Text('¿Estás seguro de que deseas eliminar la pregunta número: ${questionDelete.codPregunta}?', style: const TextStyle(fontSize: 30)),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () async {
                // Llamar al servicio de eliminación
                try {
                  final response = await ApiServicePreguntas('http://wepapi.somee.com')
                      .deletePreguntas(questionDelete.codPregunta);
                  if (response.statusCode == 204) {
                    print('Pregunta eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _showSuccessDialog(context, 'La pregunta fue eliminado con éxito');
                    _fetchData();
                  } else if (response.statusCode == 400) {
                    final responseBody = jsonDecode(response.body);
                    _showErrorDialog(context, responseBody['message']);
                  } else {
                    print('Error al eliminar la pregunta: ${response.body}');
                    _showErrorDialog(context, 'Error al eliminar la Pregunta: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar la pregunta: $e');
                }
              },
            ),
          ],
        );
      }
    );
  }

  void _showCreateDialogSubPregunta() {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Sub-Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),  // Aplica margen
            width: 400,
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'codigo',
                    decoration: InputDecorations.inputDecoration(
                      hintext: '#',
                      hintFrontSize: 30.0,
                      labeltext: 'Codigo de Sub - Pregunta',
                      labelFrontSize: 30.5,
                      icono: const Icon(Icons.numbers),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'subPreguntas',
                    decoration: InputDecorations.inputDecoration(
                      hintext: '',
                      hintFrontSize: 30.0,
                      labeltext: 'Ingresar la sub-pregunta',
                      labelFrontSize: 30.5,
                      icono: const Icon(Icons.help_outline_outlined),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  )
                ],
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()){
                  final dataSebPreg = _formKey.currentState!.value;
                  final newSubPregunta = dataSebPreg['codigo'];

                  SubPregunta? existingSubPregunta = await ApiServiceSubPreguntas('http://wepapi.somee.com').getOneSubPreg(newSubPregunta);

                  if (existingSubPregunta != null) {
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('No. de la sub-pregunta ya existente', style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold)),
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
                            child: Text('El No. $newSubPregunta ya está en uso. Por favor ingrese otro.', style: const TextStyle(fontSize: 28.0))
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
                      }
                    );
                    return;
                  }

                  SubPregunta nuevaSubPregunta = SubPregunta(
                    codSubPregunta: newSubPregunta,
                    subPreguntas: dataSebPreg['subPreguntas']
                  );

                  try{
                    final response = await ApiServiceSubPreguntas('http://wepapi.somee.com').postSubPreg(nuevaSubPregunta);

                    if(response.statusCode == 201) {
                      print('Las sub-Preguntas fue creado con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'Las sub-Preguntas fue creado con éxito');
                      _fetchDataSubPregu();
                    } else {
                      print('Error al crear las sub-Preguntas: ${response.body}');
                      _showErrorDialog(context, 'Error al crear las sub-Preguntas.');
                    }
                  } catch (e) {
                    print('Excepción al crear las sub-Preguntas: $e');
                  }
                }
              },
              child: const Text('Crear', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
            )
          ]
        );
      }
    );
  }

  TextButton buttonStop(BuildContext context) {
    return TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo sin realizar acción
            }, 
            child: const Text('Cancelar', style: TextStyle(fontSize: 30)),
          );
  }

  void _showEditDialogSubPregunta(SubPregunta subQuestionUpLoad) {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar Sub-Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'subPreguntas': subQuestionUpLoad.subPreguntas
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'subPreguntas',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Modicar la Sub pregunta',
                      labelFrontSize: 30.5,
                      hintext: '¿Editar preguntas?',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.question_mark_outlined,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),
                ],
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()) {
                  final dataSebPreg = _formKey.currentState!.value;

                  SubPregunta nuevaSubPregunta = SubPregunta(
                    codSubPregunta: subQuestionUpLoad.codSubPregunta.toString(),
                    subPreguntas: dataSebPreg['subPreguntas']
                  );

                  try{
                    final response = await ApiServiceSubPreguntas('http://wepapi.somee.com')
                      .putSubPreg(subQuestionUpLoad.codSubPregunta, nuevaSubPregunta);

                    if(response.statusCode == 204) {
                      print('La sub-pregunta fue modificada con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'Las sub-Preguntas fue actulaiza con éxito');
                      _fetchDataSubPregu();
                    } else {
                      print('Error al modificar la sub-pregunta: ${response.body}');
                      _showErrorDialog(context, 'Error al modificar la sub-pregunta');
                    }
                  } catch (e) {
                    print('Excepción al modificar la sub-pregunta: $e');
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

  void _showDeleteDialogSubPregunta(SubPregunta subQuestionDelete) {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Sub Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: const EdgeInsets.fromLTRB(70, 30, 70, 50),
          content: Text('¿Estás seguro de que deseas eliminar la sub-pregunta numero: ${subQuestionDelete.codSubPregunta}?', style: const TextStyle(fontSize: 30)),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () async {
                // Llamar al servicio de eliminación
                try {
                  final response = await ApiServiceSubPreguntas('http://wepapi.somee.com')
                      .deleteSubPreg(subQuestionDelete.codSubPregunta);
                  if (response.statusCode == 204) {
                    print('Sub pregunta eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _showSuccessDialog(context, 'Las sub-Preguntas fue creado con éxito');
                    _fetchDataSubPregu();
                  } else if (response.statusCode == 400) {
                    final responseBody = jsonDecode(response.body);
                    _showErrorDialog(context, responseBody['message']);
                  } else {
                    print('Error al eliminar la sub-pregunta: ${response.body}');
                    _showErrorDialog(context, 'Error al eliminar la Sub-Pregunta: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar la sub-pregunta: $e');
                  _showErrorDialog(context, 'Error al eliminar la Linea: $e');
                }
              },
            ),
          ],
        );
      }
    );
  }

  void _showCreateDialogSesion() {
    bool estado = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Sección', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),  // Aplica margen
            width: 600,
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'identifEncuesta',
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'No. Pregunta en la Encuesta',
                      labelFrontSize: 30.5,
                      hintext: 'Ingresar el No. Identificación de la pregunta',
                      hintFrontSize: 25.0,
                      icono: const Icon(Icons.question_answer, size: 30.0),
                      errorSize: 20.0,
                    ),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                  ),

                  FormBuilderDropdown<int>(
                    name: 'codPregunta',
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Pregunta',
                      labelFrontSize: 30.5,
                      hintext: 'Elegir la Pregunta',
                      hintFrontSize: 25.0,
                      icono: const Icon(Icons.question_answer, size: 30.0),
                      errorSize: 20.0,
                    ),
                    items: _questions.map((preg) {
                      return DropdownMenuItem(
                        value: preg.codPregunta,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                preg.pregunta, 
                                overflow: TextOverflow.ellipsis, // Maneja texto muy largo
                                maxLines: 2, // Limita el texto a 2 líneas
                              )
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _savedQuestion = value!;
                        print('Pregunta seleccionada: $_savedQuestion');
                      });
                    },
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                    isExpanded: true,
                    // dropdownColor: Colors.grey[200], // Cambiar el color del fondo
                    iconEnabledColor: Colors.blue, // Color del icono desplegable
                    menuMaxHeight: 300.0, // Altura máxima del cuadro desplegable
                  ),
                  const SizedBox(height: 20),

                  FormBuilderDropdown(
                    name: 'codSubPregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Sub Pregunta',
                      labelFrontSize: 30.5,
                      hintext: 'Elegir la Sub-Pregunta (si lo requiere)',
                      hintFrontSize: 25.0,
                      icono: const Icon(Icons.subdirectory_arrow_right, size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    items: [
                      const DropdownMenuItem(
                        value: null, // Valor para la opción "No elegir sub-preguntas"
                          child: Text(
                            'Elegir o dejarlo vacío',
                            style: TextStyle(fontSize: 20.0)
                          )
                      ),
                      ..._subQuestions.map((subPreg) {
                        return DropdownMenuItem(
                            value: subPreg.codSubPregunta,
                            child: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                        subPreg.subPreguntas!, overflow: TextOverflow.clip)
                                ),
                              ],
                            )
                        );
                      }).toList(),
                    ],
                    isExpanded: true, // Permite que los ítems se expandan al ancho disponible
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                  ),
                  const SizedBox(height: 20),

                  FormBuilderDropdown<String>(
                    name: 'tipoRespuesta',
                    menuMaxHeight: 250.0, // Altura máxima del cuadro desplegable
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Elige Tipo de Respuesta',
                      labelFrontSize: 30.5,
                      // hintext: 'Eliga como se responder esta pregunta',
                      // hintFrontSize: 30.0,
                      icono: const Icon(Icons.list_alt, size: 30.0),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 25.0, color: Color.fromARGB(255, 1, 1, 1)),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Respuesta Abierta',
                        child: Text('Respuesta Abierta')
                      ),
                      DropdownMenuItem(
                        value: 'Seleccionar: Si, No, N/A',
                        child: Text('Seleccionar: Si, No, N/A'),
                      ),
                      DropdownMenuItem(
                        value: 'Calificar del 1 a 10',
                        child: Text('Calificar del 1 a 10'),
                      ),
                      DropdownMenuItem(
                        value: 'Solo SI o No',
                        child: Text('Solo SI o No'),
                      ),
                      DropdownMenuItem(
                        value: 'Edad',
                        child: Text('Edad'),
                      ),
                      DropdownMenuItem(
                        value: 'Nacionalidad',
                        child: Text('Nacionalidad'),
                      ),
                      DropdownMenuItem(
                        value: 'Título de transporte',
                        child: Text('Título de transporte'),
                      ),
                      DropdownMenuItem(
                        value: 'Producto utilizado',
                        child: Text('Producto utilizado'),
                      ),
                      DropdownMenuItem(
                        value: 'Género',
                        child: Text('Género'),
                      ),
                      DropdownMenuItem(
                        value: 'Frecuencia de viajes por semana',
                        child: Text('Frecuencia de viajes por semana'),
                      ),
                      DropdownMenuItem(
                        value: 'Expectativa del pasajero',
                        child: Text('Expectativa del pasajero'),
                      ),
                      DropdownMenuItem(
                        value: 'Conclusión',
                        child: Text('Conclusión'),
                      ),
                      DropdownMenuItem(
                        value: 'Motivo del viaje',
                        child: Text('Motivo del viaje'),
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTipRespuestas = value!;
                      });
                    },
                    initialValue: 'Respuesta Abierta',
                  ),
                  const SizedBox(height: 20),

                  FormBuilderDropdown(
                    name: 'nota',
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Elige el Requerimiento',
                      labelFrontSize: 30.5,
                      icono: const Icon(Icons.assignment, size: 30.0),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 25.0, color: Color.fromARGB(255, 1, 1, 1)),
                    items: const  [
                      DropdownMenuItem(
                          value: null,
                          child: Text('No se requiere nada en la pregunta')
                      ),
                      DropdownMenuItem(
                          value: 'Requiere Justificación (Opcional)',
                          child: Text('Requiere Justificación (Opcional)')
                      ),
                      DropdownMenuItem(
                          value: 'Requiere Comentarios (Opcional)',
                          child: Text('Requiere Comentarios (Opcional)')
                      ),
                      DropdownMenuItem(
                          value: 'Comentarios y Justificación (Opcional)',
                          child: Text('Requiere Comentarios y Justificación (Opcional)')
                      ),
                      DropdownMenuItem(
                          value: 'En caso de responder (Si) finaliza la encuesta',
                          child: Text('En caso de responder (Si) finaliza la encuesta')
                      )
                    ],
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),

                  FormBuilderField(
                    name: 'estado',
                    builder: (FormFieldState<dynamic> field) {
                      return FlutterSwitch(
                        value: estado,
                        activeText: 'Agregando a Encuesta',
                        inactiveText: 'Descartado de la Encuesta',
                        activeColor: Colors.green,
                        inactiveColor: Colors.red,
                        activeToggleColor: Colors.white,
                        inactiveToggleColor: Colors.white,
                        activeTextColor: Colors.white,
                        inactiveTextColor: Colors.white,
                        activeIcon: const Icon(Icons.check_circle, color: Colors.green),
                        inactiveIcon: const Icon(Icons.close, color: Colors.red),
                        showOnOff: true, // Esta propiedad muestra el texto
                        onToggle: (value) => setState(() {
                          estado = value;
                          field.didChange(value);
                        }),
                        width: 520.0, 
                        height: 50.5, 
                        valueFontSize: 27.0, //agrandar los textos
                        toggleSize: 48.0, //size del icomo
                        borderRadius: 50.0, 
                        padding: 8.0,
                        duration: const Duration(milliseconds: 550), // Duración de la animación para un movimiento suave
                      );
                    },
                  )
                ] 
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataSesion = _formKey.currentState!.value;

                  Sesion nuevaSesion = Sesion(
                    tipoRespuesta: dataSesion['tipoRespuesta'],
                    identifEncuesta: dataSesion['identifEncuesta'],
                    codPregunta: _savedQuestion!,
                    codSubPregunta: dataSesion['codSubPregunta'],
                    rango: dataSesion['nota'],
                    estado: dataSesion['estado']
                  );

                  print('Resultados ${nuevaSesion}');

                  try{
                    final response = await ApiServiceSesion('http://wepapi.somee.com').postSesion(nuevaSesion);

                    if(response.statusCode == 201) {
                      print('La Sesion fue creado con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'La Sección fue creado con éxito');
                      _refreshSesion();
                      
                    } else {
                      print('Error al crear la Sesion: ${response.body}');
                      _showErrorDialog(context, 'Error al crear la Sección.');
                    }
                  } catch (e) {
                    print('Excepción al crear la Sesion: $e');
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

  void _showEditDialogSesion(Sesion sectionUpload) {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar La Sección', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'tipoRespuesta': sectionUpload.tipoRespuesta,
                'identifEncuesta': sectionUpload.identifEncuesta,
                'codPregunta': sectionUpload.codPregunta,
                'codSubPregunta': sectionUpload.codSubPregunta,
                'nota': sectionUpload.rango
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'identifEncuesta',
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'No. Pregunta en la Encuesta',
                      labelFrontSize: 30.5,
                      hintext: 'Ingresar el No. Identificación de la pregunta',
                      hintFrontSize: 25.0,
                      icono: const Icon(Icons.question_answer, size: 30.0),
                      errorSize: 20.0,
                    ),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                  ),

                  FormBuilderDropdown<String>(
                    name: 'tipoRespuesta',
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Elige Tipo de Respuesta',
                      labelFrontSize: 30.5,
                      // hintext: 'Eliga como se responder esta pregunta',
                      // hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Respuesta Abierta',
                        child: Text('Respuesta Abierta')
                      ),
                      DropdownMenuItem(
                        value: 'Seleccionar: Si, No, N/A',
                        child: Text('Seleccionar: Si, No, N/A'),
                      ),
                      DropdownMenuItem(
                        value: 'Calificar del 1 a 10',
                        child: Text('Calificar del 1 a 10'),
                      ),
                      DropdownMenuItem(
                        value: 'Solo SI o No',
                        child: Text('Solo SI o No'),
                      ),
                      DropdownMenuItem(
                        value: 'Edad',
                        child: Text('Edad'),
                      ),
                      DropdownMenuItem(
                        value: 'Nacionalidad',
                        child: Text('Nacionalidad'),
                      ),
                      DropdownMenuItem(
                        value: 'Título de transporte',
                        child: Text('Título de transporte'),
                      ),
                      DropdownMenuItem(
                        value: 'Producto utilizado',
                        child: Text('Producto utilizado'),
                      ),
                      DropdownMenuItem(
                        value: 'Género',
                        child: Text('Género'),
                      ),
                      DropdownMenuItem(
                        value: 'Frecuencia de viajes por semana',
                        child: Text('Frecuencia de viajes por semana'),
                      ),
                      DropdownMenuItem(
                        value: 'Expectativa del pasajero',
                        child: Text('Expectativa del pasajero'),
                      ),
                      DropdownMenuItem(
                        value: 'Conclusion',
                        child: Text('Conclusion'),
                      ),
                      DropdownMenuItem(
                        value: 'Motivo del viaje',
                        child: Text('Motivo del viaje'),
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTipRespuestas = value!;
                      });
                    },
                    // initialValue: 'Respuesta Abierta',
                  ),

                  FormBuilderDropdown<int>(
                    name: 'codPregunta',
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'No. de Pregunta',
                      labelFrontSize: 30.5,
                      icono: const Icon(Icons.numbers,size: 30.0),
                      errorSize: 20.0,
                    ),
                    items: _questions.map((preg) {
                      return DropdownMenuItem(
                        value: preg.codPregunta,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(preg.pregunta, overflow: TextOverflow.clip)
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _savedQuestion = value!;
                        print('Pregunta seleccionada: $_savedQuestion');
                      });
                    },
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                    isExpanded: true,
                  ),

                  /*
                  FormBuilderDropdown<String>(
                    name: 'codSubPregunta',
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Cod. Sub Pregunta',
                      labelFrontSize: 30.5,
                      hintext: 'Elegir la Sub-Pregunta (si lo requiere)',
                      hintFrontSize: 25.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    items: _subQuestions.map((subPreg) {
                      return DropdownMenuItem(
                        value: subPreg.codSubPregunta,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                subPreg.subPreguntas!, overflow: TextOverflow.clip)
                            ),
                          ],
                        )
                      );
                    }).toList(),
                    isExpanded: true, // Permite que los ítems se expandan al ancho disponible
                  ),*/

                  FormBuilderDropdown(
                    name: 'codSubPregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Sub Pregunta',
                      labelFrontSize: 30.5,
                      hintext: 'Elegir la Sub-Pregunta (si lo requiere)',
                      hintFrontSize: 25.0,
                      icono: const Icon(Icons.subdirectory_arrow_right, size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    items: [
                      const DropdownMenuItem(
                          value: null, // Valor para la opción "No elegir sub-preguntas"
                          child: Text(
                              'Elegir o dejarlo vacío',
                              style: TextStyle(fontSize: 20.0)
                          )
                      ),
                      ..._subQuestions.map((subPreg) {
                        return DropdownMenuItem(
                            value: subPreg.codSubPregunta,
                            child: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                        subPreg.subPreguntas!, overflow: TextOverflow.clip)
                                ),
                              ],
                            )
                        );
                      }).toList(),
                    ],
                    isExpanded: true, // Permite que los ítems se expandan al ancho disponible
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                  ),

                  FormBuilderDropdown(
                    name: 'nota',
                    menuMaxHeight: 400.0, // Altura máxima del cuadro desplegable
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Elige el Requerimiento',
                      labelFrontSize: 30.5,
                      icono: const Icon(Icons.numbers,size: 30.0),
                      errorSize: 20.0,
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    items: const  [
                      DropdownMenuItem(
                          value: null,
                          child: Text('No se requiere nada en la pregunta')
                      ),
                      DropdownMenuItem(
                          value: 'Requiere Justificación (Opcional)',
                          child: Text('Requiere Justificación (Opcional)')
                      ),
                      DropdownMenuItem(
                          value: 'Requiere Comentarios (Opcional)',
                          child: Text('Requiere Comentarios (Opcional)')
                      ),
                      DropdownMenuItem(
                          value: 'Comentarios y Justificación (Opcional)',
                          child: Text('Requiere Comentarios y Justificación (Opcional)')
                      ),
                      DropdownMenuItem(
                          value: 'En caso de responder (Si) finaliza la encuesta',
                          child: Text('En caso de responder (Si) finaliza la encuesta')
                      )
                    ],
                    isExpanded: true,
                  )
                ],
              )
            ),
          ),
          actions: [
            buttonStop(context),
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()) {
                  final dataSesion = _formKey.currentState!.value;

                  Sesion sesionUpLoad = Sesion(
                    idSesion: sectionUpload.idSesion,
                    tipoRespuesta: selectedTipRespuestas,
                    identifEncuesta: dataSesion['identifEncuesta'],
                    codPregunta: int.parse(dataSesion['codPregunta'].toString()),
                    codSubPregunta: dataSesion['codSubPregunta'],
                    estado: sectionUpload.estado,
                    rango: dataSesion['nota']
                  );

                  print('Resultados de sesionUpLoad: $sesionUpLoad');

                  try{
                    final response = await ApiServiceSesion('http://wepapi.somee.com')
                      .putSesion(sectionUpload.idSesion!, sesionUpLoad);

                    if(response.statusCode == 204) {
                      print('La Sesion fue modificada con éxito');
                      Navigator.of(context).pop();
                      _showSuccessDialog(context, 'La Sección fue modificada con éxito');
                      _refreshSesion();
                    } else {
                      print('Error al modificar la Sesion: ${response.body}');
                      _showErrorDialog(context, 'Error al modificar la Sección');
                    }
                  } catch (e) {
                    print('Excepción al modificar la Sesion: $e');
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

  void _showDeleteDialogSesion(Sesion sectionDelete) {
    showDialog(
      context: context, 
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Sección', style: TextStyle(fontSize: 33.0)),
          content: Text('¿Estás seguro de que deseas eliminar la sección no. ${sectionDelete.idSesion}?', style: const TextStyle(fontSize: 30)),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () async {
                try{
                  final response = await ApiServiceSesion('http://wepapi.somee.com').deleteSesion(sectionDelete.idSesion!);

                  if (response.statusCode == 204) {
                    print('Sesion eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _showSuccessDialog(context, 'La Sección fue eliminado con éxito');
                    _refreshSesion();
                  } else {
                    print('Error al eliminar la sección: ${response.body}');
                    _showErrorDialog(context, 'Error al eliminar la sesión');
                  }
                } catch (e) {
                  print('Excepción al eliminar la sesion: $e');
                }
              },
            )
          ],
        );
      }
    );
  }

  void _actualizarEstado(Sesion actualizarEstado_Sesion) async { //este metodo solo esta para habilitar y deshabilitar las preguntas en la cuesta
    try{

      Sesion estadoActualizador = Sesion(
        idSesion: actualizarEstado_Sesion.idSesion,
        tipoRespuesta: actualizarEstado_Sesion.tipoRespuesta,
        identifEncuesta: actualizarEstado_Sesion.identifEncuesta,
        codPregunta: actualizarEstado_Sesion.codPregunta,
        codSubPregunta: actualizarEstado_Sesion.codSubPregunta,
        estado: actualizarEstado_Sesion.estado == true ? true : false, //para modificar el campo estado
        rango: actualizarEstado_Sesion.rango
      );

      print('Estado actualizado a: ${estadoActualizador.estado}');

      try{
        final response = await ApiServiceSesion('http://wepapi.somee.com')
          .putSesion(actualizarEstado_Sesion.idSesion!, estadoActualizador);

        if (estadoActualizador.estado) { // dependiento del valor del campo estado aparecera un cuadro de dialoga que notifica que se ha habilitado o deshabilitado de la encuesta
          if(response.statusCode == 204) {
            print('La Sesion fue modificada con éxito');
            _showSuccessDialog(context, 'La Sección fue enviado a la Encuesta');
            _refreshSesion();
          } else {
            print('Error al modificar la Sesion: ${response.body}');
            _showErrorDialog(context, 'Error al enviar la Sección a la Encuesta');
          }
        } else {
          if(response.statusCode == 204) {
            print('La Sesion fue modificada con éxito');
            _showSuccessDialog(context, 'La Sección fue deshabilitado de la Encuesta');
            _refreshSesion();
          } else {
            print('Error al modificar la Sesion: ${response.body}');
            _showErrorDialog(context, 'Error al deshabilitar la Sección en la Encuesta');
          }
        }
        
      } catch (e) {
        print('Excepción al modificar la Sesion: $e');
      }
    } catch (e) {
      // Manejar error si la actualización falla
      print('Error al actualizar el estado: $e');
    }
  }

  void _actualizarEstadoTodasSesiones(bool nuevoEstado) async {
    try {
      for (var sesion in _sesionFiltrada) {
        Sesion estadoActualizador = Sesion(
          idSesion: sesion.idSesion,
          tipoRespuesta: sesion.tipoRespuesta,
          identifEncuesta: sesion.identifEncuesta,
          codPregunta: sesion.codPregunta,
          codSubPregunta: sesion.codSubPregunta,
          estado: nuevoEstado,
          rango: sesion.rango,
        );

        final response = await ApiServiceSesion('http://wepapi.somee.com').putSesion(sesion.idSesion!, estadoActualizador);

        if (estadoActualizador.estado) {
          if (response.statusCode == 204) {
            sesion.estado = nuevoEstado;
            print('todas las secciones fue modificada con éxito');
          } else {
            print('Error al modificar la Sesión ${sesion.idSesion}: ${response.body}');
            _showErrorDialog(context, 'Error al modificar todo el estado de la Sección');
          }
        } else {
          if (response.statusCode == 204) {
            sesion.estado = nuevoEstado;
            print('todas las secciones fue modificada con éxito');
          } else {
            print('Error al modificar la Sesión ${sesion.idSesion}: ${response.body}');
            _showErrorDialog(context, 'Error al deshabilitar todos los estados de la Sección');
          }
        }
      }
      _refreshSesion();
      _showSuccessDialog(context, 'Todas las secciones han sido ${nuevoEstado ? 'enviadas a la Encuesta' : 'deshabilitadas de la Encuesta'}');
    } catch (e) {
      print('Error al actualizar todas las sesiones: $e');
      _showErrorDialog(context, 'Error al actualizar todas las sesiones');
    }
  }


  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          contentPadding: EdgeInsets.zero,  // Elimina el padding por defecto
          content: Container(
            margin: const EdgeInsets.fromLTRB(70, 20, 70, 50),  // Aplica margen
            child: Text(message, style: const TextStyle(fontSize: 28))
          ),
          actions: [ 
            TextButton( 
              child: const Text("OK", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)), 
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

class _PreguntasDataSource extends DataTableSource {
  final List<Preguntas> preguntasData;
  final Function(Preguntas) onEdit;
  final Function(Preguntas) onDelete;

  _PreguntasDataSource(this.preguntasData, this.onEdit, this.onDelete);

  @override
  DataRow getRow(int index) {
    if (index >= preguntasData.length) return const DataRow(cells: []);

    final ask = preguntasData[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>((states) {
        // Color alterno para las filas
        return (preguntasData.indexOf(ask) % 2 == 0)
              ? Colors.blueGrey.shade50
              : Colors.white;
      }),
      cells: [
        DataCell(Text(ask.codPregunta.toString(), style: const TextStyle(fontSize: 20.0))), // Conversión explícita de int a String usando .toString()
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 420, minWidth: 420), // Ancho fijo para la celda
            child: Text(ask.pregunta, style: const TextStyle(fontSize: 20.0), softWrap: true)
          )
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // _showEditDialog(ask);
                  onEdit(ask);
                }, 
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              
              IconButton(
                onPressed: () {
                  // _showDeleteDialog(ask);
                  onDelete(ask);
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
  int get rowCount => preguntasData.length;

  @override
  int get selectedRowCount => 0;
}

class _SubPreguntasDataSource extends DataTableSource {
  final List<SubPregunta> _subPreguntasData;
  final Function(SubPregunta) onEdit;
  final Function(SubPregunta) onDelete;

  _SubPreguntasDataSource(this._subPreguntasData, this.onEdit, this.onDelete);

  @override
  DataRow getRow(int index) {
    if (index >= _subPreguntasData.length) return const DataRow(cells: []);

    final sub = _subPreguntasData[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>((states) {
        // Color alterno para las filas
        return (_subPreguntasData.indexOf(sub) % 2 == 0)
              ? Colors.blueGrey.shade50
              : Colors.white;
      }),
      cells: [
        DataCell(Text(sub.codSubPregunta, style: const TextStyle(fontSize: 20.0))),
        DataCell(sub.subPreguntas != null ? Container(
          constraints: const BoxConstraints(maxWidth: 420, minWidth: 420),
          child: Text(sub.subPreguntas!, style: const TextStyle(fontSize: 20.0), softWrap: true)
        ) : const Text('')),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // _showEditDialogSubPregunta(sub);
                  onEdit(sub);
                }, 
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              
              IconButton(
                onPressed: () {
                  // _showDeleteDialogSubPregunta(sub);
                  onDelete(sub);
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
  int get rowCount => _subPreguntasData.length;

  @override
  int get selectedRowCount => 0;
}

class _SesionDataSource extends DataTableSource {
  final List<Sesion> _sesionData;
  final Function(Sesion) onEdit;
  final Function(Sesion) onDelete;
  final Function(Sesion) _estado;

  _SesionDataSource(this._sesionData, this.onEdit, this.onDelete, this._estado);

  @override
  DataRow getRow(int index) {
    if (index >= _sesionData.length) return const DataRow(cells: []);

    final section = _sesionData[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>((states) {
        // Color alterno para las filas
        return (_sesionData.indexOf(section) % 2 == 0)
              ? Colors.blueGrey.shade50
              : Colors.white;
      }),
      cells: [
        DataCell(Text(section.idSesion.toString(), style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(section.tipoRespuesta, style: const TextStyle(fontSize: 20.0))),
        DataCell(section.identifEncuesta != null ? Text(section.identifEncuesta!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(Text(section.codPregunta.toString(), style: const TextStyle(fontSize: 20.0))),
        DataCell(section.codSubPregunta != null ? Text(section.codSubPregunta!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(section.rango != null ? Text(section.rango!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(
          /*
          Switch(
            value: section.estado,
            onChanged: (value) {
              print('Cambiando el estado a: $value');
              section.estado = value;
              _estado(section);
              notifyListeners(); // Notifica los cambios en la tabla
            },
          )
           */
          FlutterSwitch(
            value: section.estado,
            activeColor: Colors.green,
            inactiveColor: Colors.red,
            activeToggleColor: Colors.white,
            inactiveToggleColor: Colors.white,
            activeTextColor: Colors.white,
            inactiveTextColor: Colors.white,
            activeIcon: const Icon(Icons.check_circle, color: Colors.green),
            inactiveIcon: const Icon(Icons.close, color: Colors.red),
            onToggle: (value) {
              print('Cambiando el estado a: $value');
              section.estado = value;
              _estado(section);
              notifyListeners(); // Notifica los cambios en la tabla
            },
            width: 120.0,
            height: 42.0,
            toggleSize: 36.0,
            borderRadius: 60.0,
            duration: const Duration(milliseconds: 550), // Duración de la animación
          )
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // _showEditDialogSesion(section);
                  onEdit(section);
                }, 
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              
              IconButton(
                onPressed: () {
                  // _showDeleteDialogSesion(section);
                  onDelete(section);
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
  int get rowCount => _sesionData.length;

  @override
  int get selectedRowCount => 0;
}
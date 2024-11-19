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

class PreguntaScreenNavbar extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const PreguntaScreenNavbar({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<PreguntaScreenNavbar> createState() => _PreguntaScreenNavbarState();
}

class _PreguntaScreenNavbarState extends State<PreguntaScreenNavbar> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiServicePreguntas _apiServicePreguntas = ApiServicePreguntas('https://10.0.2.2:7190');
  late Future<List<Preguntas>> _preguntas;
  final ApiServiceSubPreguntas  _apiServiceSubPreguntas = ApiServiceSubPreguntas('https://10.0.2.2:7190');
  late Future<List<SubPregunta>> _subPreguntas;
  final ApiServiceSesion _apiServiceSesion = ApiServiceSesion('https://10.0.2.2:7190');
  late Future<List<Sesion>> _sesion;
  String selectedTipRespuestas = 'Respuesta Abierta';
  int _rangoValor = 1; // Valor inicial dentro del rango permitido
  String rango = "1,10"; // Ejemplo de rango
  final tipoRespuestaController = TextEditingController();
  late List<String> rangos;
  late int desde;
  late int hasta;
  late List<int> opcionesRango;
  Offset position = const Offset(700, 1150);
  List<Preguntas> _questions = [];
  int? _savedQuestion;
  List<SubPregunta> _subQuestions = [];
  // String? _savedSubQuestion;

  String numbersToRango(int desde, int hasta) {
    if (hasta == 0) return 'null';
    
    String result = '';
    for (var i = desde; i <= hasta; i++) {
      result += '|$i| ';
    }
    return result.trim();
  }

  @override
  void initState(){
    super.initState();
    _preguntas = _apiServicePreguntas.getPreguntas();
    _subPreguntas = _apiServiceSubPreguntas.getSubPreg();
    _sesion = _apiServiceSesion.getSesion();
    _fetchData();
    _fetchDataSubPregu();
    _refreshSesion();
    initializeRango();
  }

  void initializeRango() {
    rangos = rango.split(','); // Dividir el rango en una lista
    desde = int.parse(rangos[0].trim());
    hasta = int.parse(rangos[1].trim());
    opcionesRango = [0] + List<int>.generate(hasta - desde + 1, (i) => desde + i);
  }


  void _refreshPreguntas() {
    setState(() {
      _preguntas = _apiServicePreguntas.getPreguntas();
    });
  }

  void _refreshSubPreguntas() {
    setState(() {
      _subPreguntas = _apiServiceSubPreguntas.getSubPreg();
    });
  }

  void _refreshSesion() {
    setState(() {
      _sesion = _apiServiceSesion.getSesion();
    });
  }

  Future<void> _fetchData() async {
    try{
      List<Preguntas> questions = await _apiServicePreguntas.getPreguntas();

      setState(() {
        _questions = questions;
        print('Lineas obtenidas: $_questions');
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _fetchDataSubPregu() async {
    try{
      List<SubPregunta>  subPreguntas = await _apiServiceSubPreguntas.getSubPreg();

      setState(() {
        _subQuestions = subPreguntas;
        print('Lineas obtenidas: $_subQuestions');
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
      appBar: AppBar(title: const Text('Sesion de Preguntas')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Tablas de Preguntas',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<Preguntas>>(
              future: _preguntas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }else if(snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la Sesion de Preguntas.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                }else {
                  final question = snapshot.data ?? [];
            
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Preguntas', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                      ],
                      rows: question.map((ask) {
                        return DataRow(
                          cells: [
                            DataCell(Text(ask.codPregunta.toString(), style: const TextStyle(fontSize: 20.0))), // Conversión explícita de int a String usando .toString()
                            DataCell(Text(ask.pregunta, style: const TextStyle(fontSize: 20.0))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showEditDialog(ask);
                                    }, 
                                    icon: const Icon(Icons.edit)
                                  ),
                                  
                                  IconButton(
                                    onPressed: () {
                                      _showDeleteDialog(ask);
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
              'Tablas de Sub Preguntas',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<SubPregunta>>(
              future: _subPreguntas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la Sesion de los Rango.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                } else {
                  final subPreg = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('NO', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Sub Preguntas', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                      ], 
                      rows: subPreg.map((sub) {
                        return DataRow(
                          cells: [
                            DataCell(Text(sub.codSubPregunta, style: const TextStyle(fontSize: 20.0))),
                            DataCell(sub.subPreguntas != null ? Text(sub.subPreguntas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showEditDialogSubPregunta(sub);
                                    }, 
                                    icon: const Icon(Icons.edit)
                                  ),
                                  
                                  IconButton(
                                    onPressed: () {
                                      _showDeleteDialogSubPregunta(sub);
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
              'Tablas de las Sesiones',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<Sesion>>(
              future: _sesion,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la Sesion.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
                } else {
                  final sesion = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No.', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Tipo de Respuesta.', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Tema.', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('No. Pregunta.', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('No. Sub Pregunta.', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Rango determinado.', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                      ], 
                      rows: sesion.map((section) {
                        return DataRow(
                          cells: [
                            DataCell(Text(section.idSesion.toString(), style: const TextStyle(fontSize: 20.0))),
                            DataCell(Text(section.tipoRespuesta, style: const TextStyle(fontSize: 20.0))),
                            DataCell(section.grupoTema != null ? Text(section.grupoTema!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                            DataCell(Text(section.codPregunta.toString(), style: const TextStyle(fontSize: 20.0))),
                            DataCell(section.codSubPregunta != null ? Text(section.codSubPregunta!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                            DataCell(section.rango != null ? Text(section.rango!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showEditDialogSesion(section);
                                    }, 
                                    icon: const Icon(Icons.edit)
                                  ),
                                  
                                  IconButton(
                                    onPressed: () {
                                      _showDeleteDialogSesion(section);
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
              },
            )
          ],
        ),
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
          label: 'Agregar Pregunta',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialog()
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, size: 20),
          backgroundColor: const Color.fromARGB(255, 10, 25, 239),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar SubPregunta',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialogSubPregunta()
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, size: 20),
          backgroundColor: const Color.fromARGB(255, 193, 0, 252),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          label: 'Agregar Sesion',
          labelStyle: const TextStyle(fontSize: 20.0),
          onTap: () => _showCreateDialogSesion()
        ),
      ],
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context, 
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
                      labeltext: 'Numero de la Pregunta',
                      labelFrontSize: 30.5,
                      hintext: '#',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
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

                  Preguntas? existingQuestion = await ApiServicePreguntas('https://10.0.2.2:7190').getOnePregunta(newQuestion);

                  if (existingQuestion != null) {
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('No de pregunta ya existente', style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold)),
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
                    final response = await ApiServicePreguntas('https://10.0.2.2:7190').postPreguntas(nuevaPregunta);

                    if(response.statusCode == 201) {
                      print('La pregunta fue creado con éxito');
                      Navigator.of(context).pop();
                      _refreshPreguntas();
                      _fetchData();
                    } else {
                      print('Error al crear la pregunta: ${response.body}');
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
                    final response = await ApiServicePreguntas('https://10.0.2.2:7190')
                      .putPreguntas(questionUpLoad.codPregunta, askUpLoad);

                    if(response.statusCode == 204) {
                      print('La pregunta fue modificada con éxito');
                      Navigator.of(context).pop();
                      _refreshPreguntas();
                      _fetchData();
                    } else {
                      print('Error al modificar la pregunta: ${response.body}');
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Pregunta', style: TextStyle(fontSize: 33.0)),
          contentPadding: const EdgeInsets.fromLTRB(70, 30, 70, 50),
          content: Text('¿Estás seguro de que deseas eliminar la pregunta numero: ${questionDelete.codPregunta}?', style: const TextStyle(fontSize: 30)),
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
                  final response = await ApiServicePreguntas('https://10.0.2.2:7190')
                      .deletePreguntas(questionDelete.codPregunta);
                  if (response.statusCode == 204) {
                    print('Pregunta eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _refreshPreguntas();
                    _fetchData();
                  } else {
                    print('Error al eliminar la pregunta: ${response.body}');
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
                      icono: const Icon(Icons.numbers)
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
                      icono: const Icon(Icons.help_outline_outlined)
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

                  SubPregunta? existingSubPregunta = await ApiServiceSubPreguntas('https://10.0.2.2:7190').getOneSubPreg(newSubPregunta);

                  if (existingSubPregunta != null) {
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('No de la sub-pregunta ya existente', style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold)),
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
                    final response = await ApiServiceSubPreguntas('https://10.0.2.2:7190').postSubPreg(nuevaSubPregunta);

                    if(response.statusCode == 201) {
                      print('Las sub-Preguntas fue creado con éxito');
                      Navigator.of(context).pop();
                      _refreshSubPreguntas();
                      _fetchDataSubPregu();
                    } else {
                      print('Error al crear las sub-Preguntas: ${response.body}');
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
                    final response = await ApiServiceSubPreguntas('https://10.0.2.2:7190')
                      .putSubPreg(subQuestionUpLoad.codSubPregunta, nuevaSubPregunta);

                    if(response.statusCode == 204) {
                      print('La sub-pregunta fue modificada con éxito');
                      Navigator.of(context).pop();
                      _refreshSubPreguntas();
                      _fetchDataSubPregu();
                    } else {
                      print('Error al modificar la sub-pregunta: ${response.body}');
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
                  final response = await ApiServiceSubPreguntas('https://10.0.2.2:7190')
                      .deleteSubPreg(subQuestionDelete.codSubPregunta);
                  if (response.statusCode == 204) {
                    print('Sub pregunta eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _refreshSubPreguntas();
                    _fetchDataSubPregu();
                  } else {
                    print('Error al eliminar la sub-pregunta: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar la sub-pregunta: $e');
                }
              },
            ),
          ],
        );
      }
    );
  }

  void _showCreateDialogSesion() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Sesion', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),  // Aplica margen
            width: 600,
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderDropdown<String>(
                    name: 'tipoRespuesta',
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
                        value: 'Selecionar: Si, No, N/A',
                        child: Text('Selecionar: Si, No, N/A'),
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
                        value: 'Genero',
                        child: Text('Genero'),
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
                    initialValue: 'Respuesta Abierta',
                  ),

                  FormBuilderTextField(
                    name: 'grupoTema',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Tema',
                      labelFrontSize: 30.5,
                      hintext: '(Si lo requiere)',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),
                  const SizedBox(height: 20),

                  FormBuilderDropdown<int>(
                    name: 'codPregunta',
                    style: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 1, 1, 1)),
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'No. de Pregunta',
                      labelFrontSize: 30.5,
                      icono: const Icon(Icons.numbers,size: 30.0),
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
                  const SizedBox(height: 20),

                  FormBuilderDropdown(
                    name: 'codSubPregunta',
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
                  ),
                  const SizedBox(height: 20),

                  FormBuilderTextField(
                    name: 'rango',
                    controller: tipoRespuestaController,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Determinar el Rango requerido',
                      labelFrontSize: 30.5,
                      hintext: 'Usa el slider para determinar el rango deseado.',
                      hintFrontSize: 20.0,
                      icono: const Icon(Icons.numbers, size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    enabled: false,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Selecciona el Rango:',
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: opcionesRango.map((int value) {
                      return ChoiceChip(
                        label: Text(value.toString(), style: const TextStyle(fontSize: 20.0)),
                        selected: _rangoValor == value,
                        onSelected: (bool selected) {
                          setState(() {
                            _rangoValor = selected ? value : _rangoValor;
                            tipoRespuestaController.text = numbersToRango(desde, _rangoValor);
                          });
                        },
                      );
                    }).toList(),
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
                  final dataSesion = _formKey.currentState!.value;

                  Sesion nuevaSesion = Sesion(
                    tipoRespuesta: dataSesion['tipoRespuesta'],
                    grupoTema: dataSesion['grupoTema'],
                    codPregunta: _savedQuestion!,
                    codSubPregunta: dataSesion['codSubPregunta'],
                    rango: dataSesion['rango']
                  );

                  print('Resultados ${nuevaSesion}');

                  try{
                    final response = await ApiServiceSesion('https://10.0.2.2:7190').postSesion(nuevaSesion);

                    if(response.statusCode == 201) {
                      print('La Sesion fue creado con éxito');
                      Navigator.of(context).pop();
                      _refreshSesion();
                      
                    } else {
                      print('Error al crear la Sesion: ${response.body}');
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar La Sesion', style: TextStyle(fontSize: 33.0)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'tipoRespuesta': sectionUpload.tipoRespuesta,
                'grupoTema': sectionUpload.grupoTema,
                'codPregunta': sectionUpload.codPregunta.toString(),
                'codSubPregunta': sectionUpload.codSubPregunta,
                'rango': sectionUpload.rango
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderDropdown<String>(
                    name: 'tipoRespuesta',
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
                        value: 'Selecionar: Si, No, N/A',
                        child: Text('Selecionar: Si, No, N/A'),
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
                        value: 'Genero',
                        child: Text('Genero'),
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

                  FormBuilderTextField(
                    name: 'grupoTema',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Tema',
                      labelFrontSize: 30.5,
                      hintext: ' ',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'codPregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'No. Pregunta',
                      labelFrontSize: 30.5,
                      hintext: ' ',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'codSubPregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Cod. Sub Pregunta',
                      labelFrontSize: 30.5,
                      hintext: 'Ingrese el codigo de la Sub-pregunta',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'rango',
                    controller: tipoRespuestaController,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Determinar el Rango requerido',
                      labelFrontSize: 30.5,
                      hintext: 'Usa el slider para determinar el rango deseado.',
                      hintFrontSize: 20.0,
                      icono: const Icon(Icons.numbers, size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    enabled: false,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Selecciona el Rango:',
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: opcionesRango.map((int value) {
                      return ChoiceChip(
                        label: Text(value.toString(), style: const TextStyle(fontSize: 20.0)),
                        selected: _rangoValor == value,
                        onSelected: (bool selected) {
                          setState(() {
                            _rangoValor = selected ? value : _rangoValor;
                            tipoRespuestaController.text = numbersToRango(desde, _rangoValor);
                          });
                        },
                      );
                    }).toList(),
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
                  final dataSesion = _formKey.currentState!.value;

                  Sesion sesionUpLoad = Sesion(
                    idSesion: sectionUpload.idSesion,
                    tipoRespuesta: selectedTipRespuestas,
                    grupoTema: dataSesion['grupoTema'],
                    codPregunta: int.parse(dataSesion['codPregunta'].toString()),
                    codSubPregunta: dataSesion['codSubPregunta'],
                    rango: dataSesion['rango']
                  );

                  print('Resultados de sesionUpLoad: $sesionUpLoad');

                  try{
                    final response = await ApiServiceSesion('https://10.0.2.2:7190')
                      .putSesion(sectionUpload.idSesion!, sesionUpLoad);

                    if(response.statusCode == 204) {
                      print('La Sesion fue modificada con éxito');
                      Navigator.of(context).pop();
                      _refreshSesion();
                    } else {
                      print('Error al modificar la Sesion: ${response.body}');
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Sesion', style: TextStyle(fontSize: 33.0)),
          content: Text('¿Estás seguro de que deseas eliminar la sesion no. ${sectionDelete.idSesion}?', style: const TextStyle(fontSize: 30)),
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
                  final response = await ApiServiceSesion('https://10.0.2.2:7190').deleteSesion(sectionDelete.idSesion!);

                  if (response.statusCode == 204) {
                    print('Sesion eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _refreshSesion();
                  } else {
                    print('Error al eliminar la sesion: ${response.body}');
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
}
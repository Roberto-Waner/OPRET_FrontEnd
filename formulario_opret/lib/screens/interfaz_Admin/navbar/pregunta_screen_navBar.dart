import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  String selectedTipRespuestas = '';
  final tipoRespuestaController = TextEditingController();
  List<double> rangoArray = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
  int _rangoValor = 0;

  String numbersToRango(int rango) {
    String result = '';
    for (var i = 0; i <= rango; i++) {
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
            bottom: 155,
            right: 10,
            child: FloatingActionButton.extended( //aqui se crea un boton flotante para agregar
              heroTag: 'Preguntas_tap',
              onPressed: () {
                _showCreateDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Pregunta')
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton.extended( //aqui se crea un boton flotante para agregar
              heroTag: 'SubPreguntas_tap',
              onPressed: () {
                _showCreateDialogSubPregunta();
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Sub-preguntas')
            ),
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: FloatingActionButton.extended( //aqui se crea un boton flotante para agregar
              heroTag: 'Sesion_tap',
              onPressed: () {
                _showCreateDialogSesion();
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Sesion')
            ),
          ),
        ]
      ),
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
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataPreg = _formKey.currentState!.value;

                  Preguntas nuevaPregunta = Preguntas(
                    codPregunta: int.parse(dataPreg['noPregunta']), 
                    // tipoRespuesta: dataPreg['tipoRespuesta'],
                    // grupoTema: dataPreg['grupoTema'] ?? 'Sin grupo tema',
                    pregunta: dataPreg['pregunta'] ?? 'Sin pregunta',
                    // idSubPregunta: int.tryParse(dataPreg['idSubPregunta']?.toString() ?? ''),
                    // rango: dataPreg['rango']
                  ); // Para verificar el valor antes de la asignación

                  try{
                    final response = await ApiServicePreguntas('https://10.0.2.2:7190').postPreguntas(nuevaPregunta);

                    if(response.statusCode == 201) {
                      print('La pregunta fue creado con éxito');
                      Navigator.of(context).pop();
                      _refreshPreguntas();
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
                // 'no': questionUpLoad.idPreguntas.toString(),
                // 'tipoRespuesta': questionUpLoad.tipoRespuesta,
                // 'grupoTema': questionUpLoad.grupoTema,
                'pregunta': questionUpLoad.pregunta,
                // 'idSubPregunta': questionUpLoad.idSubPregunta,
                // 'rango': questionUpLoad.rango
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*
                  FormBuilderTextField(
                    name: 'tipoRespuesta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Tipo de Respuesta',
                      labelFrontSize: 30.5,
                      hintext: 'Como se respondera esta pregunta',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
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
                  */
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
                  /*
                  FormBuilderTextField(
                    name: 'idSubPregunta',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'ID de Sub. Pregunta',
                      labelFrontSize: 30.5,
                      hintext: 'Asipnar el id de la sub. pregunta',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),

                  FormBuilderTextField(
                    name: 'rango',
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Identificador de Rango',
                      labelFrontSize: 30.5,
                      hintext: '#',
                      hintFrontSize: 30.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.required(errorText: 'Este campo es requerido')
                  ),
                  */
                ],
              )
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()){
                  final formData = _formKey.currentState!.value;
                  Preguntas askUpLoad = Preguntas(
                    codPregunta: questionUpLoad.codPregunta.toInt(),
                    // tipoRespuesta: formData['tipoRespuesta'],
                    // grupoTema: formData['grupoTema'],
                    pregunta: formData['pregunta'],
                    // idSubPregunta: formData['idSubPregunta'],
                    // rango: formData['rango']
                  );

                  try{
                    final response = await ApiServicePreguntas('https://10.0.2.2:7190')
                      .putPreguntas(questionUpLoad.codPregunta, askUpLoad);

                    if(response.statusCode == 204) {
                      print('La pregunta fue modificada con éxito');
                      Navigator.of(context).pop();
                      _refreshPreguntas();
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin realizar acción
              }, 
              child: const Text('Cancelar', style: TextStyle(fontSize: 30)),
            ),
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()){
                  final dataSebPreg = _formKey.currentState!.value;

                  SubPregunta nuevaSubPregunta = SubPregunta(
                    codSubPregunta: dataSebPreg['codigo'],
                    subPreguntas: dataSebPreg['subPreguntas']
                  );

                  try{
                    final response = await ApiServiceSubPreguntas('https://10.0.2.2:7190').postSubPreg(nuevaSubPregunta);

                    if(response.statusCode == 201) {
                      print('Las sub-Preguntas fue creado con éxito');
                      Navigator.of(context).pop();
                      _refreshSubPreguntas();
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
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
              },
            ),
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
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Respuesta Abierta',
                        child: Text('Respuesta Abierta', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1)))
                      ),
                      DropdownMenuItem(
                        value: 'Selecionar: Si, No, N/A',
                        child: Text('Selecionar: Si, No, N/A', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Calificar del 1 a 10',
                        child: Text('Calificar del 1 a 10', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Solo SI o No',
                        child: Text('Solo SI o No', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Edad',
                        child: Text('Edad', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Nacionalidad',
                        child: Text('Nacionalidad', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Título de transporte',
                        child: Text('Título de transporte', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Producto utilizado',
                        child: Text('Producto utilizado', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Genero',
                        child: Text('Genero', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Frecuencia de viajes por semana',
                        child: Text('Frecuencia de viajes por semana', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Expectativa del pasajero',
                        child: Text('Expectativa del pasajero', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Conclusion',
                        child: Text('Conclusion', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      // DropdownMenuItem(
                      //   value: 'Calificar del 1 a 10',
                      //   child: Text('Calificar del 1 a 10', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      // )
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Determinar el Rango requerido',
                      labelFrontSize: 30.5,
                      hintext: 'Usa el slider para determinar el rango deseado.',
                      hintFrontSize: 20.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.numeric(errorText: 'Este campo es requerido')
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: _rangoValor.toDouble(),
                          min: 0,
                          max: (rangoArray.length - 1).toDouble(),
                          divisions: rangoArray.length - 1,
                          label: rangoArray[_rangoValor].toString(),
                          onChanged: (double valor) {
                            setState(() {
                              _rangoValor = valor.toInt();
                              // Actualiza el valor del controlador con el formato requerido
                              tipoRespuestaController.text = numbersToRango(_rangoValor);
                            });
                          },
                        ),
                      ]
                    ),
                  )
                ] 
              )
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
              },
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  final dataSesion = _formKey.currentState!.value;

                  Sesion nuevaSesion = Sesion(
                    tipoRespuesta: dataSesion['tipoRespuesta'],
                    grupoTema: dataSesion['grupoTema'],
                    codPregunta: int.parse(dataSesion['codPregunta']),
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
                    style: const TextStyle(fontSize: 30.0),
                    validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Respuesta Abierta',
                        child: Text('Respuesta Abierta', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1)))
                      ),
                      DropdownMenuItem(
                        value: 'Selecionar: Si, No, N/A',
                        child: Text('Selecionar: Si, No, N/A', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Calificar del 1 a 10',
                        child: Text('Calificar del 1 a 10', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Solo SI o No',
                        child: Text('Solo SI o No', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Edad',
                        child: Text('Edad', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Nacionalidad',
                        child: Text('Nacionalidad', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Título de transporte',
                        child: Text('Título de transporte', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Producto utilizado',
                        child: Text('Producto utilizado', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Genero',
                        child: Text('Genero', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Frecuencia de viajes por semana',
                        child: Text('Frecuencia de viajes por semana', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Expectativa del pasajero',
                        child: Text('Expectativa del pasajero', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      DropdownMenuItem(
                        value: 'Conclusion',
                        child: Text('Conclusion', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      ),
                      // DropdownMenuItem(
                      //   value: 'Calificar del 1 a 10',
                      //   child: Text('Calificar del 1 a 10', style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 1, 1, 1))),
                      // )
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      labeltext: 'Determinar el Rango requerido',
                      labelFrontSize: 30.5,
                      hintext: 'Usa el slider para determinar el rango deseado.',
                      hintFrontSize: 20.0,
                      icono: const Icon(Icons.numbers,size: 30.0),
                    ),
                    style: const TextStyle(fontSize: 30.0),
                    // validator: FormBuilderValidators.numeric(errorText: 'Este campo es requerido')
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: _rangoValor.toDouble(),
                          min: 0,
                          max: (rangoArray.length - 1).toDouble(),
                          divisions: rangoArray.length - 1,
                          label: rangoArray[_rangoValor].toString(),
                          onChanged: (double valor) {
                            setState(() {
                              _rangoValor = valor.toInt();
                              // Actualiza el valor del controlador con el formato requerido
                              tipoRespuestaController.text = numbersToRango(_rangoValor);
                            });
                          },
                        ),
                      ]
                    ),
                  )
                ],
              )
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo si se cancela
              },
            ),
            TextButton(
              onPressed: () async {
                if(_formKey.currentState!.saveAndValidate()) {
                  final dataSesion = _formKey.currentState!.value;

                  Sesion sesionUpLoad = Sesion(
                    idSesion: sectionUpload.idSesion,
                    tipoRespuesta: selectedTipRespuestas,
                    grupoTema: dataSesion['grupoTema'],
                    codPregunta: int.parse(dataSesion['codPregunta']),
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

// void _showCreateDialogRangoRespuestas() {
//   final tipoRespuestaController = TextEditingController();
//   List<String> selectedValues = [];
//   int _rangoValor = 1;

//   showDialog(
//     context: context, 
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Determinar el Rango requerido', style: TextStyle(fontSize: 33.0)),
//             contentPadding: EdgeInsets.zero,
//             content: FormBuilder(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
                  
//                   FormBuilderTextField(
//                     name: 'rango',
//                     controller: tipoRespuestaController,
//                     decoration: InputDecorations.inputDecoration(
//                       labeltext: 'Rango',
//                       labelFrontSize: 30.5,
//                       hintext: 'Determinar el Rango de la Respuestas',
//                       hintFrontSize: 30.0,
//                       icono: const Icon(Icons.question_answer,size: 30.0),
//                     ),
//                     style: const TextStyle(fontSize: 30.0),
//                     validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 20.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Slider(
//                           value: _rangoValor.toDouble(),
//                           min: 1,
//                           max: 10,
//                           divisions: 10,
//                           label: _rangoValor.toString(),
//                           onChanged: (double valor) {
//                             setState(() {
//                               _rangoValor = valor.toInt();
//                               String valorString = _rangoValor.toString();

//                               // Si el valor no está en la lista, lo añadimos.
//                               if (!selectedValues.contains(valorString)) {
//                                 selectedValues.add(valorString);
//                               } else {
//                                 // Si el valor ya está en la lista y se ha reducido, lo quitamos.
//                                 selectedValues.remove(valorString);
//                               }

//                               // Ordenar la lista de valores seleccionados
//                               selectedValues.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

//                               // Actualizar el campo de texto con los valores concatenados
//                               tipoRespuestaController.text = selectedValues.join(' | ');
//                             });
//                           }
//                         ),
//                       ],
//                     )
//                   )
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Cerrar el diálogo sin realizar acción
//                 }, 
//                 child: const Text('Cancelar', style: TextStyle(fontSize: 30)),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   // Validar el formulario antes de proceder
//                   if (_formKey.currentState!.saveAndValidate()) {
//                     final dataRango = _formKey.currentState!.value;

//                     RangoRespuestas nuevoRango = RangoRespuestas(
//                       // idTipRespuesta: int.tryParse(dataTipResp['idTipRespuesta']) ?? 0,
//                       rango: dataRango['rango']
//                     );

//                     try{
//                       final response = await ApiServiceRangoResp('https://10.0.2.2:7190').postRangoResp(nuevoRango);
//                       if(response.statusCode == 201) {
//                         print('El Tipo de Respuesta fue creado con éxito');
//                         Navigator.of(context).pop(); // Cerrar el diálogo
//                         _refreshTipoRespuestas();
//                       } else {
//                         print('Error al crear Tipo de Respuesta: ${response.body}');
//                       }
//                     } catch (e) {
//                       print('Excepción al crear el tipo de respuesta: $e');
//                     }
//                   }
//                 }, 
//                 child: const Text('Crear', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
//               ),
//             ],
//           );
//         }
//       );
//     }
//   );
// }
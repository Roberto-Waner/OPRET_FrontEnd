import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/Controllers/respuesta_Controller.dart';
import 'package:formulario_opret/Controllers/section_Controller.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:formulario_opret/screens/interfaz_User/navbarUser/navbar_Empl.dart';
import 'package:formulario_opret/services/sesion_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';

class PreguntaEncuestaScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;
  final TextEditingController noEncuestaFiltrar;

  const PreguntaEncuestaScreen({
    super.key,
    required this.noEncuestaFiltrar,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    required this.filtrarId,
    required this.filtrarCedula, 
  });

  @override
  State<PreguntaEncuestaScreen> createState() => _PreguntaEncuestaScreenState();
}

class _PreguntaEncuestaScreenState extends State<PreguntaEncuestaScreen> {
  final ApiServiceSesion2 _apiSesion = ApiServiceSesion2('https://10.0.2.2:7190');
  final SectionController _sectionController = SectionController();
  final RespuestaController _respuestaController = RespuestaController();
  late List<SpPreguntascompleta> dataQuestion = []; //para la llamada de los datos
  late List<SpInsertarRespuestas> dataRespuesta = []; //para para ingresar
  final _formKey = GlobalKey<FormBuilderState>();
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _refreshPreguntas(); //utilizado para cargar los datos al cargar la pagina y se cargan los datos
  }

  void _refreshPreguntas() async {
    try {
      List<SpPreguntascompleta> preguntas = await _sectionController.loadFromApi();
      _respuestaController.syncDataResp();
      setState(() {
        dataQuestion = preguntas;
        _isExpandedList = List.filled(dataQuestion.length, false);
      });
    } catch (e) {
      print('Error al cargar las preguntas: $e');
    }
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
        title: const Text('Preguntas de Encuesta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30.0),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() {
                _refreshPreguntas();
              });
            },
          )
        ],
      ),

      body:Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _apiSesion.getSpPreguntascompletaListada().catchError((e) async {
                print('Error al cargar desde la API, cargando desde SQLite: $e');
                return await _sectionController.loadFromSQLite().timeout(const Duration(seconds: 5));
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error al cargar las preguntas", style: TextStyle(fontSize: 30.0)));
                } else if (dataQuestion.isEmpty) {
                  return const Center(child: Text("No hay preguntas disponibles", style: TextStyle(fontSize: 30.0)));
                } else {
                  // dataQuestion = snapshot.data!;
                  return _buildPreguntaList(); // Construye la lista de preguntas si hay datos
                }
              }
            ),
          ),
        ],
      )
    );
  }

  SingleChildScrollView _buildPreguntaList() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: dataQuestion.length,
                physics: const NeverScrollableScrollPhysics(), // Evita conflictos de desplazamiento
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpandedList[index] = !_isExpandedList[index];
                      });
                    },
                    child: Card(
                      elevation: 5,//para elevar hacia delante los cuadros de la preguntas
                      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ExpandablePanel(
                        header: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Numero de la pregunta: ',
                                  style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                ),
                                TextSpan(
                                  text: '${dataQuestion[index].sp_CodPregunta}',
                                  style: const TextStyle(fontSize: 35.0, color: Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                )
                              ]
                            )
                          ),
                        ),
                        collapsed: Container(), // Puedes añadir contenido para mostrar cuando el panel esté colapsado
                        expanded: Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 50.0, left: 45.0, right: 45.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Respuesta que solo recibe es: \n',
                                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                    ),
                                    TextSpan(
                                      text: ('  ${dataQuestion[index].sp_TipoRespuesta}'),
                                      style: const TextStyle(fontSize: 28.0, color: Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                    )
                                  ]
                                )
                              ),
                              const SizedBox(height: 15),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: '- Pregunta: \n',
                                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                    ),
                                    TextSpan(
                                      text: ('    ${dataQuestion[index].sp_Pregunta}'),
                                      style: const TextStyle(fontSize: 28.0, color: Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                    )
                                  ]
                                )
                              ),
                              const SizedBox(height: 15),
                              if (dataQuestion[index].sp_SubPregunta != null)
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '-- Sub-Pregunta: \n',
                                        style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                      ),
                                      TextSpan(
                                        text: ('    ${dataQuestion[index].sp_SubPregunta}'),
                                        style: const TextStyle(fontSize: 26.0, color: Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                      )
                                    ]
                                  )
                                ),
                              const SizedBox(height: 5),
                              if (dataQuestion[index].sp_Rango != null)
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '- Rango Determinado: \n',
                                        style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                      ),
                                      TextSpan(
                                        text: ('    ${dataQuestion[index].sp_Rango}'),
                                        style: const TextStyle(fontSize: 26.0, color: Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                      )
                                    ]
                                  )
                                ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    _showPreguntaDialog(dataQuestion[index]); // Muestra el diálogo al hacer clic
                                  },
                                  child: const Text('Responder.', style: TextStyle(fontSize: 26.0)),
                                ),
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          )
      ),
    );
  }

  void _showPreguntaDialog(SpPreguntascompleta question) {

    showDialog(
      context: context, 
      builder: (BuildContext context, ) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Pregunta No: ${question.sp_CodPregunta}. ${question.sp_Pregunta}', style: const TextStyle(fontSize: 30.0)),
              content: Container(
                margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),  // Aplica margen
                width: 1500,
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Determina el tipo de respuesta y muestra el widget adecuado segun el tipo Respuesta de la tabla sesion
                      if (question.sp_TipoRespuesta == 'Respuesta Abierta')
                        FormBuilderTextField(
                          name: 'respuesta_Abierta',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Escribe tu respuesta',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.notes, size: 30.0)
                          ),
                          // validator: FormBuilderValidators.compose([
                          //   FormBuilderValidators.required(),
                          // ]),
                        ),
                      
                      if(question.sp_TipoRespuesta == 'Selecionar: Si, No, N/A')
                        FormBuilderDropdown<String>(
                          name: 'respuesta_SiNoNA',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Selecionar: Si, No, N/A',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.check_circle, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Si', child: Text('Si')),
                            DropdownMenuItem(value: 'No', child: Text('No')),
                            DropdownMenuItem(value: 'N/A', child: Text('N/A')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Calificar del 1 a 10')
                        FormBuilderDropdown<String>(
                          name: 'respuesta_Calificacion',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Calific. 1 a 10',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.numbers, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('1')),
                            DropdownMenuItem(value: '2', child: Text('2')),
                            DropdownMenuItem(value: '3', child: Text('3')),
                            DropdownMenuItem(value: '4', child: Text('4')),
                            DropdownMenuItem(value: '5', child: Text('5')),
                            DropdownMenuItem(value: '6', child: Text('6')),
                            DropdownMenuItem(value: '7', child: Text('7')),
                            DropdownMenuItem(value: '8', child: Text('8')),
                            DropdownMenuItem(value: '9', child: Text('9')),
                            DropdownMenuItem(value: '10', child: Text('10')),
                          ],
                          // items: List.generate(10, (index) {
                          //   return DropdownMenuItem(
                          //     value: index + 1,
                          //     child: Text('${index + 1}'),
                          //   );
                          // }),
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Solo SI o No')
                        FormBuilderDropdown(
                          name: 'respuesta_Si-No',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Seleciona solo Si o No',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.check, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Si', child: Text('Si')),
                            DropdownMenuItem(value: 'No', child: Text('No')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Edad')
                        FormBuilderDropdown(
                          name: 'respuesta_Edad',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Edad',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.calendar_month_outlined, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Menor 15', child: Text('Menor 10')),
                            DropdownMenuItem(value: '15 - 20', child: Text('15 - 20')),
                            DropdownMenuItem(value: '21 - 25', child: Text('21 - 25')),
                            DropdownMenuItem(value: '26 - 30', child: Text('26 - 30')),
                            DropdownMenuItem(value: '31 - 35', child: Text('31 - 35')),
                            DropdownMenuItem(value: '36 - 40', child: Text('36 - 40')),
                            DropdownMenuItem(value: '41 - 45', child: Text('41 - 45')),
                            DropdownMenuItem(value: '46 - 50', child: Text('46 - 50')),
                            DropdownMenuItem(value: '51 o Mas', child: Text('51 o Mas')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Nacionalidad')
                        FormBuilderDropdown(
                          name: 'respuesta_Nacionalidad',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Nacionalidad',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.boy_rounded, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'DOMINICANO', child: Text('DOMINICANO')),
                            DropdownMenuItem(value: 'EXTRANJERO RESIDENTE', child: Text('EXTRANJERO RESIDENTE')),
                            DropdownMenuItem(value: 'EXTRANJERO TURISTA', child: Text('EXTRANJERO TURISTA')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Título de transporte')
                        FormBuilderDropdown(
                          name: 'respuesta_Títransporte',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige el Título de transporte',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.credit_card, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'TARJETAR REUSABLE (PLASTICO)', child: Text('TARJETAR REUSABLE (PLASTICO)')),
                            DropdownMenuItem(value: 'TARJETA DESECHABLE (CARTON)', child: Text('TARJETA DESECHABLE (CARTON)'))
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Producto utilizado')
                        FormBuilderDropdown(
                          name: 'respuesta_ProdUtilizado',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige el Producto utilizado',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.monetization_on_outlined, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'MONEDERO', child: Text('MONEDERO')),
                            DropdownMenuItem(value: 'Multi-10', child: Text('Multi-10')),
                            DropdownMenuItem(value: 'Multi-20', child: Text('Multi-20')),
                            DropdownMenuItem(value: 'Viaje-Dia', child: Text('Viaje-Dia')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Genero')
                        FormBuilderDropdown(
                          name: 'respuesta_Genero',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige el Genero',
                            labelFrontSize: 26.0,
                            hintFrontSize: 26.0,
                            icono: const Icon(Icons.wc_rounded, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                            DropdownMenuItem(value: 'Femenino', child: Text('Femenino'))
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Frecuencia de viajes por semana')
                        FormBuilderDropdown(
                          name: 'respuesta_Frecuencia',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Frecuencia de viajes por semana',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.airplanemode_active, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: '0 - 4', child: Text('0 - 4')),
                            DropdownMenuItem(value: '5 - 8', child: Text('5 - 8')),
                            DropdownMenuItem(value: '9 - 12', child: Text('9 - 12')),
                            DropdownMenuItem(value: '13 - 16', child: Text('13 - 16')),
                            DropdownMenuItem(value: '17 o Mas', child: Text('17 o Mas')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Expectativa del pasajero')
                        FormBuilderDropdown(
                          name: 'respuesta_Expectativa',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Expectativa del pasajero',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'NADA', child: Text('NADA')),
                            DropdownMenuItem(value: 'ALGO', child: Text('ALGO')),
                            DropdownMenuItem(value: 'BASTANTE', child: Text('BASTANTE')),
                            DropdownMenuItem(value: 'MUCHO', child: Text('MUCHO')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                
                      if(question.sp_TipoRespuesta == 'Conclusion')
                        FormBuilderTextField(
                          name: 'respuesta_Conclusion',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Escribe la Conclusion (Opcional)',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.notes, size: 30.0)
                          )
                        ),

                      if(question.sp_TipoRespuesta == 'Motivo del viaje')
                        FormBuilderDropdown(
                          name: 'motivo_viaje',
                          style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Cual es el motivo del viaje a metro',
                            labelFrontSize: 20.0,
                            hintFrontSize: 20.0,
                            icono: const Icon(Icons.airplanemode_active, size: 30.0)
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Trabajo', child: Text('Trabajo')),
                            DropdownMenuItem(value: 'Estudio', child: Text('Estudio')),
                            DropdownMenuItem(value: 'Ocio', child: Text('Ocio')),
                            DropdownMenuItem(value: 'Turismo', child: Text('Turismo')),
                            DropdownMenuItem(value: 'Salud', child: Text('Salud')),
                            DropdownMenuItem(value: 'Otros.', child: Text('Otros.')),
                          ],
                          validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                        ),
                      
                      FormBuilderTextField(
                        name: 'comentarios',
                        style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Escribe tu comentarios aqui. (Opcional)',
                          labelFrontSize: 20.0,
                          hintext: ' ',
                          hintFrontSize: 20.0,
                          icono: const Icon(Icons.notes, size: 30.0)
                        ),
                      ),

                      FormBuilderTextField(
                        name: 'justificacion',
                        style: const TextStyle(fontSize: 26, color: Color.fromARGB(255, 1, 1, 1)),
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Justifique su respuesta (Opcional)',
                          labelFrontSize: 20.0,
                          hintext: ' ',
                          hintFrontSize: 20.0,
                          icono: const Icon(Icons.notes, size: 30.0)
                        ),
                      ),
                    ],
                  )
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cerrar", style: TextStyle(fontSize: 25.0)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
                ),

                TextButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final responseForm = _formKey.currentState!.value;
                      _saveRespuesta(question, responseForm, finalizarSesion: 0);
                      Navigator.of(context).pop();
                    }
                  }, 
                  child: const Text('Proxima Pregunta', style: TextStyle(fontSize: 25.0))
                ),

                TextButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final responseForm = _formKey.currentState!.value;
                      _saveRespuesta(question, responseForm, finalizarSesion: 1);
                      _respuestaController.syncDataResp();
                      Navigator.of(context).pop();
                    }
                  }, 
                  child: const Text('Finalizar Pregunta', style: TextStyle(fontSize: 25.0))
                )
              ]
            );
          }
        );
      }
    );
  }

  // Guardar respuesta en la API
  void _saveRespuesta(SpPreguntascompleta question, Map<String, dynamic> responseForm, {int finalizarSesion = 0}) async {
    // Verificamos si el formulario es válido antes de guardar
    if (_formKey.currentState!.saveAndValidate()){
      final dataAnswer = _formKey.currentState!.value;

      // Determinamos el tipo de respuesta ingresada por el usuario
      final String? respuestaFinal = dataAnswer['respuesta_Abierta'] ??
                                      dataAnswer['respuesta_SiNoNA'] ??
                                      dataAnswer['respuesta_Calificacion'] ??
                                      dataAnswer['respuesta_Si-No'] ??
                                      dataAnswer['respuesta_Edad'] ??
                                      dataAnswer['respuesta_Nacionalidad'] ??
                                      dataAnswer['respuesta_Títransporte'] ??
                                      dataAnswer['respuesta_ProdUtilizado'] ??
                                      dataAnswer['respuesta_Genero'] ??
                                      dataAnswer['respuesta_Frecuencia'] ??
                                      dataAnswer['respuesta_Expectativa'] ??
                                      dataAnswer['respuesta_Conclusion'] ??
                                      dataAnswer['motivo_viaje'];

      // Verificamos que exista alguna respuesta válida
      if(respuestaFinal == null || respuestaFinal.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, completa la respuesta.'))
        );
        return;
      }

      // Creamos el objeto `Respuesta` con los datos recopilados
      SpInsertarRespuestas nuevaRespuesta = SpInsertarRespuestas(
        idUsuarios: widget.filtrarId.text, // ID del usuario extraido del token
        idSesion: question.sp_CodPregunta!, //  sp_CodPregunta estraido del modelo SpPreguntascompleta que hace referencia a un stored procedure 
        respuesta: respuestaFinal, // para recibir diferentes tipos de respuestas
        comentarios: dataAnswer['comentarios'],
        justificacion: dataAnswer['justificacion'],
        finalizarSesion: finalizarSesion // recibir la respuesta atravez de un boton con true y false
      );

      // Imprimir los datos a enviar para depuración
      print('Datos de la respuesta: ${nuevaRespuesta.toJson()}');

      try {
        await _respuestaController.saveRespuesta([nuevaRespuesta]);
        // await _apiRespuesta.postRespuesta(nuevaRespuesta);
        print('Respuesta guardada localmente');

        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar(content: Text('Respuesta guardada con éxito')) 
        );
        
      } catch (e) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text('Error: $e, guardada localmente')) 
        ); 
      }
    } else {
      // Si el formulario no es válido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
      );
    }
  }
}
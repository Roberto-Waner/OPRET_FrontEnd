import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/Controllers/respuesta_Controller.dart';
import 'package:formulario_opret/Controllers/section_Controller.dart';
import 'package:formulario_opret/data/respuesta_crud.dart';
import 'package:formulario_opret/data/section_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:formulario_opret/screens/interfaz_User/form_Encuesta_Screen.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'package:intl/intl.dart';

class PreguntaEncuestaScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController noEncuestaFiltrar;

  const PreguntaEncuestaScreen({
    super.key,
    required this.noEncuestaFiltrar,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    required this.filtrarId,
  });

  @override
  State<PreguntaEncuestaScreen> createState() => _PreguntaEncuestaScreenState();
}

class _PreguntaEncuestaScreenState extends State<PreguntaEncuestaScreen> {
  // final ApiServiceSesion2 _apiSesion = ApiServiceSesion2('https://10.0.2.2:7190');
  final RespuestaController _respuestaController = RespuestaController();
  final SectionController _sectionController = SectionController();
  late List<SpPreguntascompleta> dataQuestion = []; //para la llamada de los datos
  late List<SpInsertarRespuestas> dataRespuesta = []; //para para ingresar
  final _formKey = GlobalKey<FormBuilderState>();
  final RespuestaCrud _respuestaCrud = RespuestaCrud();
  final SectionCrud _sectionCrud = SectionCrud();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  late Future<List<SpPreguntascompleta>> _preguntasFuture;

  @override
  void initState() {
    super.initState();
    _preguntasFuture = _refreshPreguntas(); //utilizado para cargar los datos al cargar la pagina y se cargan los datos
    _setInitialValues(); // para que la fecha y la hora se asignen automaticamente de acuerdo a la tabla
  }

  Future<List<SpPreguntascompleta>> _refreshPreguntas() async {
    try {
      await _sectionController.syncData(); // esperando a que se sincronice primero la api con la cache.

      // List<SpPreguntascompleta> preguntas = await _sectionController.loadPreguntasFromCache().timeout(const Duration(seconds: 5));
      List<SpPreguntascompleta> preguntas = await _sectionCrud.querySectionCrud();
      print("Preguntas cargadas: $preguntas");

      setState(() {
        dataQuestion = preguntas;
      });

      // Sincronización en segundo plano
      await _respuestaController.syncDataResp();
      await _respuestaController.syncDataStoredResp();
      return preguntas; // Devuelve la lista de preguntas
    } catch (e) {
      print("⚠️ Error: $e");
      return [];
    }
  }

  void _setInitialValues() {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());

    fechaController.text = currentDate;
    horaController.text = currentTime;
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

    return PopScope(
      canPop: false,
      child: ScreenUtilInit(
        designSize: const Size(360, 740),
        builder: (context, child) => Scaffold(

            appBar: AppBar(
              title: const Text('Preguntas de Encuesta'),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, size: isTabletDevice ? 15.sp : 15.sp),
                  tooltip: 'Recargar',
                  onPressed: () async {
                    // List<SpPreguntascompleta> getNewQuestion = await _refreshPreguntas();
                    setState(() {
                      // _refreshPreguntas();
                      _preguntasFuture = _refreshPreguntas();
                      // dataQuestion = getNewQuestion;
                    });
                  },
                )
              ],
            ),

            body: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<SpPreguntascompleta>>(
                      future: _preguntasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                              child: Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  width: 200,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                      ),

                                      SizedBox(height: 20),
                                      Text(
                                        'Cargando...',
                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          );
                        } else if (snapshot.hasError) {
                          print('Error al cargar los datos: ${snapshot.error}');
                          return const Center(child: Text("Error al cargar las preguntas", style: TextStyle(fontSize: 30.0)));
                        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                          return const Center(child: Text('No hay preguntas disponibles \n\nRecuerde refrescar la pantalla cada vez que \nentres y también cuando finalices las \nrespuestas mientras tengas conexión a "internet"', style: TextStyle(fontSize: 30.0)));
                        } else {
                          return _buildPreguntaList();
                        }
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          _showWarning(context, 'Ten en cuenta que deberás llenar el formulario nuevamente para acceder a esta pantalla.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(1, 135, 76, 1),
                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text('Regresar al formulario.', style: TextStyle(fontSize: isTabletDevice ? 13.sp : 18.sp))
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  Widget _buildPreguntaList() {
    //filtrar las preguntas segun el estado sea igual a true
    // final filteredQuestions = dataQuestion.where((question) => question.sp_Estado == 1).toList();
    final List<SpPreguntascompleta> filteredQuestions = dataQuestion.where((question) => question.sp_Estado == 1).toList();
    print("Preguntas filtradas: ${filteredQuestions.length}");
    final isTabletDevice = isTablet(context);

    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredQuestions.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // final pregunta = filteredQuestions[index];
          final SpPreguntascompleta pregunta = filteredQuestions[index];
          print("Mostrando pregunta: ${pregunta.sp_Pregunta}");
          return GestureDetector(
            onTap: () => _showPreguntaDialog(pregunta), // Abre el diálogo al hacer clic en la tarjeta
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la pregunta
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Número de la pregunta: ',
                            style: TextStyle(fontSize: isTabletDevice ? 12.sp : 15.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                          ),
                          TextSpan(
                            text: '${pregunta.sp_noIdentifEncuesta}',
                            style: TextStyle(fontSize: isTabletDevice ? 12.sp : 15.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                          )
                        ]
                      )
                    ),
                    const SizedBox(height: 8),
      
                    // Descripción breve de la pregunta
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '- Pregunta: ',
                            style: TextStyle(fontSize: isTabletDevice ? 11.sp : 12.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                          ),
                          TextSpan(
                            text: (pregunta.sp_Pregunta),
                            style: TextStyle(fontSize: isTabletDevice ? 11.sp : 12.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                          )
                        ]
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
      
                    // Botón de expansión para más detalles
                    ExpandablePanel(
                      collapsed: Container(), 
                      theme: ExpandableThemeData(
                        expandIcon: Icons.arrow_drop_down_circle_outlined,
                        collapseIcon: Icons.arrow_circle_up_sharp,
                        iconSize: isTabletDevice ? 28 : 30,
                        iconColor: const Color.fromARGB(255, 12, 44, 19),
                      ),
                      header: Text('Más detalles', style: TextStyle(fontSize: isTabletDevice ? 12.25.sp : 15.sp, color: const Color.fromARGB(255, 1, 1, 1))), 
                      expanded: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: 'Respuesta que solo recibe es: ',
                                    style: TextStyle(fontSize: isTabletDevice ? 10.sp : 12.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                  ),
                                  TextSpan(
                                    text: ('${pregunta.sp_TipoRespuesta}'),
                                    style: TextStyle(fontSize: isTabletDevice ? 10.sp : 12.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                  )
                                ]
                              )
                            ),
                          ),

                          if (pregunta.sp_SubPregunta != null)
                            ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Sub-Pregunta: ',
                                      style: TextStyle(fontSize: isTabletDevice ? 10.sp : 12.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                    ),
                                    TextSpan(
                                      text: ('${pregunta.sp_SubPregunta}'),
                                      style: TextStyle(fontSize: isTabletDevice ? 10.sp : 12.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                    )
                                  ]
                                )
                              ),
                            ),
                          
                          if (pregunta.sp_Rango != null)
                            ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Requerimiento: ',
                                      style: TextStyle(fontSize: isTabletDevice ? 10.sp : 12.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                    ),
                                    TextSpan(
                                      text: ('${pregunta.sp_Rango}'),
                                      style: TextStyle(fontSize: isTabletDevice ? 10.sp : 12.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                    )
                                  ]
                                )
                              ),
                            ),
                        ],
                      )
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showPreguntaDialog(SpPreguntascompleta question) async {
    final isTabletDevice = isTablet(context);
    Map<int, SpInsertarRespuestas> stoppedAnswer = {};
    SpInsertarRespuestas? saveResp = stoppedAnswer[question.sp_CodPregunta ?? 0];
    saveResp ??= await _respuestaCrud.getRespuestaById(question.sp_CodPregunta ?? 0);

    // Filtrar preguntas que tienen estado en true
    final filteredQuestions = dataQuestion.where((q) => q.sp_Estado == 1).toList();
    final currentIndex = filteredQuestions.indexOf(question);
    final isFirstQuestion = currentIndex == 0;
    final isLastQuestion = currentIndex == filteredQuestions.length - 1;

    showDialog(
        context: context,
        barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                // Reinicializa 'selectedAnswer' para cada nueva pregunta
                String? selectedAnswer = '';

                return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Título del diálogo
                        Expanded(
                          child: Text(
                            'No: ${question.sp_noIdentifEncuesta}. ${question.sp_Pregunta}',
                            style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp),
                          ),
                        ),
                        const SizedBox(width: 35),
                        // Botón de cierre
                        IconButton(
                            icon: Icon(Icons.close, color: Colors.red, size: isTabletDevice ? 20.sp : 20.sp),
                            onPressed: () => Navigator.of(context).pop()
                        ),
                      ],
                    ),
                    content: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),  // Aplica margen
                      width: isTabletDevice ? 700 : 500,
                      padding: EdgeInsets.zero,
                      child: FormBuilder(
                          key: _formKey,
                          initialValue: {
                            'sub-preguntas': question.sp_SubPregunta,
                            'respuesta_selected': saveResp?.respuesta ?? '',
                            'comentarios': saveResp?.comentarios ?? '',
                            'justificacion': saveResp?.justificacion ?? ''
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (question.sp_SubPregunta != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  child: FormBuilderTextField(
                                    name: 'sub-preguntas',
                                    enabled: false,
                                    style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    decoration: InputDecorations.inputDecoration(
                                      labeltext: 'Perteneciente a la sub-pregunta',
                                      labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                      hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                      icono: const Icon(Icons.question_answer, size: 30.0, color: const Color.fromARGB(255, 168, 163, 170)),
                                      errorSize: isTabletDevice ? 10.sp : 10.sp,
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 20),

                              // Determina el tipo de respuesta y muestra el widget adecuado segun el tipo Respuesta de la tabla sesion
                              if (question.sp_TipoRespuesta == 'Respuesta Abierta')
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 100.0, // Ajusta la altura máxima del contenedor
                                  ),
                                  child: SingleChildScrollView(
                                    child: FormBuilderTextField(
                                      name: 'respuesta_selected',
                                      maxLines: null,
                                      style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                      decoration: InputDecorations.inputDecoration(
                                        labeltext: 'Escribe tu respuesta',
                                        labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                        hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                        icono: const Icon(Icons.notes, size: 30.0, color: const Color.fromARGB(255, 168, 163, 170)),
                                        errorSize: isTabletDevice ? 10.sp : 10.sp,
                                      ),
                                      validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                    ),
                                  ),
                                ),

                              if(question.sp_TipoRespuesta == 'Seleccionar: Si, No, N/A')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Seleccionar: Si, No, N/A',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: const Icon(Icons.check_circle, size: 30.0, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Si', child: Text('Si')),
                                    DropdownMenuItem(value: 'No', child: Text('No')),
                                    DropdownMenuItem(value: 'N/A', child: Text('N/A')),
                                  ],
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                ),

                              if(question.sp_TipoRespuesta == 'Calificar del 1 a 10')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  menuMaxHeight: 200.0, // Altura máxima del cuadro desplegable
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Calific. 1 a 10',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: const Icon(Icons.numbers, size: 30.0, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
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
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                ),

                              if(question.sp_TipoRespuesta == 'Solo SI o No')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Seleciona solo Si o No',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.check, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Si', child: Text('Si')),
                                    DropdownMenuItem(value: 'No', child: Text('No')),
                                  ],
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                  onSaved: (value) {
                                    setState(() {
                                      selectedAnswer = value ?? '';
                                    });
                                  },
                                ),

                              if(question.sp_TipoRespuesta == 'Edad')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  menuMaxHeight: 200.0,
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige la Edad',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.calendar_month_outlined, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Menor 15', child: Text('Menor 15')),
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
                                  name: 'respuesta_selected',
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige la Nacionalidad',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.boy_rounded, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
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
                                  name: 'respuesta_selected',
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige el Título de transporte',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.credit_card, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'TARJETAR REUSABLE (PLASTICO)', child: Text('TARJETAR REUSABLE (PLASTICO)')),
                                    DropdownMenuItem(value: 'TARJETA DESECHABLE (CARTON)', child: Text('TARJETA DESECHABLE (CARTON)'))
                                  ],
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                ),

                              if(question.sp_TipoRespuesta == 'Producto utilizado')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  menuMaxHeight: 200.0,
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige el Producto utilizado',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.monetization_on_outlined, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'MONEDERO', child: Text('MONEDERO')),
                                    DropdownMenuItem(value: 'Multi-10', child: Text('Multi-10')),
                                    DropdownMenuItem(value: 'Multi-20', child: Text('Multi-20')),
                                    DropdownMenuItem(value: 'Viaje-Dia', child: Text('Viaje-Dia')),
                                  ],
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                ),

                              if(question.sp_TipoRespuesta == 'Género')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige el Género',
                                    labelFrontSize: 26.0,
                                    hintFrontSize: 26.0,
                                    icono: Icon(Icons.wc_rounded, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                                    DropdownMenuItem(value: 'Femenino', child: Text('Femenino'))
                                  ],
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                ),

                              if(question.sp_TipoRespuesta == 'Frecuencia de viajes por semana')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  menuMaxHeight: 200.0,
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige la Frecuencia de viajes por semana',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.airplanemode_active, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
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
                                  name: 'respuesta_selected',
                                  menuMaxHeight: 200.0,
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Elige la Expectativa del pasajero',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.timeline, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'NADA', child: Text('NADA')),
                                    DropdownMenuItem(value: 'ALGO', child: Text('ALGO')),
                                    DropdownMenuItem(value: 'BASTANTE', child: Text('BASTANTE')),
                                    DropdownMenuItem(value: 'MUCHO', child: Text('MUCHO')),
                                  ],
                                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                                ),

                              if(question.sp_TipoRespuesta == 'Conclusión')
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 100.0, // Ajusta la altura máxima del contenedor
                                  ),
                                  child: SingleChildScrollView(
                                    child: FormBuilderTextField(
                                      name: 'respuesta_Conclusion',
                                      style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                      decoration: InputDecorations.inputDecoration(
                                          labeltext: 'Escribe la Conclusión (Opcional)',
                                          labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                          hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                          icono: Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170))
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),

                              if(question.sp_TipoRespuesta == 'Motivo del viaje')
                                FormBuilderDropdown(
                                  name: 'respuesta_selected',
                                  menuMaxHeight: 200.0,
                                  style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                  decoration: InputDecorations.inputDecoration(
                                    labeltext: 'Cual es el motivo del viaje a metro',
                                    labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                    hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                    icono: Icon(Icons.airplanemode_active, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170)),
                                    errorSize: isTabletDevice ? 10.sp : 10.sp,
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

                              if (question.sp_Rango == 'Comentarios y Justificación (Opcional)') ...comentarios() + justificacion()
                              else if (question.sp_Rango == 'Requiere Comentarios (Opcional)') ...comentarios()
                              else if (question.sp_Rango == 'Requiere Justificación (Opcional)') ...justificacion(),
                            ],
                          )
                      ),
                    ),
                    actions: <Widget>[
                      //boton para retroceder
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3)
                              )
                            ]
                        ),
                        child: TextButton(
                            onPressed: isFirstQuestion ? null : () {
                              final previousQuestion = dataQuestion[currentIndex - 1];
                              if(!isFirstQuestion){
                                _formKey.currentState?.reset();
                                Navigator.of(context).pop();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showPreguntaDialog(previousQuestion); // Abre el diálogo con la pregunta anterior
                                });
                              }
                            },
                            child: Text("Anterior", style: TextStyle(fontSize: isTabletDevice ? 10.5.sp : 10.5.sp))
                        ),
                      ),

                      //boton para avanzar a la siguiente pregunta
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3)
                              )
                            ]
                        ),
                        child: TextButton(
                            onPressed: isLastQuestion ? null : () {
                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                final responseForm = _formKey.currentState!.value;

                                if(selectedAnswer == 'Si' && question.sp_Rango == 'En caso de responder (Si) finaliza la encuesta') {
                                  _saveRespuesta(question, responseForm, formKey: _formKey, finalizarSesion: 1);

                                  Navigator.of(context).pop();
                                } else {
                                  _saveRespuesta(question, responseForm, formKey: _formKey, finalizarSesion: 0);

                                  // Avanza a la próxima pregunta y actualiza el estado
                                  if (!isLastQuestion){
                                    // Reinicia el estado del formulario antes de cargar la siguiente pregunta
                                    _formKey.currentState?.reset();
                                    Navigator.of(context).pop();
                                    final nextQuestion = dataQuestion[currentIndex + 1];
                                    // Aquí forzamos una recarga del estado global
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _showPreguntaDialog(nextQuestion); // Abre el diálogo con la próxima pregunta
                                    });
                                  }/* else {
                                    // _showSuccessDialog(context, 'Has respondido todas las preguntas.');

                                    // Manejo del caso cuando ya no hay más preguntas
                                    Future.delayed(const Duration(seconds: 2), () {
                                      Navigator.of(context).pop(); // Cerrar el diálogo si no hay más preguntas
                                    });
                                  }*/
                                }
                              }
                            },
                            child: Text('Siguiente', style: TextStyle(fontSize: isTabletDevice ? 10.5.sp : 10.5.sp))
                        ),
                      ),

                      //boton para finalizar la pregunta
                      Container(
                        padding: isTabletDevice ? const EdgeInsets.symmetric(vertical: 1, horizontal: 4) : const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3)
                              )
                            ]
                        ),
                        child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                final responseForm = _formKey.currentState!.value;
                                _showContinue(
                                    context,
                                    '¿Estás seguro de querer finalizar la encuesta?\n\nTen en cuenta que no podrás modificar las respuestas.',
                                        () {
                                      _saveRespuesta(question, responseForm, formKey: _formKey, finalizarSesion: 1);
                                      // _respuestaController.syncDataResp();
                                      Navigator.of(context).pop();
                                    }
                                );
                              }
                            },
                            child: Text('Finalizar Encuesta', style: TextStyle(fontSize: isTabletDevice ? 10.5.sp : 10.5.sp))
                        ),
                      )
                    ]
                );
              }
          );
        }
    );
  }

  /*
    Cuando vuelva aparecer el error de abuso del formkey
    (Duplicate GlobalKey detected in widget tree), se debe de integra un GlobalKey independiente
    para cada metodo o sino usar un GlobalKey global y utilizarlo como algumento para los metodo
    en lo que se usan para enviar datos odviamente se le debe de aplicar como parametro en el metodo
    por ejemplo (_saveRespuesta)
  */

  // Guardar respuesta en la cache y API
  void _saveRespuesta(
      SpPreguntascompleta question,
      Map<String, dynamic> responseForm,
      {
        required GlobalKey<FormBuilderState> formKey, // Recibe un GlobalKey único como parámetro
        int finalizarSesion = 0
      }) async {
    String currentDate = fechaController.text;
    String currentTime = horaController.text;

    // Verificamos si el formulario es válido antes de guardar
    if (formKey.currentState!.saveAndValidate()){
      final dataAnswer = formKey.currentState!.value;

      // Determinamos el tipo de respuesta ingresada por el usuario
      final String? respuestaFinal = dataAnswer['respuesta_selected'];

      // Verificamos que exista alguna respuesta válida
      if(respuestaFinal == null || respuestaFinal.isEmpty) {
        _showErrorDialog(context, 'Por favor, completa la respuesta.');
        return;
      }

      // Creamos el objeto `Respuesta` con los datos recopilados
      SpInsertarRespuestas nuevaRespuesta = SpInsertarRespuestas(
        idUsuarios: widget.filtrarId.text, // ID del usuario extraido del token
        idSesion: question.sp_CodPregunta!, //  sp_CodPregunta estraido del modelo SpPreguntascompleta que hace referencia a un stored procedure
        respuesta: respuestaFinal, // para recibir diferentes tipos de respuestas
        comentarios: dataAnswer['comentarios'],
        justificacion: dataAnswer['justificacion'],
        horaResp: currentTime,
        fechaResp: currentDate,
        finalizarSesion: finalizarSesion // recibir la respuesta atravez de un boton con 1 = true y 0 = false
      );

      // Imprimir los datos a enviar para depuración
      print('Datos de la respuesta: ${nuevaRespuesta.toJson()}');

      try {
        final respuestaExistente = await _respuestaCrud.getRespuestaById(question.sp_CodPregunta ?? 0); // pendiente
        print('Respuesta existente: $respuestaExistente');

        if (respuestaExistente != null) {
          nuevaRespuesta.idSesion = respuestaExistente.idSesion;
          await _respuestaCrud.updateRespuesta(nuevaRespuesta);
          print('Respuesta actualizada: ${nuevaRespuesta.toJson()}');

        } else {
          await _respuestaCrud.insertRespuestas([nuevaRespuesta]);
          print('Respuesta insertada: ${nuevaRespuesta.toJson()}');
        }

        // await _respuestaCrud.insertRespuestas([nuevaRespuesta]);
        print('Respuesta guardada localmente');

        if(finalizarSesion == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Respuesta guardada con éxito'))
          );
          // await _respuestaCrud.resetPermissionToEdict();
        } else {
          // await _respuestaCrud.permissionToEdict();
          await _respuestaController.syncDataResp();
          _showSuccessDialog(context, 'Respuesta guardada con éxito y Fin de la Encuesta.');
          await _respuestaController.syncDataStoredResp();
        }

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

  void _showErrorDialog (BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
    showDialog(
        context: context,
        builder: (context) {
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
                        const Icon(Icons.error_outline_sharp, color: Color.fromARGB(255, 181, 3, 3), size: 80.0),
                        const SizedBox(height: 20),
                        const Text(
                          'Error!',
                          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          message,
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        Flex(
                          direction: isTabletDevice ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {Navigator.of(context).pop();},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text('Ok', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                            )
                          ],
                        )
                      ]
                  )
              )
          );
        }
    );
  }

  void _showWarning (BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
    showDialog(
        context: context,
        builder: (context) {
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
                        const Icon(Icons.warning_rounded, color: Color.fromARGB(255, 255, 196, 1), size: 60.0),
                        const SizedBox(height: 20),
                        const Text(
                          'Advertencia!',
                          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          message,
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        Flex(
                          direction: isTabletDevice ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text('Cancelar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                            ),

                            const SizedBox(height: 10.0, width: 10.0),

                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => FormEncuestaScreen(
                                      filtrarUsuarioController: widget.filtrarUsuarioController,
                                      filtrarEmailController: widget.filtrarEmailController,
                                      filtrarId: widget.filtrarId,
                                      // // filtrarCedula: widget.filtrarCedula,
                                    )),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text('Continuar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 184, 135, 0)))
                            ),
                          ],
                        )
                      ]
                  )
              )
          );
        }
    );
  }

  // cuadro de acceso exito
  void _showSuccessDialog(BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text('Continuar', style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: Colors.blue)),
                            ),

                          ],
                        )
                      ]
                  )
              )
          );
        }
    );
  }

  void _showContinue (BuildContext context, String message, Function onConfirm) {
    final isTabletDevice = isTablet(context);
    showDialog(
        context: context,
        builder: (context) {
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
                        const Icon(Icons.send_to_mobile_outlined, color: Color.fromARGB(
                            255, 165, 0, 220), size: 70.0),
                        const SizedBox(height: 20),
                        const Text(
                          'Finalizar Encuesta y Enviar',
                          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          message,
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        Flex(
                          direction: isTabletDevice ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {Navigator.of(context).pop();},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text('Cancelar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                            ),

                            const SizedBox(height: 10.0, width: 10.0),

                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onConfirm();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text('Continuar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 184, 135, 0)))
                            ),
                          ],
                        )
                      ]
                  )
              )
          );
        }
    );
  }

  List<Widget> comentarios() {
    final isTabletDevice = isTablet(context);
    return [
      Container(
        constraints: const BoxConstraints(
          maxHeight: 100.0, // Ajusta la altura máxima del contenedor
        ),
        child: SingleChildScrollView(
          child: FormBuilderTextField(
            name: 'comentarios',
            style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
            decoration: InputDecorations.inputDecoration(
                labeltext: 'Agregar comentarios (Opcional)',
                labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                hintext: ' ',
                hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                icono: Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170))
            ),
            maxLines: null,
          ),
        ),
      )
    ];
  }

  List<Widget> justificacion() {
    final isTabletDevice = isTablet(context);
    return [
      Container(
        constraints: const BoxConstraints(
          maxHeight: 100.0, // Ajusta la altura máxima del contenedor
        ),
        child: SingleChildScrollView(
          child: FormBuilderTextField(
            name: 'justificacion',
            style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
            decoration: InputDecorations.inputDecoration(
                labeltext: 'Justifique su respuesta (Opcional)',
                labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                hintext: ' ',
                hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                icono: Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 168, 163, 170))
            ),
            maxLines: null,
          ),
        ),
      )
    ];
  }
}
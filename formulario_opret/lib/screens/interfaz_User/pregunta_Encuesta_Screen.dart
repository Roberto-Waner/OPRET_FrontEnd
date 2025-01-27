import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/Controllers/respuesta_Controller.dart';
import 'package:formulario_opret/Controllers/section_Controller.dart';
import 'package:formulario_opret/data/respuesta_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:formulario_opret/screens/interfaz_User/form_Encuesta_Screen.dart';
import 'package:formulario_opret/services/sesion_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';

class PreguntaEncuestaScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  // final TextEditingController filtrarCedula;
  final TextEditingController noEncuestaFiltrar;

  const PreguntaEncuestaScreen({
    super.key,
    required this.noEncuestaFiltrar,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    required this.filtrarId,
    // required this.filtrarCedula, 
  });

  @override
  State<PreguntaEncuestaScreen> createState() => _PreguntaEncuestaScreenState();
}

class _PreguntaEncuestaScreenState extends State<PreguntaEncuestaScreen> {
  final ApiServiceSesion2 _apiSesion = ApiServiceSesion2('http://wepapi.somee.com');
  final SectionController _sectionController = SectionController();
  final RespuestaController _respuestaController = RespuestaController();
  late List<SpPreguntascompleta> dataQuestion = []; //para la llamada de los datos
  late List<SpInsertarRespuestas> dataRespuesta = []; //para para ingresar
  final _formKey = GlobalKey<FormBuilderState>();
  List<bool> _isExpandedList = [];
  final RespuestaCrud _respuestaCrud = RespuestaCrud();

  @override
  void initState() {
    super.initState();
    _refreshPreguntas(); //utilizado para cargar los datos al cargar la pagina y se cargan los datos
  }

  void _refreshPreguntas() async {
    try {
      List<SpPreguntascompleta> preguntas = await _sectionController.loadFromApi();

      // Filtrar solo las preguntas con estado verdadero
      preguntas = preguntas.where((pregunta) => pregunta.sp_Estado == true).toList();

      _respuestaController.syncDataResp();
      setState(() {
        dataQuestion = preguntas;
        _isExpandedList = List.filled(dataQuestion.length, false);
      });
    } catch (e) {
      print('Error al cargar las preguntas: $e');
    }
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
      canPop: true,
      child: ScreenUtilInit(
        designSize: const Size(360, 740),
        builder: (context, child) => Scaffold(
          // drawer: NavbarEmpl(
          //   filtrarUsuarioController: widget.filtrarUsuarioController,
          //   filtrarEmailController: widget.filtrarEmailController,
          //   filtrarId: widget.filtrarId,
          //   // // filtrarCedula: widget.filtrarCedula,
          // ),

          appBar: AppBar(
            title: const Text('Preguntas de Encuesta'),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, size: isTabletDevice ? 15.sp : 15.sp),
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
                      return Center(
                        // child: CircularProgressIndicator()
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
                    } else if (dataQuestion.isEmpty) {
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   _showErrorDialog(context, "Los sentimos en estos momentos no hay Preguntas de Encuestas disponibles por ahora.");
                      // });
                      return const Center(child: Text("No hay preguntas disponibles", style: TextStyle(fontSize: 30.0)));
                    } else {
                      // dataQuestion = snapshot.data!;
                      return _buildPreguntaList(); // Construye la lista de preguntas si hay datos
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => FormEncuestaScreen(
                      //     filtrarUsuarioController: widget.filtrarUsuarioController,
                      //     filtrarEmailController: widget.filtrarEmailController,
                      //     filtrarId: widget.filtrarId,
                      //     // // filtrarCedula: widget.filtrarCedula,
                      //   )),
                      // );
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
    final filteredQuestions = dataQuestion.where((question) => question.sp_Estado == true).toList();
    final isTabletDevice = isTablet(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredQuestions.length,
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
                      theme: ExpandableThemeData(
                        expandIcon: Icons.arrow_drop_down_circle_outlined, // Ícono para expandir
                        collapseIcon: Icons.arrow_circle_up_sharp, // Ícono para colapsar
                        iconSize: isTabletDevice ? 50 : 45.0, // Tamaño del ícono predeterminado
                        iconColor: const Color.fromARGB(255, 12, 44, 19), // Cambia el color si lo deseas
                      ),
                      header: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Número de la pregunta: ',
                                style: TextStyle(fontSize: isTabletDevice ? 15.sp : 18.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                              ),
                              TextSpan(
                                text: '${filteredQuestions[index].sp_noIdentifEncuesta}',
                                style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
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
                                  TextSpan(
                                    text: 'Respuesta que solo recibe es: \n',
                                    style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                  ),
                                  TextSpan(
                                    text: ('  ${filteredQuestions[index].sp_TipoRespuesta}'),
                                    style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                  )
                                ]
                              )
                            ),
                            const SizedBox(height: 15),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '- Pregunta: \n',
                                    style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                  ),
                                  TextSpan(
                                    text: ('    ${filteredQuestions[index].sp_Pregunta}'),
                                    style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                  )
                                ]
                              )
                            ),
                            const SizedBox(height: 15),
                            if (filteredQuestions[index].sp_SubPregunta != null)
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '-- Sub-Pregunta: \n',
                                      style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                    ),
                                    TextSpan(
                                      text: ('    ${filteredQuestions[index].sp_SubPregunta}'),
                                      style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                    )
                                  ]
                                )
                              ),
                            const SizedBox(height: 5),
                            if (filteredQuestions[index].sp_Rango != null)
                              RichText(
                                  text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '--- Requerimiento: \n',
                                          style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo en negrita
                                        ),
                                        TextSpan(
                                          text: ('    ${filteredQuestions[index].sp_Rango}'),
                                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)), // Estilo normal
                                        )
                                      ]
                                  )
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _showPreguntaDialog(filteredQuestions[index]); // Muestra el diálogo al hacer clic
                                },
                                child: Text('Responder.', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 17.sp))
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
    final isTabletDevice = isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (BuildContext context, ) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Filtrar preguntas que tienen estado en true
            final filteredQuestions = dataQuestion.where((q) => q.sp_Estado == true).toList();

            final currentIndex = filteredQuestions.indexOf(question);
            final isLastQuestion = currentIndex == filteredQuestions.length - 1;
            
            // Reinicializa 'selectedAnswer' para cada nueva pregunta
            String? selectedAnswer = '';

            return AlertDialog(
              title: Text('No: ${question.sp_noIdentifEncuesta}. ${question.sp_Pregunta}', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp)),
              content: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),  // Aplica margen
                // width: 1500,
                padding: EdgeInsets.zero,
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    'requerimientos': question.sp_Rango
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

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
                              style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                              decoration: InputDecorations.inputDecoration(
                                labeltext: 'Escribe tu respuesta',
                                labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                icono: const Icon(Icons.notes, size: 30.0),
                                errorSize: isTabletDevice ? 10.sp : 10.sp,
                              ),
                              validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                            ),
                          ),
                        ),
                      
                      if(question.sp_TipoRespuesta == 'Seleccionar: Si, No, N/A')
                        FormBuilderDropdown(
                          name: 'respuesta_selected',
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Seleccionar: Si, No, N/A',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: const Icon(Icons.check_circle, size: 30.0),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Calific. 1 a 10',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: const Icon(Icons.numbers, size: 30.0),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Seleciona solo Si o No',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.check, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Edad',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.calendar_month_outlined, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Nacionalidad',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.boy_rounded, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige el Título de transporte',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.credit_card, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige el Producto utilizado',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.monetization_on_outlined, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige el Género',
                            labelFrontSize: 26.0,
                            hintFrontSize: 26.0,
                            icono: Icon(Icons.wc_rounded, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Frecuencia de viajes por semana',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.airplanemode_active, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Elige la Expectativa del pasajero',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                              icono: Icon(Icons.timeline, size: isTabletDevice ? 15.sp : 15.sp),
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
                              style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                              decoration: InputDecorations.inputDecoration(
                                labeltext: 'Escribe la Conclusión (Opcional)',
                                labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                                hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                                icono: Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp)
                              ),
                              maxLines: null,
                            ),
                          ),
                        ),

                      if(question.sp_TipoRespuesta == 'Motivo del viaje')
                        FormBuilderDropdown(
                          name: 'respuesta_selected',
                          menuMaxHeight: 200.0,
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Cual es el motivo del viaje a metro',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.airplanemode_active, size: isTabletDevice ? 15.sp : 15.sp),
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

                      /*
                      if(question.sp_Rango == 'En caso de responder (Si) finaliza la encuesta' ||
                          question.sp_Rango == 'Requiere Justificación (Opcional)' ||
                          question.sp_Rango == 'Requiere Comentarios (Opcional)' ||
                          question.sp_Rango == 'Comentarios y Justificación (Opcional)')
                        FormBuilderTextField(
                          name: 'requerimientos',
                          enabled: false,
                          maxLines: null, // Esto permite que el campo se expanda a medida que se ingresa texto
                          style: const TextStyle(fontSize: 26/*, color: Color.fromARGB(255, 1, 1, 1)*/),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: '${question.sp_Rango}',
                            labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
                            icono: const Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp),
                          ),
                        ),
                      */
                    ],
                  )
                ),
              ),
              actions: <Widget>[
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
                    child: Text("Cerrar", style: TextStyle(fontSize: isTabletDevice ? 10.5.sp : 10.5.sp)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                  ),
                ),

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
                  
                            Navigator.of(context).pop(); // Cierra el diálogo actual
                  
                            final nextQuestion = dataQuestion[currentIndex + 1];
                            // Aquí forzamos una recarga del estado global
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showPreguntaDialog(nextQuestion); // Abre el diálogo con la próxima pregunta
                            });
                          } else {
                            // Manejo del caso cuando ya no hay más preguntas
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.of(context).pop(); // Cerrar el diálogo si no hay más preguntas
                            });
                  
                            _showSuccessDialog(context, 'Has respondido todas las preguntas.');
                          }
                        }
                      }
                    },
                    child: Text('Proxima Pregunta', style: TextStyle(fontSize: isTabletDevice ? 10.5.sp : 10.5.sp))
                  ),
                ),

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
                        _saveRespuesta(question, responseForm, formKey: _formKey, finalizarSesion: 1);
                        _respuestaController.syncDataResp();
                        Navigator.of(context).pop();
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
        finalizarSesion: finalizarSesion // recibir la respuesta atravez de un boton con 1 = true y 0 = false
      );

      // Imprimir los datos a enviar para depuración
      print('Datos de la respuesta: ${nuevaRespuesta.toJson()}');

      try {
        // await _respuestaController.saveRespuesta([nuevaRespuesta]);
        // saveRespuesta_Directa([nuevaRespuesta], finalizarSesion);
        await _respuestaCrud.insertRespuestas([nuevaRespuesta]);

        // await _apiRespuesta.postRespuesta(nuevaRespuesta);
        print('Respuesta guardada localmente');

        if(finalizarSesion == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Respuesta guardada con éxito'))
          );
        } else {
          _showSuccessDialog(context, 'Respuesta guardada con éxito y Fin de la Encuesta.');
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
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
            style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
            decoration: InputDecorations.inputDecoration(
              labeltext: 'Agregar comentarios (Opcional)',
              labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
              hintext: ' ',
              hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
              icono: Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp)
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
            style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: const Color.fromARGB(255, 1, 1, 1)),
            decoration: InputDecorations.inputDecoration(
              labeltext: 'Justifique su respuesta (Opcional)',
              labelFrontSize: isTabletDevice ? 13.sp : 13.sp,
              hintext: ' ',
              hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
              icono: Icon(Icons.notes, size: isTabletDevice ? 15.sp : 15.sp)
            ),
            maxLines: null,
          ),
        ),
      )
    ];
  }
}
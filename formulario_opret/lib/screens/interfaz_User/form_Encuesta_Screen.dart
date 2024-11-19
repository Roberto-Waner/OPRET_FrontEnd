import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_ObtenerEstacionPorLinea.dart';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:formulario_opret/screens/interfaz_User/navbarUser/navbar_Empl.dart';
import 'package:formulario_opret/screens/interfaz_User/pregunta_Encuesta_Screen.dart';
import 'package:formulario_opret/services/estacion_services.dart';
import 'package:formulario_opret/services/form_Registro_services.dart';
import 'package:formulario_opret/services/linea_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'package:intl/intl.dart';

class FormEncuestaScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const FormEncuestaScreen({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController
  });

  @override
  State<FormEncuestaScreen> createState() => _FormEncuestaScreenState();
}

class _FormEncuestaScreenState extends State<FormEncuestaScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiServiceFormRegistro _apiServiceFormRegistro = ApiServiceFormRegistro('https://10.0.2.2:7190');
  final ApiServiceLineas _apiServiceLineas = ApiServiceLineas('https://10.0.2.2:7190');
  final ApiServiceEstacion _apiServiceEstacion = ApiServiceEstacion('https://10.0.2.2:7190');
  // final TextEditingController timePicker = TextEditingController();
  // final TextEditingController datePicker = TextEditingController();
  final TextEditingController noEncuestaFiltrar = TextEditingController();
  String? _selectLineMetro; // Línea seleccionada
  int? _selectedStation; // Estación seleccionada
  String year = DateFormat('yyyy').format(DateTime.now()); // Obtener el año actual en el momento del registro

  List<Linea> _lineas = [];
  List<EstacionPorLinea> _estaciones = [];

  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  void initState() {
    super.initState();
    _fetchData();
    _setInitialValues();
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

  Future<void> _fetchEstaciones(String idLinea) async {
    try {
      List<EstacionPorLinea> estaciones = await _apiServiceEstacion.getEstacionesPorLinea(idLinea);
      setState(() {
        _estaciones = estaciones;
      });
    } catch (e) {
      print('Error fetching estaciones: $e');
    }
  }

  void _setInitialValues() {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String currentTime = DateFormat('hh:mm a').format(DateTime.now());

    fechaController.text = currentDate;
    horaController.text = currentTime;
  }

  //método se utiliza para filtrar una lista de objetos Estacion basándose en el idLinea seleccionado. 
  // List<EstacionPorLinea> _filtrarEstaciones(String? idLinea) {
  //   if (idLinea == null) return [];
  //   return _estaciones.where((e) => e.nombreLinea == idLinea).toList();
  // }

  // Future<void> _showDatePicker() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(), 
  //     firstDate: DateTime(2024, 9, 1), 
  //     lastDate: DateTime.now(),
  //     builder: (BuildContext content, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           colorScheme: const ColorScheme.light(primary: Colors.green),
  //           buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child!,
  //       );
  //     }
  //   );

  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //       datePicker.text = DateFormat("yyyy-MM-dd").format(_selectedDate!); // Formatea la fecha seleccionada
  //     });
  //   }
  // }

  void _registrarFormEncuesta() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final data = _formKey.currentState!.value;

      String currentDate = fechaController.text;
      String currentTime = horaController.text;

      FormularioRegistro formEncuesta = FormularioRegistro(
        idUsuarios: data['idUsuarios'],
        cedula: data['cedula'],
        fecha: currentDate,
        hora: currentTime,
        idEstacion: _selectedStation,
        idLinea: _selectLineMetro
      );

      // Imprimir los datos a enviar para depuración
      print('Datos del formulario: ${formEncuesta.toJson()}');

      try{
        final response = await _apiServiceFormRegistro.postFormRegistro(formEncuesta);

        // Imprimir la respuesta completa para depuración
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if(response.statusCode == 201){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulario enviado con exito'))
          );

          Navigator.pushReplacement( //para evitar que regrese a la pantalla anterior
            context,
            MaterialPageRoute(
              builder: (context) => PreguntaEncuestaScreen(
                noEncuestaFiltrar: noEncuestaFiltrar, //para filtrarlo a la pantalla de "PreguntaEncuestaScreen"
                filtrarUsuarioController: widget.filtrarUsuarioController,  
                filtrarEmailController: widget.filtrarEmailController,
                filtrarId: widget.filtrarId,
                filtrarCedula: widget.filtrarCedula,
              )
            ),
          );

        } else {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar formulario: ${response.reasonPhrase}')),
          );
        }

      } catch (e) {
        print('Error al enviar formulario: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar formulario: ${e.toString()}')),
        );
      }
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

      appBar: AppBar(title: const Text('Formulario')),

      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: FormBuilderTextField(
              //         name: 'noEncuesta',
              //         controller: noEncuestaFiltrar,
              //         decoration: InputDecorations.inputDecoration(
              //           hintext: '#',
              //           hintFrontSize: 25.0,
              //           labeltext: 'No. de Encuesta',
              //           labelFrontSize: 30.5,
              //           prefixText: '$year - ',
              //           icono: const Icon(Icons.numbers, size: 30.0)
              //         ),
              //         style: const TextStyle(fontSize: 30.0), // Cambiar tamaño de letra del texto filtrado
              //         validator: FormBuilderValidators.required(),
              //         onChanged: (val) {
              //           // noEncuestaFiltrar.text = '$year - $val';
              //           noEncuestaFiltrar.selection = TextSelection.fromPosition(TextPosition(offset: noEncuestaFiltrar.text.length));
              //           print('Numero seleccionada: $val');
              //         },
              //       ),
              //     )
              //   ]
              // ),

              FormBuilderTextField(
                name: 'idUsuarios',
                initialValue: widget.filtrarId.text,
                enabled: false,
                decoration: InputDecorations.inputDecoration(
                  labeltext: 'Asignar ID',
                  labelFrontSize: 25.5, // Tamaño de letra personalizado
                  hintext: 'USER-000000000',
                  hintFrontSize: 20.0,
                  icono: const Icon(Icons.perm_identity_outlined,size: 30.0),
                ),
                style: const TextStyle(fontSize: 30.0),
                // validator: FormBuilderValidators.required(),
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'Por favor ingrese su ID-Empleado';
                  }

                  if (!RegExp(r'^USER-\d{4,10}$').hasMatch(value)){
                    return 'Por favor ingrese un ID-Empleado valido';
                  }

                  return null;
                },
                onChanged: (val) {
                  print('Id seleccionada: $val');
                },
              ),

              FormBuilderTextField(
                name: 'cedula',
                initialValue: widget.filtrarCedula.text,
                enabled: false,
                decoration: InputDecorations.inputDecoration(
                  labeltext: 'Cedula',
                  labelFrontSize: 25.5,
                  hintext: '000-0000000-0',
                  hintFrontSize: 20.0, 
                  icono: const Icon(Icons.person_pin_circle_outlined, size: 30.0),
                ),
                style: const TextStyle(fontSize: 30.0),
                // validator: FormBuilderValidators.required(),
                validator: FormBuilderValidators.compose([ //Combina varios validadores. En este caso, se utiliza el validador requerido y una función personalizada para la expresión regular.
                  FormBuilderValidators.required(errorText: 'Debe de ingresar la cedula'), //Valida que el campo no esté vacío y muestra el mensaje 'El correo es obligatorio' si no se ingresa ningún valor.
                  (value) {
                    // Expresión regular para validar la cedula
                    String pattern = r'^\d{3}-\d{7}-\d{1}$';
                    RegExp regExp = RegExp(pattern);
                    // if(value == null || value.isEmpty){
                    //   return 'Por favor ingrese su cédula';
                    // }

                    if(!regExp.hasMatch(value ?? '')){
                      return 'Formato de cédula incorrecto';
                    }
                    return null;
                  },
                ]),
                onChanged: (val) {
                  print('Cedula seleccionada: $val');
                },                 
              ),

              FormBuilderTextField(
                name: 'hora',
                controller: horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora de Encuesta',
                  labelStyle: TextStyle(fontSize: 25.0),
                  prefixIcon: Icon(Icons.access_time, size: 30.0)
                ),
                style: const TextStyle(fontSize: 30.0),
                enabled: false,
              ),

              FormBuilderTextField(
                name: 'fechaEncuesta',
                controller: fechaController,
                decoration: const InputDecoration(
                  // hintext: 'Hora actual',
                  // hintFrontSize: 20.0,
                  labelText: 'Fecha de Encuesta',
                  labelStyle: TextStyle(fontSize: 25.0),
                  prefixIcon: Icon(Icons.calendar_month_outlined, size: 30.0)
                ),
                style: const TextStyle(fontSize: 30.0),
                enabled: false
              ),
              
              FormBuilderDropdown<String>(
                name: 'linea_metro',
                validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                decoration: InputDecorations.inputDecoration(
                  labeltext: 'Linea del metro',
                  labelFrontSize: 30.0,
                  hintext: 'Linea 1, 2 ... o Teleferico',
                  hintFrontSize: 22.0,
                  icono: const Icon(Icons.people_outline_rounded, size: 30.0),
                ),
                initialValue: _selectLineMetro,
                items: _lineas.map((linea) {
                  return DropdownMenuItem(
                    value: linea.idLinea,
                    child: Text(linea.nombreLinea, style: const TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1))),
                  );
                }).toList(),
                style: const TextStyle(fontSize: 30.0),
                onChanged: (value) async {
                  setState(() {
                    _selectLineMetro = value;
                    _selectedStation = null; // Reiniciar estación seleccionada al cambiar de línea
                    print('Línea seleccionada: $_selectLineMetro'); // Depuración
                  });

                  if (value != null) {
                    await _fetchEstaciones(value);
                  }
                },
              ),
              // if (_selectLineMetro != null)
                FormBuilderDropdown<int>(
                  name: 'estacion_metro',
                  style: const TextStyle(fontSize: 30.0),
                  validator: FormBuilderValidators.required(errorText: 'Este campo es requerido'),
                  decoration: InputDecorations.inputDecoration(
                    labeltext: 'Estacion del metro - $_selectLineMetro',
                    labelFrontSize: 30.0,
                    hintext: '',
                    icono: const Icon(Icons.train_outlined, size: 30.0),
                  ),
                  items: _estaciones.map((estacion) {
                    return DropdownMenuItem(
                      value: estacion.idEstacion,
                      child: Text(estacion.nombreEstacion, style: const TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1))),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStation = value;
                      print('Estación seleccionada: $_selectedStation'); // Depuración
                    });
                  },
                ),

              ElevatedButton(
                onPressed: _registrarFormEncuesta, 
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(1, 135, 76, 1), //  se usa para definir el color de fondo del botón.
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), // se usa para definir el color del texto y los iconos dentro del botón.
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),

                child: const Text(
                  'Iniciar Encuesta',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
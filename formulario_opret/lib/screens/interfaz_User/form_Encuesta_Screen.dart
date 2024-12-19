import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  // final TextEditingController filtrarCedula;

  const FormEncuestaScreen({
    super.key,
    required this.filtrarId,
    // required this.filtrarCedula,
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
  final TextEditingController noEncuestaFiltrar = TextEditingController();
  String? _selectLineMetro; // Línea seleccionada
  int? _selectedStation; // Estación seleccionada
  String year = DateFormat('yyyy').format(DateTime.now()); // Obtener el año actual en el momento del registro

  List<Linea> _lineas = [];
  List<EstacionPorLinea> _estaciones = [];

  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  bool isLoading = false; // Variable de control para el cuadro de carga
  bool hasError = false;

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

  void _registrarFormEncuesta() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final data = _formKey.currentState!.value;
      String currentDate = fechaController.text;
      String currentTime = horaController.text;

      setState(() {
        isLoading = true; // Mostrar el cuadro de carga
        hasError = false;
      });

      FormularioRegistro formEncuesta = FormularioRegistro(
        idUsuarios: data['idUsuarios'],
        // cedula: data['cedula'],
        fecha: currentDate,
        hora: currentTime,
        idEstacion: _selectedStation,
        idLinea: _selectLineMetro
      );

      // Imprimir los datos a enviar para depuración
      print('Datos del formulario: ${formEncuesta.toJson()}');

      try{
        final response = await _apiServiceFormRegistro.postFormRegistro(formEncuesta);

        setState(() {
          isLoading = false; // Ocultar el cuadro de carga
          hasError = true;
        });

        // Imprimir la respuesta completa para depuración
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if(response.statusCode == 201){
          _showSuccessDialog(context);

          Navigator.pushReplacement( //para evitar que regrese a la pantalla anterior
            context,
            MaterialPageRoute(
              builder: (context) => PreguntaEncuestaScreen(
                noEncuestaFiltrar: noEncuestaFiltrar, //para filtrarlo a la pantalla de "PreguntaEncuestaScreen"
                filtrarUsuarioController: widget.filtrarUsuarioController,  
                filtrarEmailController: widget.filtrarEmailController,
                filtrarId: widget.filtrarId,
                // // filtrarCedula: widget.filtrarCedula,
              )
            ),
          );

        } else {
          setState(() {
            isLoading = false; // Ocultar el cuadro de carga
            hasError = true;
          });

          _showErrorDialog(context, 'Error al enviar formulario: ${response.reasonPhrase}');
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
        // // filtrarCedula: widget.filtrarCedula,
      ),

      appBar: AppBar(title: const Text('Formulario')),

      body: isLoading // Si está cargando, mostrar el cuadro de carga
        ? Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 200,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hasError 
                        ? const Icon(
                            Icons.close,
                            size: 80,
                            color: Colors.red,
                          )
                        : const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                    const SizedBox(height: 20),
                    Text(
                      hasError ? 'Error' : 'Cargando...',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            )
          )
        : SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(35, 105, 35, 0),
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Container(
              // margin: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration( 
                color: Colors.white,
                borderRadius: BorderRadius.circular(35), 
                boxShadow: [ 
                  BoxShadow( 
                    color: Colors.black.withOpacity(0.1), 
                    blurRadius: 10, 
                    offset: const Offset(0, 5), 
                  ), 
                ], 
              ),
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      onChanged: (val) {
                        print('Id seleccionada: $val');
                      },
                    ),
              
                    const SizedBox(height: 16),
                
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
              
                    const SizedBox(height: 16),
                
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
              
                    const SizedBox(height: 16),
                    
                    FormBuilderDropdown<String>(
                      name: 'linea_metro',
                      validator: (value) {
                        if (value == null) {
                          _showErrorDialog(context, 'Es obligatorio elegir una Linea del metro');
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Linea del metro',
                        labelFrontSize: 30.0,
                        hintext: 'Linea 1, 2 ... o Teleferico',
                        hintFrontSize: 30.0,
                        icono: const Icon(Icons.people_outline_rounded, size: 30.0),
                        errorSize: 20
                      ),
                      initialValue: _selectLineMetro,
                      items: _lineas.map((linea) {
                        return DropdownMenuItem(
                          value: linea.idLinea,
                          child: Text(linea.nombreLinea, style: const TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1))),
                        );
                      }).toList(),
                      style: const TextStyle(fontSize: 30.0),
                      menuMaxHeight: 250.0, // Altura máxima del cuadro desplegable
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
              
                    const SizedBox(height: 16),
              
                    FormBuilderDropdown<int>(
                      name: 'estacion_metro',
                      style: const TextStyle(fontSize: 30.0),
                      initialValue: _selectedStation,
                      menuMaxHeight: 250.0, // Altura máxima del cuadro desplegable
                      validator: (value) {
                        if(value == null) {
                          _showErrorDialog(context, 'Es obligatorio elegir una Estación del metro');
                          return 'Este campo es requerido';
                        }

                        return null;
                      },
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Estación del metro',
                        labelFrontSize: 30.0,
                        hintext: (_selectedStation).toString(),
                        hintFrontSize: 30.0,
                        icono: const Icon(Icons.train_outlined, size: 30.0),
                        errorSize: 20
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
              
                    const SizedBox(height: 42),
                
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
                          fontSize: 30, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
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
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold), 
                ),
                const SizedBox(height: 8.0),
                const Text( 
                  'Formulario enviado con exito', 
                  style: TextStyle(fontSize: 18.0), 
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

    // Hacer que el cuadro de éxito se cierre automáticamente después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      // Comprobamos si el widget aún está montado antes de intentar realizar cualquier acción
      if (mounted) {
        Navigator.of(context).pop(); // Cierra el cuadro de éxito solo si el widget está montado
      }
    });
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
}
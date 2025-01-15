import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/screens/login_Screen.dart';
import 'package:formulario_opret/screens/presentation_screen.dart';
import 'package:formulario_opret/services/user_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:formulario_opret/widgets/upperCaseText.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Importa esto para controlar la orientación

class NewUser extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  // final TextEditingController filtrarCedula;

  const NewUser({
    super.key,
    required this.filtrarId,
    // required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  // String _selectedRole = ''; // Valor inicial del Dropdown
  final _formkey = GlobalKey<FormBuilderState>();
  // final UpperCaseTextEditingController _controller = UpperCaseTextEditingController();
  final TextEditingController datePicker = TextEditingController();
  DateTime? _selectedDate;
  final ApiServiceUser _apiServiceUser = ApiServiceUser('http://wepapi.somee.com');
  bool _obscureText = true;
  bool isLoading = false; // Variable de control para el cuadro de carga
  // bool hasError = true; // Variable de control para el cuadro de Error de carga

  // Bloquear la orientación de la pantalla
  @override
  void initState() {
    super.initState();
    // Bloquear la orientación a solo vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Para orientación vertical hacia arriba
      DeviceOrientation.portraitDown, // Para orientación vertical hacia abajo
    ]);
  }

  // Restaurar la orientación cuando la pantalla se cierre
  @override
  void dispose() {
    super.dispose();
    // Restaurar la orientación de la pantalla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _registrarUser() async {
    if(_formkey.currentState!.saveAndValidate()){
      final data = _formkey.currentState!.value;
      final nombreCompleto = '${data['nombre']} ${data['apellido']}';

      final user = Usuarios(
        // idUsuarios:  data['idUsuario'],
        // cedula: data['cedula'],
        nombreApellido: nombreCompleto, // Concatenación de nombre y apellido
        usuario1: data['nombreUsuario'],
        email: data['email'],
        passwords: data['password'],
        fechaCreacion: data['fechaCreacion'],
        rol: data['rol'],
      );

      setState(() {
        isLoading = true; // Mostrar el cuadro de carga
        // hasError = false;
      });

      try {
        final response = await _apiServiceUser.createUsuario(user);
        final responseBody = jsonDecode(response.body);

        setState(() {
          isLoading = false; // Ocultar el cuadro de carga
          // hasError = true;
        });

        if (response.statusCode == 201) {
          // Mostrar mensaje de éxito
          _showSuccessDialog(context);

          // Hacer que el cuadro de éxito se cierre automáticamente después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            // Comprobamos si el widget aún está montado antes de intentar realizar cualquier acción
            
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                )
              );
            
          });

        } else if (response.statusCode == 400) {

          setState(() {
            isLoading = false; // Ocultar el cuadro de carga
            // hasError = true;
          });

          String errorMessage = responseBody['message'] ?? 'Error desconocido.';
          _showErrorDialog(context, errorMessage);
        } else {
          // Mostrar mensaje de error
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Error al agregar usuario: ${response.reasonPhrase} de rol: $_selectedRole')),
          // );
          _showErrorDialog(context, 'No se puedo crear el Usuario');
        }
      } catch (e) {
        print('Error al crear usuario: $e');
        _showErrorDialog(context, 'Ocurrió un error inesperado');

        // Hacer que el cuadro de éxito se cierre automáticamente después de 2 segundos
        Future.delayed(const Duration(seconds: 4), () {
          // Comprobamos si el widget aún está montado antes de intentar realizar cualquier acción
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PresentationScreen(
                filtrarUsuarioController: widget.filtrarUsuarioController,  
                filtrarEmailController: widget.filtrarEmailController,
                filtrarId: widget.filtrarId,
                // filtrarCedula: widget.filtrarCedula,
              )),
            ); // Cierra el cuadro de éxito solo si el widget está montado
          }
        });
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*hasError 
                        ? const Icon(
                            Icons.close,
                            size: 80,
                            color: Colors.red,
                          )
                        : */CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                    SizedBox(height: 20),
                    Text(
                      /*hasError ? 'Error' : */'Cargando...',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            )
          ) 
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            // margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration( //para el fondo
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(1, 135, 76, 1),
                  Color.fromRGBO(3, 221, 127, 1),
                ])
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    // margin: const EdgeInsets.symmetric(horizontal: 30),
                    width: size.width,
                    constraints: BoxConstraints(
                      minHeight: size.height,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(5, 20),
                        ),
                      ],
                    ),
                    child: FormBuilder(
                      key: _formkey,
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      /*Hace que los campos se validen automáticamente cada vez que se detecta una interacción con el 
                      formulario. Esto puede causar que todos los campos se validen incluso si no han sido tocados*/

                      autovalidateMode: AutovalidateMode.disabled,
                      /*(la validación se realiza solo cuando se envía el formulario) y realizar la 
                      validación manualmente cuando el usuario intente registrar los datos.*/

                      child: Padding(
                        // padding: const EdgeInsets.fromLTRB(80, 80, 80, 80),
                        padding: const EdgeInsets.all(80),
                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Logo(context),
                                  const SizedBox(height: 20),        
                                  // Texto de "Ingrese sus Datos"
                                  const Text(
                                    'Ingrese sus Datos',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ]
                              )
                            ),
                            const SizedBox(height: 50),
                                    
                            Row( //para hacer que los TextFormField se olganicen en filas
                              children: [
                                Expanded( //Nombre
                                  child: FormBuilderTextField(
                                    name: 'nombre',
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecorations.inputDecoration(
                                      hintext: 'Primer y Segundo Nom.',
                                      hintFrontSize: 22.0,
                                      labeltext: 'Nombre',
                                      labelFrontSize: 35.0,
                                      icono: const Icon(Icons.person_2_outlined, size: 30.0),
                                      errorSize: 20
                                    ),
                                    style: const TextStyle(fontSize: 30.0),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                                    
                                const SizedBox(width: 16.0), // Espacio entre los campos
                                
                                Expanded( //Apellido
                                  child: FormBuilderTextField(
                                    name: 'apellido',
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecorations.inputDecoration(
                                      hintext: 'Primer y Segundo Apell.',
                                      hintFrontSize: 22.0,
                                      labeltext: 'Apellido',
                                      labelFrontSize: 35.0,
                                      icono: const Icon(Icons.person_2_outlined, size: 30.0),
                                      errorSize: 20
                                    ),
                                    style: const TextStyle(fontSize: 30.0),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                )
                              ],
                            ),
                            
                            const SizedBox(height: 30),
                            FormBuilderTextField( //Correo
                              name: 'email',
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: InputDecorations.inputDecoration(
                                hintext: 'ejemplo20##@gmail.com',
                                hintFrontSize: 22.0,
                                labeltext: 'Correo Electronico',
                                labelFrontSize: 35.0,
                                icono: const Icon(Icons.alternate_email_rounded, size: 30.0),
                                errorSize: 20        
                              ),
                              style: const TextStyle(fontSize: 30.0),
                              validator: (value){
                                // expresion regular
                                String pattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$';
                                RegExp regExp = new RegExp(pattern);
                                return regExp.hasMatch(value ?? '')
                                  ? null
                                  : 'Ingrese un correo electronico valido';
                              },
                            ),
                                    
                            const SizedBox(height: 30),
                            FormBuilderTextField( //Usuario
                              name: 'nombreUsuario',
                              keyboardType: TextInputType.name,
                              decoration: InputDecorations.inputDecoration(
                                hintext: 'MetroSantDom123',
                                hintFrontSize: 22.0,
                                labeltext: 'Usuario',
                                labelFrontSize: 35.0,
                                icono: const Icon(Icons.person_pin_circle, size: 30.0),
                                errorSize: 20
                              ),
                              style: const TextStyle(fontSize: 30.0),
                              validator: FormBuilderValidators.required(),
                            ),
                                    
                            const SizedBox(height: 30),
                            FormBuilderTextField( //Contraseña
                              name: 'password',
                              autocorrect: false,
                              obscureText: _obscureText,
                              decoration: InputDecorations.inputDecoration(
                                hintext: '******', 
                                hintFrontSize: 22.0,
                                labeltext: 'Contraseña',
                                labelFrontSize: 35.0,
                                // icono: const Icon(Icons.lock_person_rounded, size: 30.0),
                                icono: const Icon(Icons.lock_person_outlined, size: 30.0),
                                suffIcon: IconButton(
                                  onPressed: _togglePasswordVisibility, 
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    size: 30.0,
                                  )
                                ),
                                errorSize: 20
                              ),
                              style: const TextStyle(fontSize: 30.0),
                              validator: (value) {
                                if(value == null || value.isEmpty){
                                  return 'Por favor ingrese la nueva contraseña';
                                }
                                    
                                if(value.length < 6){
                                  return 'La contraseña debe tener al menos 6 caracteres';                                    
                                }
                                    
                                return null;
                              },
                            ),
                                    
                            const SizedBox(height: 30),
                            FormBuilderTextField(
                              name: 'fechaCreacion',
                              controller: datePicker,
                              // enabled: false,
                              decoration: InputDecorations.inputDecoration(
                                hintext: 'Puedes presionar aqui para elegir la fecha',
                                hintFrontSize: 22.0,
                                labeltext: 'Fecha',
                                labelFrontSize: 35.0,
                                icono: const Icon(Icons.calendar_month_outlined, size: 30.0),
                                errorSize: 20
                              ),
                              style: const TextStyle(fontSize: 30.0),
                              validator: FormBuilderValidators.required(),
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode()); // Cierra el teclado al hacer clic
                                await _showDatePicker(); // Muestra el DatePicker
                              },
                            ),
                                    
                            const SizedBox(height: 30),
                            FormBuilderDropdown<String>(
                              name: 'rol',
                              decoration: InputDecorations.inputDecoration(
                                labeltext: 'Tipo Usuario',
                                labelFrontSize: 30.0,
                                hintext: 'Selecciona el tipo de usuario',
                                hintFrontSize: 22.0,
                                icono: const Icon(Icons.people_outline_rounded, size: 30.0),
                                errorSize: 20
                              ),
                              initialValue: 'Empleado',
                              items: const [
                                DropdownMenuItem(
                                    value: 'Empleado',
                                    child: Text('Empleado', style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1)))),
                                DropdownMenuItem(
                                    value: 'Administrador',
                                    child: Text('Administrador', style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 1, 1, 1)))),
                              ],
                              style: const TextStyle(fontSize: 30.0)
                            ),
                                    
                            const SizedBox(height: 50),
                            // fila de botones Inicio y registros
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                                children: [
                                  ElevatedButton(
                                    onPressed: _registrarUser, 
                                    
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(1, 135, 76, 1), //  se usa para definir el color de fondo del botón.
                                      foregroundColor: const Color.fromARGB(255, 255, 255, 255), // se usa para definir el color del texto y los iconos dentro del botón.
                                      padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(100)),
                                      ),
                                    ),
                                      
                                    child: const Text(
                                      'Registrar e ir al Login',
                                      style: TextStyle(
                                        fontSize: 30, 
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // boton de retroceder de seccion
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PresentationScreen(
                                          filtrarUsuarioController: widget.filtrarUsuarioController,  
                                          filtrarEmailController: widget.filtrarEmailController,
                                          filtrarId: widget.filtrarId,
                                          // filtrarCedula: widget.filtrarCedula, 
                                        )),
                                      );
                                    }, 
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(1, 135, 76, 1), // Color de fondo del primer botón
                                      foregroundColor: const Color.fromARGB(255, 254, 255, 255), // Color del texto
                                      padding: const EdgeInsets.symmetric(horizontal: 138, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100)
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el espacio
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: size.height * 0.03,
                                        ),
                                        const SizedBox(width: 5), // Espacio entre el ícono y el texto
                                        const Text(
                                          'Volver a inicio',
                                          style: TextStyle(
                                            fontSize: 30, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                  const SizedBox(height: 20),
                ],
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
                  'Usuario agregado exitosamente. Ahora inicia sesión', 
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
    // Future.delayed(const Duration(seconds: 5), () {
    //   // Comprobamos si el widget aún está montado antes de intentar realizar cualquier acción
    //   if (mounted) {
    //     Navigator.of(context).pop(); // Cierra el cuadro de éxito solo si el widget está montado
    //   }
    // });
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

  Align Logo(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
        widthFactor: MediaQuery.of(context).orientation == Orientation.portrait ? 0.5 : 0.3, // Ajusta el tamaño del logo según la orientación
        child: AspectRatio(
          aspectRatio: 1.0, // Mantener una proporción 1:1
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              color: const Color.fromRGBO(217, 217, 217, 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image.asset(
                'assets/Logo/Logo_Metro_transparente.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime(2024, 9, 1), 
      lastDate: DateTime.now(),
      builder: (BuildContext content, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      }
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        datePicker.text = DateFormat("yyyy-MM-dd").format(_selectedDate!); // Formatea la fecha seleccionada
      });
    }
  }
}

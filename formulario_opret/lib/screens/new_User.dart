import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/screens/interfaz_User/Empleado_screen.dart';
import 'package:formulario_opret/screens/presentation_screen.dart';
import 'package:formulario_opret/services/user_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:formulario_opret/widgets/upperCaseText.dart';
import 'package:intl/intl.dart';

class NewUser extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const NewUser({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  // late List<UserEmpleado> data = [];
  String _selectedRole = ''; // Valor inicial del Dropdown
  final _formkey = GlobalKey<FormBuilderState>();
  final ApiService apiService = ApiService('https://10.0.2.2:7190');
  final UpperCaseTextEditingController _controller = UpperCaseTextEditingController();
  final TextEditingController datePicker = TextEditingController();
  DateTime? _selectedDate;

  void _registrarUser() async {
    if(_formkey.currentState!.saveAndValidate()){
      final data = _formkey.currentState!.value;
      final nombreCompleto = '${data['nombre']} ${data['apellido']}';

      final user = Usuarios(
        idUsuarios:  data['idUsuario'],
        cedula: data['cedula'],
        nombreApellido: nombreCompleto, // Concatenación de nombre y apellido
        usuario1: data['nombreUsuario'],
        email: data['email'],
        passwords: data['password'],
        fechaCreacion: data['fechaCreacion'],
        rol: _selectedRole,
      );

      try {
        final response = await apiService.createUsuarios(user);
        if (response.statusCode == 201) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario agregado exitosamente')),
          );
        } else {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar usuario: ${response.reasonPhrase} de rol: $_selectedRole')),
          );
        }
      } catch (e) {
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration( //para el fondo
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(1, 135, 76, 1),
              Color.fromRGBO(3, 221, 127, 1),
            ])
        ),
        // width: double.infinity,
        // height: double.infinity,

        child: Stack(
          children: [
            SingleChildScrollView( 
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container( //caja blaca contenedor
                    padding: const EdgeInsets.fromLTRB(80, 100, 80, 0),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    width: size.width * 1.0, // 100% del ancho de la pantalla
                    height: size.height > size.width
                      ? size.height * 1.35 // 80% si está en modo vertical
                      : size.height * 2.25, // 60% si está en modo horizontal
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(5, 20)),
                      ],
                    ),
                  
                    child: FormBuilder(
                      key: _formkey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [         
                          //Logo
                          Logo(context),
                  
                          // Texto de "Ingrese sus Datos"
                          texto(size),
                          const SizedBox(height: 50),
                  
                          FormBuilderTextField(
                            name: 'idUsuario',
                            controller: _controller,
                            decoration: InputDecorations.inputDecoration(
                              hintext: 'USER-000000000 o ADMIN-000000000',
                              hintFrontSize: 22.0,
                              labeltext: 'ID de Usuario asignado', 
                              labelFrontSize: 35.0,
                              icono: const Icon(Icons.account_circle_outlined, size: 30.0)
                            ),
                            style: const TextStyle(fontSize: 30.0),
                            validator: (value) {
                              if (value == null || value.isEmpty){
                                return 'Por favor ingrese su ID-Empleado';
                              }
                  
                              if (!RegExp(r'^(USER|ADMIN)-\d{4,10}$').hasMatch(value)){
                                return 'Por favor ingrese un ID-Empleado valido';
                              }
                  
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                  
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
                                    icono: const Icon(Icons.person_2_outlined, size: 30.0)
                                  ),
                                  style: const TextStyle(fontSize: 30.0),
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
                                    icono: const Icon(Icons.person_2_outlined, size: 30.0)
                                  ),
                                  style: const TextStyle(fontSize: 30.0),
                                ),
                              )
                            ],
                          ),
                  
                          const SizedBox(height: 30),
                          FormBuilderTextField( //Cedula
                            name: 'cedula',
                            keyboardType: TextInputType.number,
                            autocorrect: true,
                            decoration: InputDecorations.inputDecoration(
                              hintext: '000-0000000-0',
                              hintFrontSize: 22.0,
                              labeltext: 'Cedula de identidad',
                              labelFrontSize: 35.0,
                              icono: const Icon(Icons.perm_identity_rounded, size: 30.0)
                            ),
                            style: const TextStyle(fontSize: 30.0),
                            validator: (value) {
                              String pattern = r'^\d{3}-\d{7}-\d{1}$';
                              RegExp regExp = RegExp(pattern);
                              if(value == null || value.isEmpty){
                                return 'Por favor ingrese su cédula';
                              }
                  
                              if(!regExp.hasMatch(value)){
                                return 'Formato de cédula incorrecto';
                              }
                              return null;
                            },
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
                              icono: const Icon(Icons.alternate_email_rounded, size: 30.0)                
                            ),
                            style: const TextStyle(fontSize: 30.0),
                            validator: (value){
                              // expresion regular
                              String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
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
                              icono: const Icon(Icons.person_pin_circle, size: 30.0)
                            ),
                            style: const TextStyle(fontSize: 30.0),
                          ),
                  
                          const SizedBox(height: 30),
                          FormBuilderTextField( //Contraseña
                            name: 'password',
                            autocorrect: false,
                            obscureText: true,
                            decoration: InputDecorations.inputDecoration(
                              hintext: '******', 
                              hintFrontSize: 22.0,
                              labeltext: 'Contraseña',
                              labelFrontSize: 35.0,
                              icono: const Icon(Icons.lock_person_rounded, size: 30.0)
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
                            decoration: InputDecorations.inputDecoration(
                              hintext: 'Fecha de primer Inicio sesion',
                              hintFrontSize: 22.0,
                              labeltext: 'Fecha',
                              labelFrontSize: 35.0,
                              icono: const Icon(Icons.calendar_month_outlined, size: 30.0)
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
                              icono: const Icon(Icons.people_outline_rounded, size: 30.0)
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
                            style: const TextStyle(fontSize: 30.0),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                  
                          const SizedBox(height: 50),
                          // fila de botones Inicio y registros
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Para separar los botones de manera uniforme
                            children: [
                              // boton de Registrar
                              ElevatedButton(
                                onPressed: _registrarUser, 
                                
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(1, 135, 76, 1), //  se usa para definir el color de fondo del botón.
                                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), // se usa para definir el color del texto y los iconos dentro del botón.
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50), //Define el radio para la esquina superior izquierda.
                                      topRight: Radius.circular(0), //Define el radio para la esquina superior derecha.
                                      bottomLeft: Radius.circular(50), //Define el radio para la esquina inferior izquierda.
                                      bottomRight: Radius.circular(0), //Define el radio para la esquina inferior derecha.
                                    ),
                                  ),
                                ),
                  
                                child: const Text(
                                  'Registrar',
                                  style: TextStyle(
                                    fontSize: 30, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                              
                              // boton de Inicio de seccion
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => EmpleadoScreens(
                                        filtrarUsuarioController: widget.filtrarUsuarioController,  
                                        filtrarEmailController: widget.filtrarEmailController,
                                        filtrarId: widget.filtrarId,
                                        filtrarCedula: widget.filtrarCedula,
                                      ),
                                    )
                                  );
                                }, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(1, 135, 76, 1), // Color de fondo del primer botón
                                  foregroundColor: const Color.fromARGB(255, 254, 255, 255), // Color del texto
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(50),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(50),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Inicio',
                                  style: TextStyle(
                                    fontSize: 30, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          goBack(size, context), 
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned goBack(Size size, BuildContext context) {
    return Positioned( // ajuste de ubicación del icono y texto
      // top: size.height * 0.05,
      // left: size.width * 0.05,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PresentationScreen(
              filtrarUsuarioController: widget.filtrarUsuarioController,  
              filtrarEmailController: widget.filtrarEmailController,
              filtrarId: widget.filtrarId,
              filtrarCedula: widget.filtrarCedula, 
            )),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el espacio
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: size.height * 0.03,
            ),
            const SizedBox(width: 5), // Espacio entre el ícono y el texto
            Text(
              'Volver',
              style: TextStyle(
                fontSize: size.height * 0.038, // Ajusta el tamaño del texto según sea necesario
                color: const Color.fromARGB(255, 26, 26, 26),
              ),
            ),
          ],
        ),
      ),
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
              borderRadius: BorderRadius.circular(150),
              color: const Color.fromRGBO(217, 217, 217, 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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

  Positioned texto(Size size) {
    return Positioned(
      top: size.height * 0.30,
      left: size.width * 0.25,
      right: size.width * 0.25,
      child: const Text('Ingrese sus Datos', 
      textAlign: TextAlign.center, //para determinar la posicion del texto
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 0, 0)
      ),),
    );
  }
}


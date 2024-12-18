import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/user_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';

class PerfiluserScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  // final TextEditingController filtrarCedula;

  const PerfiluserScreen({
    super.key,
    required this.filtrarId,
    // required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<PerfiluserScreen> createState() => _PerfiluserScreenState();
}

class _PerfiluserScreenState extends State<PerfiluserScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  final ApiServiceUser _apiServiceUser = ApiServiceUser('https://10.0.2.2:7190'); // Servicio para obtener datos del usuario
  late Future<Usuarios?> _userData;
  final TextEditingController datePicker = TextEditingController();
  String selectedRole = 'Empleado';
  bool _obscureText = true;

  @override 
  void initState() { 
    super.initState(); 
    _loadUserProfile(); 
  }

  Future<void> _loadUserProfile() async {
    _userData = _apiServiceUser.getOneUsuario(widget.filtrarId.text);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(
        filtrarUsuarioController: widget.filtrarUsuarioController,
        filtrarEmailController: widget.filtrarEmailController,
        filtrarId: widget.filtrarId,
        // // filtrarCedula: widget.filtrarCedula,
      ),

      appBar: AppBar( 
        title: const Text('Perfil del Usuario'), 
      ),

      body: FutureBuilder<Usuarios?>(
        future: _userData, 
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Usuario no encontrado'));
          } else {
            final user = snapshot.data!;
            return FormBuilder(
              key: formKey,
              initialValue: {
                // 'cedula': user.cedula,
                'nombre': user.nombreApellido,
                'usuario': user.usuario1,
                'email': user.email,
                // 'password': user.passwords,
                'fechaCreacion': user.fechaCreacion,
                'rol': user.rol
              },
              autovalidateMode: AutovalidateMode.disabled,
              child: Padding(
                 padding: const EdgeInsets.all(50.0),
                 child: Column(
                  children: [
                    // FormBuilderTextField(
                    //   name: 'cedula',
                    //   style: const TextStyle(fontSize: 30.0),
                    //   enabled: false,
                    //   decoration: InputDecorations.inputDecoration(
                    //     labeltext: 'Cedula',
                    //     labelFrontSize: 30.5,
                    //     hintext: '000-0000000-0',
                    //     hintFrontSize: 25.0,
                    //     icono: const Icon(Icons.person_pin_circle_outlined, size: 30.0),
                    //   ),                    
                    // ),
            
                    FormBuilderTextField(
                      name: 'nombre',
                      style: const TextStyle(fontSize: 30.0),
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Editar Nombre Completo',
                        labelFrontSize: 30.5,
                        hintext: 'Nombre y Apellido',
                        hintFrontSize: 25.0,
                        icono: const Icon(Icons.person, size: 30.0),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
            
                    FormBuilderTextField(
                      name: 'usuario',
                      style: const TextStyle(fontSize: 30.0),
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Editar Usuario',
                        labelFrontSize: 30.5,
                        hintext: 'MetroSantDom123',
                        hintFrontSize: 25.0,
                        icono: const Icon(Icons.account_circle, size: 30.0),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
            
                    FormBuilderTextField(
                      name: 'email',
                      style: const TextStyle(fontSize: 30.0),
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Editar Email',
                        labelFrontSize: 30.5,
                        hintext: 'ejemplo-0##@gmail.com',
                        hintFrontSize: 25.0,
                        icono: const Icon(Icons.alternate_email_rounded, size: 30.0),
                      ),
                      // validator: FormBuilderValidators.required(),
                      validator: (value){
                        // expresion regular
                        String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                        RegExp regExp = RegExp(pattern);
                        return regExp.hasMatch(value ?? '')
                          ? null
                          : 'Ingrese un correo electronico valido';
                      },
                    ),
            
                    FormBuilderTextField(
                      name: 'password',
                      autocorrect: false,
                      obscureText: _obscureText,
                      style: const TextStyle(fontSize: 30.0),
                      // controller: passwordController,
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Editar Contraseña',
                        labelFrontSize: 30.5,
                        hintext: '******',
                        hintFrontSize: 25.0,
                        errorSize: 20,
                        icono: const Icon(Icons.lock_clock_outlined, size: 30.0),
                        suffIcon: IconButton(
                          onPressed: _togglePasswordVisibility, 
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            size: 30.0,
                          )
                        ),
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty){
                          // return 'Debe de introducir la contraseña, para confirmar los cambio';
                          _showErrorDialog(context, 'Debe de introducir la contraseña, para confirmar los cambio');
                        }
            
                        if(value!.length < 6){
                          // return 'La contraseña debe tener al menos 6 caracteres';
                          _showErrorDialog(context, 'La contraseña debe tener al menos 6 caracteres');                                  
                        }
            
                        return null;
                      },
                    ),
            
                    FormBuilderTextField(
                      name: 'fechaCreacion',
                      // controller: datePicker,
                      enabled: false,
                      style: const TextStyle(fontSize: 30.0),
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Fecha de Ingreso',
                        labelFrontSize: 30.5,
                        icono: const Icon(Icons.calendar_month_outlined, size: 30.0)
                      ),
                    ),
            
                    FormBuilderDropdown<String>(
                      name: 'rol',
                      enabled: false,
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Tipo Usuario',
                        labelFrontSize: 30.0,
                        hintext: 'Selecciona el tipo de usuario',
                        hintFrontSize: 22.0,
                        icono: const Icon(Icons.people_outline_rounded, size: 30.0)
                      ),
                      // initialValue: 'Empleado',
                      style: const TextStyle(fontSize: 25.0, color: Color.fromARGB(255, 1, 1, 1)),
                      items: const [
                        DropdownMenuItem(
                            value: 'Empleado',
                            child: Text('Empleado' )),
                        DropdownMenuItem(
                            value: 'Administrador',
                            child: Text('Administrador')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
            
                    const SizedBox(height: 55),
            
                    Center(
                      child: ElevatedButton(
                        onPressed: () {_upLoadUser(user);},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(1, 135, 76, 1), // Color de fondo del primer botón
                          foregroundColor: const Color.fromARGB(255, 254, 255, 255), // Color del texto
                          padding: const EdgeInsets.symmetric(horizontal: 138, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el espacio
                          children: [
                            Icon(
                              Icons.edit,
                              size: 30.0,
                            ),
                            SizedBox(width: 5), // Espacio entre el ícono y el texto
                            Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                fontSize: 30, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]
                 )
              ),
            );
          }
        }
      ),
    );
  }

  Future <void> _upLoadUser(Usuarios userUpload) async {
    if(formKey.currentState!.saveAndValidate()){
      final upLoadUser = formKey.currentState!.value;
      Usuarios usuarioActualizado = Usuarios(
        idUsuarios: userUpload.idUsuarios,
        // cedula: userUpload.cedula,
        nombreApellido: upLoadUser['nombre'], 
        usuario1: upLoadUser['usuario'], 
        email: upLoadUser['email'], 
        passwords: upLoadUser['password'], 
        fechaCreacion: userUpload.fechaCreacion, 
        rol: userUpload.rol
      );

      print('Datos a actualizar: $usuarioActualizado');
      print('Datos a enviar: ${usuarioActualizado.toJson()}');

      try{
        final response = await _apiServiceUser.updateUsuario(userUpload.idUsuarios!, usuarioActualizado);

        if(response.statusCode == 204){
          print('El Usuario fue modificada con éxito');
          _showSuccessDialog(context, 'El Usuario fue modificada con éxito');
          _loadUserProfile();
        } else {
          print('Error al modificar el Usuario: ${response.body}');
          _showErrorDialog(context, 'Error al actualizar el usuario');
        }
      } catch (e) {
        print('Error al actualizar usuario: $e');
        _showErrorDialog(context, 'Error al actualizar usuario: $e');
      }
    }
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

    // Hacer que el cuadro de éxito se cierre automáticamente después de 2 segundos
    // Future.delayed(const Duration(seconds: 2), () {
    //   // Comprobamos si el widget aún está montado antes de intentar realizar cualquier acción
    //   if (mounted) {
    //     Navigator.of(context).pop(); // Cierra el cuadro de éxito solo si el widget está montado
    //   }
    // });
  }

  // para mostrar los errores
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
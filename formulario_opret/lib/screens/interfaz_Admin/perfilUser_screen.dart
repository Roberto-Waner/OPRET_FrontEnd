import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final ApiServiceUser _apiServiceUser = ApiServiceUser('http://wepapi.somee.com'); // Servicio para obtener datos del usuario
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

    return ScreenUtilInit(
      designSize: const Size(360, 740),
      builder: (context, child) => Scaffold(
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
              print('Error al cargar los datos: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Usuario no encontrado'));
            } else {
              final user = snapshot.data!;
              return SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: {
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
                
                        FormBuilderTextField(
                          name: 'nombre',
                          style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Editar Nombre Completo',
                            labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                            hintext: 'Nombre y Apellido',
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.person, size: isTabletDevice ? 15.sp : 15.sp),
                            errorSize: isTabletDevice ? 10.sp : 10.sp, 
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                
                        FormBuilderTextField(
                          name: 'usuario',
                          style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Editar Usuario',
                            labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                            hintext: 'MetroSantDom123',
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.account_circle, size: isTabletDevice ? 15.sp : 15.sp),
                            errorSize: isTabletDevice ? 10.sp : 10.sp,
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                
                        FormBuilderTextField(
                          name: 'email',
                          style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Editar Email',
                            labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                            hintext: 'ejemplo-0##@gmail.com',
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.alternate_email_rounded, size: isTabletDevice ? 15.sp : 15.sp),
                            errorSize: isTabletDevice ? 10.sp : 10.sp,
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
                          style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          // controller: passwordController,
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Editar Contraseña',
                            labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                            hintext: '******',
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            errorSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.lock_clock_outlined, size: isTabletDevice ? 15.sp : 15.sp),
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
                          style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Fecha de Ingreso',
                            labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                            icono: Icon(Icons.calendar_month_outlined, size: isTabletDevice ? 15.sp : 15.sp),
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                          ),
                        ),
                
                        FormBuilderDropdown<String>(
                          name: 'rol',
                          enabled: false,
                          decoration: InputDecorations.inputDecoration(
                            labeltext: 'Tipo Usuario',
                            labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
                            hintext: 'Selecciona el tipo de usuario',
                            hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
                            icono: Icon(Icons.people_outline_rounded, size: isTabletDevice ? 15.sp : 15.sp),
                            errorSize: isTabletDevice ? 10.sp : 10.sp
                          ),
                          // initialValue: 'Empleado',
                          style: TextStyle(fontSize: isTabletDevice ? 11.5.sp : 11.5.sp, color: const Color.fromARGB(255, 1, 1, 1)),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: isTabletDevice ? 0.2.sw : 0.2.sw,
                                vertical: isTabletDevice ? 10.h : 11.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el espacio
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: isTabletDevice ? 15.sp : 15.sp,
                                ),
                                const SizedBox(width: 5), // Espacio entre el ícono y el texto
                                Text(
                                  'Guardar Cambios',
                                  style: TextStyle(
                                    fontSize: isTabletDevice ? 15.sp : 15.sp, 
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
                ),
              );
            }
          }
        ),
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
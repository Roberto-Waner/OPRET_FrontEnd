import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:formulario_opret/models/userEmpleado.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/user_services.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'package:intl/intl.dart';

class RegistroEmpl extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const RegistroEmpl({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<RegistroEmpl> createState() => _RegistroEmplState();
}

class _RegistroEmplState extends State<RegistroEmpl> {
  final ApiService _apiService = ApiService('https://10.0.2.2:7190'); // Cambia por tu URL
  late Future<List<ObtenerEmpleados>> _usuariosdata;
  final TextEditingController datePicker = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState(){
    super.initState();
    _usuariosdata = _apiService.getUsuarios(); // Cargar los usuarios al iniciar
  }

  // Llamada para refrescar datos
  void _refreshUsuarios() {
    setState(() {
      _usuariosdata = _apiService.getUsuarios();
    });
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
    return Scaffold(
      drawer: Navbar(
        filtrarUsuarioController: widget.filtrarUsuarioController,
        filtrarEmailController: widget.filtrarEmailController,
        filtrarId: widget.filtrarId,
        filtrarCedula: widget.filtrarCedula,
      ),
      appBar: AppBar(title: const Text('Registro Empleados')),
      body: FutureBuilder<List<ObtenerEmpleados>>(
        future: _usuariosdata,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else if (snapshot.hasError){
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          }else {
            final usuariostabla = snapshot.data ?? [];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Permitir scroll horizontal
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Cedula', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Nombre Completo', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Usuario', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Correo Electronico', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Fecha de Creacion', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Rol', style: TextStyle(fontSize: 23.0))),
                  DataColumn(label: Text('Accion', style: TextStyle(fontSize: 23.0)))
                ], 
                rows: usuariostabla.map((obtenerEmpleado){
                  Usuarios usuario = Usuarios(
                    idUsuarios: obtenerEmpleado.idUsuarios$,
                    cedula: obtenerEmpleado.cedula$,
                    nombreApellido: obtenerEmpleado.nombreApellido$,
                    usuario1: obtenerEmpleado.usuario$,
                    email: obtenerEmpleado.email$,
                    passwords: '',
                    foto: null,
                    fechaCreacion: obtenerEmpleado.fechaCreacion$,
                    rol: obtenerEmpleado.rol$,
                  );

                  return DataRow(
                    cells: [
                      DataCell(Text(usuario.idUsuarios, style: const TextStyle(fontSize: 20.0))),
                      DataCell(Text(usuario.cedula, style: const TextStyle(fontSize: 20.0))),
                      DataCell(Text(usuario.nombreApellido, style: const TextStyle(fontSize: 20.0))),
                      DataCell(Text(usuario.usuario1, style: const TextStyle(fontSize: 20.0))),
                      DataCell(Text(usuario.email, style: const TextStyle(fontSize: 20.0))),
                      DataCell(Text(usuario.fechaCreacion, style: const TextStyle(fontSize: 20.0))),
                      DataCell(Text(usuario.rol, style: const TextStyle(fontSize: 20.0))),
                      // DataCell(Text(usuario.estado.toString(), style: const TextStyle(fontSize: 20.0))),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit), 
                              onPressed: (){
                                _showEditDialog(usuario);
                              },
                            ),
              
                            IconButton(
                              onPressed: () {
                                _showDeleteDialog(usuario);
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'RegEmpleado_tag',
        onPressed: () {
          _showCreateDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Mostrar diálogo para crear un nuevo usuario
  void _showCreateDialog() {
    final formKey = GlobalKey<FormBuilderState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    @override
    void dispose(){
      passwordController.dispose();
      confirmPasswordController.dispose();
      super.dispose();
    }

    showDialog(
      context: context,
      builder: (context) {
        // Formulario para crear usuario
        return AlertDialog(
          title: const Text('Crear Usuario'),
          contentPadding: const EdgeInsets.fromLTRB(60, 20, 60, 50),  // Elimina el padding por defecto
          content: SingleChildScrollView(
            child: Container(
              // margin: const EdgeInsets.all(70),  // Aplica margen
              margin: const EdgeInsets.fromLTRB(50, 20, 50, 10),  // Aplica margen
              // width: 600,
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'id',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Asignar ID',
                        labelFrontSize: 20.5, // Tamaño de letra personalizado
                        hintext: 'USER-000000000',
                        hintFrontSize: 15.0,
                        icono: const Icon(Icons.perm_identity_outlined,size: 30.0),
                      ),
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
                    ),
            
                    FormBuilderTextField(
                      name: 'cedula',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Cedula',
                        labelFrontSize: 20.5,
                        hintext: '000-0000000-0',
                        hintFrontSize: 15.0, 
                        icono: const Icon(Icons.person_pin_circle_outlined, size: 30.0),
                      ),
                      // validator: FormBuilderValidators.required(),
                      validator: FormBuilderValidators.compose([ //Combina varios validadores. En este caso, se utiliza el validador requerido y una función personalizada para la expresión regular.
                        FormBuilderValidators.required(errorText: 'Debe de ingresar la cedula'), //Valida que el campo no esté vacío y muestra el mensaje 'El correo es obligatorio' si no se ingresa ningún valor.
                        (value) {
                          // Expresión regular para validar la cedula
                          String pattern = r'^\d{3}-\d{7}-\d{1}$';
                          RegExp regExp = RegExp(pattern);
            
                          if(!regExp.hasMatch(value ?? '')){
                            return 'Formato de cédula incorrecto';
                          }
                          return null;
                        },
                      ]),                    
                    ),
            
                    FormBuilderTextField(
                      name: 'nombre',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Nombre Completo',
                        labelFrontSize: 20.5,
                        hintext: 'Nombre y Apellido',
                        hintFrontSize: 15.0,
                        icono: const Icon(Icons.person, size: 30.0),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
            
                    FormBuilderTextField(
                      name: 'usuario',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Usuario',
                        labelFrontSize: 20.5,
                        hintext: 'MetroSantDom123',
                        hintFrontSize: 15.0,
                        icono: const Icon(Icons.account_circle, size: 30.0),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
            
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Email',
                        labelFrontSize: 20.5,
                        hintext: 'ejemplo-0##@gmail.com',
                        hintFrontSize: 15.0,
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
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Contraseña',
                        labelFrontSize: 20.5,
                        hintext: '******',
                        hintFrontSize: 15.0,
                        icono: const Icon(Icons.lock_person_outlined, size: 30.0),
                      ),
                      // validator: FormBuilderValidators.required(),
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
            
                    FormBuilderTextField(
                      name: 'fechaCreacion',
                      controller: datePicker,
                      decoration: InputDecorations.inputDecoration(
                        hintext: 'Hora actual',
                        hintFrontSize: 15.0,
                        labeltext: 'Fecha de Encuesta',
                        labelFrontSize: 20.0,
                        icono: const Icon(Icons.calendar_month_outlined, size: 30.0)
                      ),
                      validator: FormBuilderValidators.required(),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode()); // Cierra el teclado al hacer clic
                        await _showDatePicker(); // Muestra el DatePicker
                      },
                    ),
                    
                    FormBuilderTextField(
                      name: 'rol',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Rol',
                        labelFrontSize: 20.5,
                        hintext: 'Empleado',
                        hintFrontSize: 15.0,
                        icono: const Icon(Icons.groups_3_outlined, size: 30.0),
                      ),
                      // validator: FormBuilderValidators.required(),
                      validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Por favor ingrese el rol';
                        }
            
                        if(value != 'Empleado'){
                          return 'Solo se permite el rol de Empleado';
                        }
            
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if(formKey.currentState!.saveAndValidate()){
                  final formData = formKey.currentState!.value;
                  Usuarios nuevoUsuario = Usuarios(
                    idUsuarios: formData['id'],
                    cedula: formData['cedula'],
                    nombreApellido: formData['nombre'],
                    usuario1: formData['usuario'],
                    email: formData['email'],
                    passwords: formData['password'], 
                    fechaCreacion: formData['fechaCreacion'], 
                    rol: formData['rol'], 
                  );

                  // Llamar al servicio para crear el usuario
                  try {
                    final response = await ApiService('https://10.0.2.2:7190')
                        .createUsuarios(nuevoUsuario);
                    if (response.statusCode == 201) {
                      print('Usuario creado con éxito');
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      // Refrescar la lista de usuarios aquí
                      _refreshUsuarios();
                    } else {
                      print('Error al crear usuario: ${response.body}');
                    }
                  } catch (e) {
                    print('Excepción al crear usuario: $e');
                  }
                }
              }, 
              child: const Text('Guardar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  // Mostrar diálogo para editar un usuario
  void _showEditDialog(Usuarios userUpload) {
    final formKey = GlobalKey<FormBuilderState>(); // Clave para manejar el estado del formulario
    // final passwordController = TextEditingController();
    // final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        // Formulario para editar usuario
        return AlertDialog(
          title: const Text('Editar Usuario'),
          contentPadding: const EdgeInsets.fromLTRB(60, 20, 60, 50),  // Adaptar el padding por defecto
          content: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.fromLTRB(50, 20, 50, 10),  // Aplica margen
              width: 600,
              child: FormBuilder(
                key: formKey,
                initialValue: { //la funicion de "initialValue" es firtral de manera automatica los datos de los diferentes campos de la base de datos
                  'nombreApellido': userUpload.nombreApellido,
                  'usuario': userUpload.usuario1,
                  'email': userUpload.email,
                  // 'password': userUpload.passwords,
                  // 'fechaCreacion': userUpload.fechaCreacion
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'nombreApellido',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Nombre Completo',
                        labelFrontSize: 30.5,
                        hintext: 'Nombre y Apellido',
                        hintFrontSize: 15.0,
                        icono: const Icon(Icons.person, size: 30.0),
                      ),
                      style: const TextStyle(fontSize: 23.5), // Cambiar tamaño de letra del texto filtrado
                      validator: FormBuilderValidators.required(),
                    ),
              
                    FormBuilderTextField(
                      name: 'usuario',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Usuario',
                        labelFrontSize: 15.5,
                        hintext: 'MetroSantDom123',
                        hintFrontSize: 20.0,
                        icono: const Icon(Icons.account_circle, size: 30.0),
                      ),
                      style: const TextStyle(fontSize: 23.5), // Cambiar tamaño de letra del texto filtrado
                      validator: FormBuilderValidators.required(),
                    ),
              
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecorations.inputDecoration(
                        labeltext: 'Email',
                        labelFrontSize: 15.5,
                        hintext: 'ejemplo20##@gmail.com',
                        hintFrontSize: 20.0,
                        icono: const Icon(Icons.alternate_email_rounded, size: 30.0),
                      ),
                      // validator: FormBuilderValidators.required(),
                      style: const TextStyle(fontSize: 23.5), // Cambiar tamaño de letra del texto filtrado
                      validator: (value){
                        // expresion regular
                        String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                        RegExp regExp = RegExp(pattern);
                        return regExp.hasMatch(value ?? '')
                          ? null
                          : 'Ingrese un correo electronico valido';
                      },
                    ),
              
                    // FormBuilderTextField(
                    //   name: 'password',
                    //   autocorrect: false,
                    //   obscureText: true,
                    //   controller: passwordController,
                    //   decoration: InputDecorations.inputDecoration(
                    //     labeltext: 'Contraseña',
                    //     labelFrontSize: 15.5,
                    //     hintext: '******',
                    //     hintFrontSize: 20.0,
                    //     icono: const Icon(Icons.lock_person_outlined, size: 30.0),
                    //   ),
                    //   // validator: FormBuilderValidators.required(),
                    //   style: const TextStyle(fontSize: 23.5), // Cambiar tamaño de letra del texto filtrado
                    //   validator: (value) {
                    //     if(value == null || value.isEmpty){
                    //       return 'Por favor ingrese la nueva contraseña';
                    //     }
              
                    //     if(value.length < 6){
                    //       return 'La contraseña debe tener al menos 6 caracteres';                                    
                    //     }
              
                    //     return null;
                    //   },
                    // ),
                    // FormBuilderTextField(
                    //   name: 'fechaCreacion',
                    //   controller: datePicker,
                    //   decoration: InputDecorations.inputDecoration(
                    //     hintext: 'Hora actual',
                    //     hintFrontSize: 20.0,
                    //     labeltext: 'Fecha de Encuesta',
                    //     labelFrontSize: 15.0,
                    //     icono: const Icon(Icons.calendar_month_outlined, size: 30.0)
                    //   ),
                    //   validator: FormBuilderValidators.required(),
                    //   onTap: () async {
                    //     FocusScope.of(context).requestFocus(FocusNode()); // Cierra el teclado al hacer clic
                    //     await _showDatePicker(); // Muestra el DatePicker
                    //   },
                    // ),
              
                    // FormBuilderTextField(
                    //   name: 'resptPassword',
                    //   autocorrect: false,
                    //   obscureText: true,
                    //   controller: confirmPasswordController,
                    //   decoration: InputDecorations.inputDecoration(
                    //     labeltext: 'Contraseña',
                    //     labelFrontSize: 15.5,
                    //     hintext: '******',
                    //     hintFrontSize: 20.0,
                    //     icono: const Icon(Icons.lock_person_outlined, size: 30.0),
                    //   ),
                    //   // validator: FormBuilderValidators.required(),
                    //   style: const TextStyle(fontSize: 23.5), // Cambiar tamaño de letra del texto filtrado
                    //   validator: (value) {
                    //     if(value == null || value.isEmpty){
                    //       return 'Por favor repita la contraseña';
                    //     }
              
                    //     if(value.length < 6){
                    //       return 'La contraseña debe tener al menos 6 caracteres';                                    
                    //     }
              
                    //     if(value != passwordController.text){
                    //       return 'Las contraseñas no coinciden';
                    //     }
              
                    //     return null;
                    //   },
                    // ),
                  ],
                ),
              ),
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
              child: const Text('Actualizar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              onPressed: () async {
                // Llamar al método de actualización y refrescar la lista
                if(formKey.currentState!.saveAndValidate()){
                  // Obtener los valores del formulario
                  final formData = formKey.currentState!.value;
                  Usuarios usuarioActualizado = Usuarios(
                    idUsuarios: userUpload.idUsuarios, // Mantener el ID original
                    cedula: userUpload.cedula,
                    nombreApellido: formData['nombreApellido'],
                    usuario1: formData['usuario'],
                    email: formData['email'],
                    passwords: userUpload.passwords, // Mantener la contraseña original
                    fechaCreacion: userUpload.fechaCreacion, // Mantener la fecha original
                    rol: userUpload.rol, // Mantener el rol original
                    // fotoEmpl: usuario.fotoEmpl, // Mantener la foto original
                  );

                  print(formData);

                  // Llamar al servicio para actualizar el usuario
                  try {
                    final response = await ApiService('https://10.0.2.2:7190')
                        .updateUsuario(userUpload.idUsuarios, usuarioActualizado);
                    if (response.statusCode == 204) {
                      print('Usuario actualizado con éxito');
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      // Refrescar la lista de usuarios aquí
                      _refreshUsuarios();
                    } else {
                      print('Error al actualizar usuario: ${response.body}');
                    }
                  } catch (e) {
                    print('Excepción al actualizar usuario: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo para Eliminar un usuario
  void _showDeleteDialog(Usuarios userDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          contentPadding: const EdgeInsets.fromLTRB(80, 40, 60, 50),
          content: Text('¿Estás seguro de que deseas eliminar al usuario ${userDelete.nombreApellido}?', style: const TextStyle(fontSize: 30)),
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
                  final response = await ApiService('https://10.0.2.2:7190')
                      .deleteUsuario(userDelete.idUsuarios);
                  if (response.statusCode == 204) {
                    print('Usuario eliminado con éxito');
                    Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                    // Refrescar la lista de usuarios aquí
                    _refreshUsuarios();
                  } else {
                    print('Error al eliminar usuario: ${response.body}');
                  }
                } catch (e) {
                  print('Excepción al eliminar usuario: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
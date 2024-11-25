import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
  final ApiServiceUser _apiServiceUser = ApiServiceUser('https://10.0.2.2:7190'); // Cambia por tu URL
  late Future<List<Usuarios>> _usuariosdata;
  final TextEditingController datePicker = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  Usuarios? usuariosFiltrados;
  DateTime? _selectedDate;
  Offset position = const Offset(700, 1150); // Posición inicial del botón
  String selectedRole = '';

  @override
  void initState() {
    super.initState();
    _usuariosdata = _apiServiceUser.getUsuarios();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() {
      _usuariosdata = _apiServiceUser.getUsuarios();
    });
  }

  void _refreshUsuarios() {
    setState(() {
      _usuariosdata = _apiServiceUser.getUsuarios();
    });
  }

  void _filtrarUsuarioPorId(String query) async {
    final usuarios = await _usuariosdata;
    final filtrar = usuarios.firstWhere(
      (usuario) => 
        usuario.idUsuarios.toLowerCase().contains(query.toLowerCase()) ||
        usuario.cedula.toLowerCase().contains(query.toLowerCase()) ||
        usuario.usuario1.toLowerCase().contains(query.toLowerCase()) ||
        usuario.nombreApellido.toLowerCase().contains(query.toLowerCase()),
      orElse: () => Usuarios(
        idUsuarios: '',
        cedula: '',
        nombreApellido: '',
        usuario1: '',
        email: '',
        passwords: '',
        fechaCreacion: '',
        rol: ''
      ) // Devolver un objeto de Usuario vacío
    );

    setState(() {
      usuariosFiltrados = filtrar.idUsuarios.isNotEmpty ? filtrar : null;
    });
  }

  void _limpiarBusqueda() { 
    searchController.clear();
    setState(() { 
      usuariosFiltrados = null; 
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
      appBar: AppBar(
        title: const Text('Registro Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30.0),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() {
                _refreshUsuarios();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Campo de entrada para búsqueda
          Padding( 
            padding: const EdgeInsets.all(16.0), 
            child: FormBuilder( 
              child: FormBuilderTextField( 
                name: 'search', 
                controller: searchController,
                style: const TextStyle(fontSize: 20.0),
                decoration: InputDecoration( 
                  labelText: 'Buscar Usuario aqui',
                  labelStyle: const TextStyle(fontSize: 30),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _limpiarBusqueda,
                      )
                    : null                          
                ), 
                onChanged: (value) { 
                  if (value != null && value.isNotEmpty) { 
                    _filtrarUsuarioPorId(value); 
                  } else { 
                    setState(() { 
                      usuariosFiltrados = null; 
                    }); 
                  } 
                }, 
              ), 
            ), 
          ),

          // Mostrar detalles del usuario seleccionado
          if (usuariosFiltrados != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: const Color.fromARGB(255, 2, 37, 4), // Color de fondo de la tarjeta
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Colors.blue,
                            child: Text(
                              usuariosFiltrados!.nombreApellido[0],
                              style: const TextStyle(
                                fontSize: 30.0,
                                color: Colors.white
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuariosFiltrados!.nombreApellido,
                                style: const TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 246, 244, 244)
                                )
                              ),
                              Text(
                                usuariosFiltrados!.email,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  color: Color.fromARGB(255, 58, 204, 240)
                                )
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.perm_identity, size: 30.0, color: Colors.blue),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                  text: 'ID: ', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0, color: Colors.white),
                              ),
                              TextSpan( 
                                text: usuariosFiltrados!.idUsuarios, 
                                style: const TextStyle(fontSize: 28.0, color: Colors.white), 
                              ),
                            ]
                          )
                        )
                      ),
                      ListTile(
                        leading: const Icon(Icons.account_circle, size: 30.0, color: Colors.blue),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                  text: 'Usuario: ', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0, color: Colors.white),
                              ),
                              TextSpan( 
                                text: usuariosFiltrados!.usuario1, 
                                style: const TextStyle(fontSize: 28.0, color: Colors.white), 
                              ),
                            ]
                          )
                        )
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_pin_circle_outlined, size: 30.0, color: Colors.blue),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                  text: 'Cédula: ', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0, color: Colors.white),
                              ),
                              TextSpan( 
                                text: usuariosFiltrados!.cedula, 
                                style: const TextStyle(fontSize: 28.0, color: Colors.white), 
                              ),
                            ]
                          )
                        )
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined, size: 30.0, color: Colors.blue),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                  text: 'Fecha de Creación: ', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0, color: Colors.white),
                              ),
                              TextSpan( 
                                text: usuariosFiltrados!.fechaCreacion, 
                                style: const TextStyle(fontSize: 28.0, color: Colors.white), 
                              ),
                            ]
                          )
                        )
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_outline_rounded, size: 30.0, color: Colors.blue),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                  text: 'Rol: ', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0, color: Colors.white),
                              ),
                              TextSpan( 
                                text: usuariosFiltrados!.rol, 
                                style: const TextStyle(fontSize: 28.0, color: Colors.white), 
                              ),
                            ]
                          )
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],

          Expanded(
            child: FutureBuilder<List<Usuarios>>(
              future: _usuariosdata,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }else if (snapshot.hasError){
                  return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
                }else {
                  final usuariostabla = snapshot.data ?? [];
            
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Permitir scroll horizontal
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color.fromARGB(255, 74, 71, 71)),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 9, 9, 9).withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            )
                          ]
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 2, 37, 4)), // Fondo de encabezado
                          headingTextStyle: const TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold), // Texto de encabezado,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Cedula')),
                            DataColumn(label: Text('Nombre Completo')),
                            DataColumn(label: Text('Usuario')),
                            DataColumn(label: Text('Correo Electronico')),
                            DataColumn(label: Text('Fecha de Creacion')),
                            DataColumn(label: Text('Rol')),
                            DataColumn(label: Text('Accion'))
                          ], 
                          rows: usuariostabla.map((usuario){
                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color>((states) {
                                // Color alterno para las filas
                                return (usuariostabla.indexOf(usuario) % 2 == 0)
                                      ? Colors.blueGrey.shade50
                                      : Colors.white;
                              }),
                              cells: [
                                DataCell(Text(usuario.idUsuarios, style: const TextStyle(fontSize: 20.0))),
                                DataCell(Text(usuario.cedula, style: const TextStyle(fontSize: 20.0))),
                                DataCell(Text(usuario.nombreApellido, style: const TextStyle(fontSize: 20.0))),
                                DataCell(Text(usuario.usuario1, style: const TextStyle(fontSize: 20.0))),
                                DataCell(Text(usuario.email, style: const TextStyle(fontSize: 20.0))),
                                DataCell(Text(usuario.fechaCreacion, style: const TextStyle(fontSize: 20.0))),
                                DataCell(Text(usuario.rol, style: const TextStyle(fontSize: 20.0))),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),  
                                        onPressed: (){
                                          _showEditDialog(usuario);
                                        },
                                      ),
                        
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteDialog(usuario);
                                        }, 
                                        icon: const Icon(Icons.delete, color: Colors.red)
                                      )
                                    ],
                                  )
                                )
                              ]
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }
              }
            ),
          )
        ]
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: FloatingActionButton(
                onPressed: () => _showCreateDialog(context),
                child: const Icon(Icons.add),
              ),
              // childWhenDragging: Container(), // Widget que aparece en la posición original mientras se arrastra
              onDragEnd: (details) {
                setState(() {
                  // Limitar la posición del botón a los límites de la pantalla
                  double dx = details.offset.dx;
                  double dy = details.offset.dy;

                  if (dx < 0) dx = 0;
                  if (dx > MediaQuery.of(context).size.width - 56) { // 56 es el tamaño del FAB
                      dx = MediaQuery.of(context).size.width - 56;
                  }

                  if (dy < 0) dy = 0;
                  if (dy > MediaQuery.of(context).size.height - kToolbarHeight - 50) { // Ajusta para la altura del AppBar y del SpeedDial desplegado
                      dy = MediaQuery.of(context).size.height - kToolbarHeight - 50;
                  }

                  position = Offset(dx, dy);
                });
              },
              child: FloatingActionButton(
                onPressed: () => _showCreateDialog(context),
                child: const Icon(Icons.add),
              ), 
            )
          )
        ]
      )
    );
  }

  // Mostrar diálogo para crear un nuevo usuario
  void _showCreateDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      builder: (context) {
        // Formulario para crear usuario
        return Dialog(
          // title: const Text('Crear Usuario', style: TextStyle(fontSize: 33.0)),
          // contentPadding: EdgeInsets.zero,  // Elimina el padding por defecto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0), 
            decoration: BoxDecoration( 
              color: Colors.white, 
              borderRadius: BorderRadius.circular(15.0), 
              boxShadow: [ 
                BoxShadow( 
                  color: Colors.grey.withOpacity(0.5), 
                  spreadRadius: 2, 
                  blurRadius: 5, 
                  offset: const Offset(0, 3), 
                ), 
              ], 
            ),
            child: SingleChildScrollView(
              child: Container(
                // margin: const EdgeInsets.all(70),  // Aplica margen
                margin: const EdgeInsets.fromLTRB(100, 20, 90, 50),  // Aplica margen
                // width: 600,
                child: FormBuilder(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        name: 'id',
                        style: const TextStyle(fontSize: 30.0),
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Asignar ID',
                          labelFrontSize: 30.5, // Tamaño de letra personalizado
                          hintext: 'USER o ADMIN-0000',
                          hintFrontSize: 25.0,
                          icono: const Icon(Icons.perm_identity_outlined,size: 30.0),
                        ),
                        // validator: FormBuilderValidators.required(),
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
              
                      FormBuilderTextField(
                        name: 'cedula',
                        style: const TextStyle(fontSize: 30.0),
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Cedula',
                          labelFrontSize: 30.5,
                          hintext: '000-0000000-0',
                          hintFrontSize: 25.0,
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
                        style: const TextStyle(fontSize: 30.0),
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Nombre Completo',
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
                          labeltext: 'Usuario',
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
                          labeltext: 'Email',
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
                        obscureText: true,
                        style: const TextStyle(fontSize: 30.0),
                        // controller: passwordController,
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Contraseña',
                          labelFrontSize: 30.5,
                          hintext: '******',
                          hintFrontSize: 25.0,
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
                        style: const TextStyle(fontSize: 30.0),
                        decoration: InputDecorations.inputDecoration(
                          labeltext: 'Fecha de Ingreso',
                          labelFrontSize: 30.5,
                          icono: const Icon(Icons.calendar_month_outlined, size: 30.0)
                        ),
                        validator: FormBuilderValidators.required(),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode()); // Cierra el teclado al hacer clic
                          await _showDatePicker(); // Muestra el DatePicker
                        },
                      ),
            
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
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              if(formKey.currentState!.saveAndValidate()){
                                final formData = formKey.currentState!.value;
                                final newIdUser = formData['id'];

                                Usuarios? existingUser = await _apiServiceUser.getOneUsuario(newIdUser);

                                if (existingUser != null) {
                                  showDialog(
                                    context: parentContext, 
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('ID de Usuario ya existente', style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold)),
                                        contentPadding: EdgeInsets.zero,
                                        content: Container(
                                          margin: const EdgeInsets.fromLTRB(90, 20, 90, 50),
                                          child: Text('El ID. $newIdUser ya está en uso. Por favor ingrese otro.', style: const TextStyle(fontSize: 28.0))
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                                            },
                                            child: const Text('Aceptar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      );
                                    }
                                  );
                                  return;
                                }

                                Usuarios nuevoUsuario = Usuarios(
                                  idUsuarios: newIdUser,
                                  cedula: formData['cedula'],
                                  nombreApellido: formData['nombre'],
                                  usuario1: formData['usuario'],
                                  email: formData['email'],
                                  passwords: formData['password'], 
                                  fechaCreacion: formData['fechaCreacion'],
                                  // fechaCreacion: DateFormat("yyyy-MM-dd").format(DateTime.now()), // Fecha actual
                                  rol: formData['rol'], 
                                );

                                // Llamar al servicio para crear el usuario
                                // Guardar el nuevo usuario
                                try {
                                  await _apiServiceUser.createUsuario(nuevoUsuario);
                                  Navigator.of(parentContext).pop();
                                  _refreshUsuarios();
                                } catch (e) {
                                  print('Error al crear usuario: $e');
                                }
                              }
                            }, 
                            child: const Text('Guardar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                          TextButton( 
                            onPressed: () { 
                              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo 
                            }, 
                            child: const Text('Cancelar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)), 
                          )
                        ]
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
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
                    )
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

                  // Actualizar usuario
                  try {
                    await _apiServiceUser.updateUsuario(userUpload.idUsuarios, usuarioActualizado);
                    Navigator.of(context).pop();
                    _refreshUsuarios();
                  } catch (e) {
                    print('Error al actualizar usuario: $e');
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
                // Eliminar usuario
                try {
                  await _apiServiceUser.deleteUsuario(userDelete.idUsuarios);
                  Navigator.of(context).pop();
                  _refreshUsuarios();
                } catch (e) {
                  print('Error al eliminar usuario: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
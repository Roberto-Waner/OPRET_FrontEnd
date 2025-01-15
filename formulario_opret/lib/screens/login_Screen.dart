import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formulario_opret/models/login.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/pregunta_screen_navBar.dart';
// import 'package:formulario_opret/models/login_Admin.dart';
import 'package:formulario_opret/screens/interfaz_User/Empleado_screen.dart';
import 'package:formulario_opret/screens/presentation_screen.dart';
import 'package:formulario_opret/services/login_services_token.dart';
import 'package:formulario_opret/widgets/input_decoration.dart';
import 'dart:convert'; // Import para decodificar el JWT

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controladores para filtrar el nombre de usuario y el email
  final TextEditingController _filtrarUsuarioController = TextEditingController();
  final TextEditingController _filtrarEmailController = TextEditingController();
  final TextEditingController _filtrarId = TextEditingController();
  // final TextEditingController _filtrarCedula = TextEditingController();

  final ApiServiceToken _serviceToken = ApiServiceToken('http://wepapi.somee.com',false);
  String myToken ="";
  bool _isLoading = false;
  bool _obscureText = true;

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

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String userName = _userController.text.trim();
    String password = _passwordController.text.trim();

    // Modelos de login
    Login login = Login(userName: userName, password: password);

    try{
      String token = await _serviceToken.loginUser(login);
      myToken = token;
      redireccionPerRoles();

    }catch (e) {
      // _showSnackBar('An error occurred. Please try again later.');
      _showErrorDialog(context, 'Ha ocurrido un error. Por favor intentelo mas tarde.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void redireccionPerRoles(){
    if (myToken != ""){
      // Decodificar el token JWT para obtener los claims
      Map<String, dynamic> decodedToken = _parseJwt(myToken);
      String role = decodedToken['rol'];
      String userNameEmpl = decodedToken['usuario'];
      String email = decodedToken['email'];
      String id = decodedToken['id'];
      // String cedula = decodedToken['cedula'];

      _filtrarUsuarioController.text = userNameEmpl;
      _filtrarEmailController.text = email;
      _filtrarId.text = id;
      // _filtrarCedula.text = cedula;

      if (role == 'Administrador'){
        _showSuccessDialog(context);

        // Si el rol es Administrador, redirige a la pantalla de administrador
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PreguntaScreenNavbar(
              filtrarUsuarioController: _filtrarUsuarioController,
              filtrarEmailController: _filtrarEmailController,
              filtrarId: _filtrarId,
              // filtrarCedula: _filtrarCedula
            ))
          );
          
        });
      } else {
        _showSuccessDialog(context);
        // Si el rol es falso, redirige a la pantalla de empleado
        Future.delayed(const Duration(seconds: 2), () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmpleadoScreens(
                filtrarUsuarioController: _filtrarUsuarioController,
                filtrarEmailController: _filtrarEmailController,
                filtrarId: _filtrarId,
                // filtrarCedula: _filtrarCedula
              )
            )
          );
        });
      } 

    } else {
      // Manejar el error de login
      // _showSnackBar('Credenciales incorrectas.');
      _showErrorDialog(context, 'Credenciales incorrectas.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parseJwt(String token){
    final parts = token.split('.');
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    return json.decode(utf8.decode(payload));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // cuadro de acceso exito
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
                  'Ha iniciado Sesión',
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

  // cuadro de error
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation; // Obtener orientación

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            cajaverde(size), 
            // buttonBack(size),
            ventanalogin(size, context, orientation),
            if (_isLoading)
              Center(
                // child: CircularProgressIndicator(),
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
              )
          ],
        ),
      ),
    );
  }

  Container cajaverde(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromRGBO(1, 135, 76, 1),
          Color.fromRGBO(3, 221, 127, 1),
        ]),
      ),
      width: double.infinity,
      // height: size.height * 0.54,
      height: double.infinity,
    );
  }

  Widget logoInsideLogin(Size size) {
    return Container(
      width: size.width * 0.3, // Ajuste del ancho basado en el tamaño de la pantalla (30% del ancho)
      height: size.height * 0.2, // Ajuste del alto basado en el tamaño de la pantalla (20% del alto)
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // El logo estará dentro de un contenedor circular
        color: Color.fromRGBO(217, 217, 217, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(50.0), // Margen dentro del logo
        child: Image.asset(
          'assets/Logo/Logo_Metro_transparente.png',
          fit: BoxFit.contain, // El logo se ajustará manteniendo su aspecto original
        ),
      ),
    );
  }

  Container ventanalogin(Size size, BuildContext context, Orientation orientation) {
    if(_serviceToken.isLoggedFuncion()){
      return Container();
    }else{
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 50),
              Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.18),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                width: double.infinity,
                height: size.height * (orientation == Orientation.portrait ? 0.85 : 0.96), // Ajuste según la orientación
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 252, 252, 252),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(5, 20),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      logoInsideLogin(size),
                      const SizedBox(height: 30),
                      const Text('Inicio Sesión', style: TextStyle(fontSize: 54)),
                      const SizedBox(height: 30),
                      _loginForm(size),
                      const SizedBox(height: 50),
                      _loginButton(size)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // const Text('Olvide la contraseña', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      );
    }
  }

  Form _loginForm(Size size) {
    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          TextFormField(
            controller: _userController,
            autocorrect: true,
            decoration: InputDecorations.inputDecoration(
              hintext: 'Ingrese el Usuario',
              hintFrontSize: 30.0,
              labeltext: 'Nombre Usuario',
              labelFrontSize: 30.5,
              icono: const Icon(Icons.account_circle, size: 30.0),
              errorSize: 20
            ),
            style: const TextStyle(fontSize: 30.0),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return const Text(
                  'Por favor ingrese su nombre de usuario',
                  style: TextStyle(fontSize: 20.0), // Ajusta el tamaño del texto
                ).data;
              }

              return null;
            },
          ),
          
          const SizedBox(height: 30),
          TextFormField(
            autocorrect: false,
            obscureText: _obscureText,
            controller: _passwordController,
            decoration: InputDecorations.inputDecoration(
              hintext: '******',
              hintFrontSize: 30.0,
              labeltext: 'Contraseña',
              labelFrontSize: 30.5,
              icono: const Icon(Icons.lock_clock_outlined, size: 30.0),
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
              if (value == null || value.isEmpty) {
                return const Text(
                  'La contraseña debe ser mayor o igual a los 6 caracteres',
                  style: TextStyle(fontSize: 20.0), // Ajusta el tamaño del texto
                ).data;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Center _loginButton(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
        children: [
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(1, 135, 76, 1), // Color de fondo del primer botón
              foregroundColor: const Color.fromARGB(255, 254, 255, 255), // Color del texto
              padding: const EdgeInsets.symmetric(horizontal: 138, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            child: const Text(
              'Ingresar',
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const SizedBox(height: 20),

          // boton de retroceder de seccion
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PresentationScreen(
                  filtrarUsuarioController: _filtrarUsuarioController,
                  filtrarEmailController: _filtrarEmailController,
                  filtrarId: _filtrarId,
                  // filtrarCedula: _filtrarId,
                ))
              );
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(1, 135, 76, 1), // Color de fondo del primer botón
              foregroundColor: const Color.fromARGB(255, 254, 255, 255), // Color del texto
              padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
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
                    fontSize: 40, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ]
      )      
    );
  }
}
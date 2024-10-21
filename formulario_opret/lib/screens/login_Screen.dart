import 'package:flutter/material.dart';
import 'package:formulario_opret/models/login.dart';
// import 'package:formulario_opret/models/login_Admin.dart';
import 'package:formulario_opret/screens/interfaz_Admin/administrador_screen.dart';
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
  final TextEditingController _filtrarCedula = TextEditingController();

  final ApiServiceToken _serviceToken = ApiServiceToken('https://10.0.2.2:7190',false);
  String myToken ="";
  bool _isLoading = false;

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
      _showSnackBar('An error occurred. Please try again later.');
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
      String cedula = decodedToken['cedula'];

      _filtrarUsuarioController.text = userNameEmpl;
      _filtrarEmailController.text = email;
      _filtrarId.text = id;
      _filtrarCedula.text = cedula;

      if (role == 'Administrador'){
        // Si el rol es Administrador, redirige a la pantalla de administrador
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdministradorScreen(
            filtrarUsuarioController: _filtrarUsuarioController,
            filtrarEmailController: _filtrarEmailController,
            filtrarId: _filtrarId,
            filtrarCedula: _filtrarCedula
          ))
        );
      } else {
        // Si el rol es falso, redirige a la pantalla de empleado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmpleadoScreens(
              filtrarUsuarioController: _filtrarUsuarioController,
              filtrarEmailController: _filtrarEmailController,
              filtrarId: _filtrarId,
              filtrarCedula: _filtrarCedula
            )
          )
        );
      } 

    } else {
      // Manejar el error de login
      _showSnackBar('Credenciales incorrectas.');
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
            buttonBack(size),
            ventanalogin(size, context, orientation),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
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

  Positioned buttonBack(Size size) {
    return Positioned( //ajuste de ubicacion del icono
      top: size.height * 0.05,
      right: size.width * 0.88,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: size.height * 0.05,              
        ), 
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PresentationScreen(
              filtrarUsuarioController: _filtrarUsuarioController,
              filtrarEmailController: _filtrarEmailController,
              filtrarId: _filtrarId,
              filtrarCedula: _filtrarId,
            ))
          );
        },
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
              const SizedBox(height: 50),
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
                      const Text('Inicio Sesion', style: TextStyle(fontSize: 54)),
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: _userController,
            autocorrect: true,
            decoration: InputDecorations.inputDecoration(
              hintext: 'User o Admin',
              hintFrontSize: 30.0,
              labeltext: 'Nombre Usuario',
              labelFrontSize: 30.5,
              icono: const Icon(Icons.account_circle, size: 30.0)
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
            obscureText: true,
            controller: _passwordController,
            decoration: InputDecorations.inputDecoration(
              hintext: '******',
              hintFrontSize: 30.0,
              labeltext: 'Contraseña',
              labelFrontSize: 30.5,
              icono: const Icon(Icons.lock_clock_outlined, size: 30.0)
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

  MaterialButton _loginButton(Size size) {
    return MaterialButton(
      minWidth: double.infinity,
      height: size.height * 0.08,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      color: const Color.fromARGB(255, 4, 111, 25),
      onPressed: _login,
      child: Text(
        'Ingresar',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.height * 0.035,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formulario_opret/models/login.dart';
import 'package:formulario_opret/screens/forgotPassword_screen.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/pregunta_screen_navBar.dart';
// import 'package:formulario_opret/models/login_Admin.dart';
import 'package:formulario_opret/screens/interfaz_User/welcome_screen.dart';
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

  final ApiServiceToken _serviceToken = ApiServiceToken('https://10.0.2.2:7190',false);
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
        Future.delayed(const Duration(seconds: 1), () {
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
        Future.delayed(const Duration(seconds: 1), () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                filtrarUsuarioController: _filtrarUsuarioController,
                filtrarEmailController: _filtrarEmailController,
                filtrarId: _filtrarId,
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
  }

  void _showErrorDialog (BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
    showDialog(
      context: context,
      builder: (context) {
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
                const Icon(Icons.error_outline_sharp, color: Color.fromARGB(255, 181, 3, 3), size: 80.0),
                const SizedBox(height: 20),
                const Text(
                  'Error!',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  message,
                  style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Flex(
                  direction: isTabletDevice ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {Navigator.of(context).pop();},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text('Ok', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                    )
                  ],
                )
              ]
            )
          )
        );
      }
    );
  }

  void _showWarning (BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
    showDialog(
        context: context,
        builder: (context) {
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
                        const Icon(Icons.security, color: Color.fromARGB(255, 0, 44, 62), size: 60.0),
                        const SizedBox(height: 20),
                        const Text(
                          'Haz olvidado la Contraseña!!!',
                          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          message,
                          style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        Flex(
                          direction: isTabletDevice ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text('Cancelar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                            ),

                            const SizedBox(height: 10.0, width: 10.0),

                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ForgotpasswordScreen(
                                      filtrarUsuarioController: _filtrarUsuarioController,
                                      filtrarEmailController: _filtrarEmailController,
                                      filtrarId: _filtrarId,
                                      // filtrarCedula: _filtrarId,
                                    ))
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text('Continuar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 184, 135, 0)))
                            ),
                          ],
                        )
                      ]
                  )
              )
          );
        }
    );
  }

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletWidth = size.width > 600;
    final isTabletHeight = size.height > 800;
    return isTabletWidth && isTabletHeight;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletDevice = isTablet(context);

    return ScreenUtilInit(
      designSize: const Size(360, 740),
      builder: (context, child) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              cajaverde(size),
              // buttonBack(size),
              ventanalogin(isTabletDevice, context),
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

  Widget logoInsideLogin(bool isTabletDevice) {
    return Container(
      width: isTabletDevice ? 0.3.sw : 0.3.sw, // Ajuste del ancho basado en el tamaño de la pantalla (30% del ancho)
      height: isTabletDevice ? 0.2.sh : 0.2.sh, // Ajuste del alto basado en el tamaño de la pantalla (20% del alto)
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // El logo estará dentro de un contenedor circular
        color: Color.fromRGBO(217, 217, 217, 1),
      ),
      child: Padding(
        padding: isTabletDevice ? const EdgeInsets.all(50.0) : const EdgeInsets.all(30.0), // Margen dentro del logo
        child: Image.asset(
          'assets/Logo/Logo_Metro_transparente.png',
          fit: BoxFit.contain, // El logo se ajustará manteniendo su aspecto original
        ),
      ),
    );
  }

  Container ventanalogin(bool isTabletDevice, BuildContext context) {
    if(_serviceToken.isLoggedFuncion()){
      return Container();
    }else{
      return Container(
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 50),
              Container(
                // padding: EdgeInsets.symmetric(horizontal: isTabletHeight ? 0.18 : 0.10),
                padding: isTabletDevice ? EdgeInsets.symmetric(horizontal: 0.07.sh) : EdgeInsets.symmetric(horizontal: 0.04.sh),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                width: double.infinity,
                // height: size.height * (orientation == Orientation.portrait ? 0.85 : 0.96), // Ajuste según la orientación
                height: isTabletDevice ? 0.92.sh : 0.92.sh,
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
                      // const SizedBox(height: 100),
                      SizedBox(height: isTabletDevice ? 80.h : 80.h),
                      logoInsideLogin(isTabletDevice),
                      SizedBox(height: isTabletDevice ? 30.h : 10.h),
                      Text('Inicio Sesión', style: TextStyle(fontSize: isTabletDevice ? 20.sp : 20.sp)),
                      SizedBox(height: isTabletDevice ? 30.h : 10.h),
                      _loginForm(isTabletDevice),
                      SizedBox(height: isTabletDevice ? 25.h : 20.h),
                      _loginButton(isTabletDevice)
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

  Form _loginForm(bool isTabletDevice) {
    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          TextFormField(
            controller: _userController,
            autocorrect: true,
            decoration: InputDecorations.inputDecoration(
              hintext: 'Ingrese el Usuario',
              hintFrontSize: isTabletDevice ? 10.sp : 10.sp,
              labeltext: 'Nombre Usuario',
              labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
              icono: Icon(Icons.account_circle, size: isTabletDevice ? 15.sp : 15.sp),
              errorSize: 20
            ),
            style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Text(
                  'Por favor ingrese su nombre de usuario',
                  style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp), // Ajusta el tamaño del texto
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
                hintFrontSize: isTabletDevice? 10.sp : 10.sp,
              labeltext: 'Contraseña',
                labelFrontSize: isTabletDevice ? 15.sp : 15.sp,
              icono: Icon(Icons.lock_clock_outlined, size: isTabletDevice ? 15.sp : 15.sp,),
              suffIcon: IconButton(
                onPressed: _togglePasswordVisibility, 
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  size: isTabletDevice ? 15.sp : 15.sp,
                )
              ),
              errorSize: 20
            ),
            style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Text(
                  'La contraseña debe ser mayor o igual a los 6 caracteres',
                  style: TextStyle(fontSize: isTabletDevice ? 15.sp : 15.sp), // Ajusta el tamaño del texto
                ).data;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showWarning(context, 'A continuación iremos restablecer la contraseña. ¿Estás seguro de que deseas continuar?'),
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ForgotpasswordScreen(
                  //     filtrarUsuarioController: _filtrarUsuarioController,
                  //     filtrarEmailController: _filtrarEmailController,
                  //     filtrarId: _filtrarId,
                  //     // filtrarCedula: _filtrarId,
                  //   ))
                  // );
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
                  shadowColor: Colors.transparent, // Evitar sombras que cubran el degradado
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0)
                ),
                child: Text(
                  'Olvidé la contraseña',
                  style: TextStyle(
                    fontSize: isTabletDevice ? 10.sp : 17.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0)
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ]
          )
        ],
      ),
    );
  }

  Center _loginButton(bool isTabletDevice) {
    return Center(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
        children: [
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(1, 135, 76, 1), // Color de fondo del primer botón
              foregroundColor: const Color.fromARGB(255, 254, 255, 255), // Color del texto
              padding: EdgeInsets.symmetric(
                horizontal: isTabletDevice ? 0.235.sw : 0.235.sw,
                vertical: isTabletDevice ? 10.h : 11.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            child: Text(
              'Ingresar',
              style: TextStyle(
                  fontSize: isTabletDevice ? 17.sp : 17.sp,
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
              padding: EdgeInsets.symmetric(
                horizontal: isTabletDevice ? 0.15.sw : 0.138.sw,
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
                  Icons.arrow_back_ios_new_rounded,
                  size: isTabletDevice ? 14.sp : 17.sp,
                ),
                const SizedBox(width: 5), // Espacio entre el ícono y el texto
                Text(
                  'Volver a inicio',
                  style: TextStyle(
                      fontSize: isTabletDevice ? 17.sp : 17.sp,
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
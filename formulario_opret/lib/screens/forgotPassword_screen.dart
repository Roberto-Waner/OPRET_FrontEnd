import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formulario_opret/models/resertPassword.dart';
import 'package:formulario_opret/screens/presentation_screen.dart';
import 'package:formulario_opret/screens/resertPassword_screen.dart';
import 'package:formulario_opret/services/resertPassword_services.dart';

class ForgotpasswordScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;

  const ForgotpasswordScreen({
    super.key,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    required this.filtrarId,
  });

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final _formkey = GlobalKey<FormBuilderState>();
  final ApiResertPasswordServices _apiResertPassServ = ApiResertPasswordServices('https://10.0.2.2:7190');

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletWidth = size.width > 600;
    final isTabletHeight = size.height > 800;
    return isTabletWidth && isTabletHeight;
  }

  Future<void> _requestPassword() async {
  if (_formkey.currentState!.saveAndValidate()) {
      final data = _formkey.currentState!.value;

      Request insertRequest = Request(email: data['email']);

      try{
        final response = await _apiResertPassServ.postEmail(insertRequest);

        if (response.statusCode == 200) {
          print('✔️ Email enviado con éxito');
          _showSuccessDialog(context, 'Se ha enviado un correo con el código de verificación. \nPor favor, revisa tu bandeja de entrada. \nSi no lo encuentras, revisa la carpeta de spam.');
        } else {
          print('❌ Error al enviar el email');
          _showErrorDialog(context, 'Error al enviar el email. Usuario no encontrado. \nPor favor, intenta de nuevo.');
        }
      } catch (e) {
        print('❌ Error al enviar el email: $e');
        _showErrorDialog(context, 'Error al enviar la solicitud de recuperación de contraseña.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTabletDevice = isTablet(context);

    return ScreenUtilInit(
      designSize: const Size(360, 740),
      builder: (context, child) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF159957),
                Color(0xFF155799),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(5, 20),
              ),
            ],
          ),
          child: Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Padding( // Padding para el contenedor principal
                padding: isTabletDevice ? const EdgeInsets.all(50.0) : const EdgeInsets.all(30.0),
                // padding: const EdgeInsets.all(40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      Container( // Contenedor del logo
                        margin: const EdgeInsets.only(top: 50), // Margen superior del contenedor
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // El logo estará dentro de un contenedor circular
                          color: Color.fromRGBO(255, 254, 254, 1),
                        ),
                        child: Padding(
                          padding: isTabletDevice ? const EdgeInsets.all(50.0) : const EdgeInsets.all(30.0), // Margen dentro del logo
                          // padding: EdgeInsets.all(20.0),
                          child: const Icon(
                            Icons.email_outlined, // Icono de un candado
                            size: 100, // Tamaño del icono
                            color: Color.fromARGB(255, 12, 0, 0), // Color del icono
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      const Text(
                        "Recupera tu cuenta", // Título de la pantalla
                        style: TextStyle(
                          fontSize: 40, // Tamaño de la fuente
                          fontWeight: FontWeight.bold, // Peso de la fuente
                          color: Color.fromARGB(255, 255, 255, 255), // Color de la fuente
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Container( //Para el cuadro blanco
                            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 70),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 252, 252),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(5, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [                      
                                const Text(
                                  "Paso 1: Verifica tu correo", // Título de la pantalla
                                  style: TextStyle(
                                    fontSize: 40, // Tamaño de la fuente
                                    fontWeight: FontWeight.bold, // Peso de la fuente
                                    color: Color.fromARGB(255, 12, 0, 0), // Color de la fuente
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                  
                                FormBuilder(
                                  key: _formkey,
                                  child: Column(
                                    children: [
                                      FormBuilderTextField(
                                        name: 'email',
                                        decoration: InputDecoration(
                                          labelText: 'Correo Electrónico',
                                          labelStyle: TextStyle(fontSize: isTabletDevice ? 15.sp : 13.sp),
                                          hintText: 'Tu@ejemplo.com',
                                          hintStyle: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 138, 138, 138)),
                                          prefixIcon: Icon(Icons.account_circle, size: isTabletDevice ? 15.sp : 15.sp),
                                          border: const OutlineInputBorder(),
                                          enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(color: Color.fromARGB(255, 39, 99, 41)),
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromARGB(255, 12, 0, 0), // Color del borde
                                            ),
                                          ),
                                          errorStyle: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp,),
                                        ),
                                        style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 1, 1, 1)),
                                        keyboardType: TextInputType.emailAddress, // Tipo de teclado
                                        validator: (value){
                                          // expresion regular
                                          String pattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$';
                                          RegExp regExp = RegExp(pattern);
                                          return regExp.hasMatch(value ?? '')
                                            ? null
                                            : 'Ingrese un correo electronico valido';
                                        },
                                      ),
                                
                                      const SizedBox(height: 20), // Separación entre el campo de texto y el botón
                          
                                      Text(
                                        "Te enviaremos un código de verificación a este correo. Si todo sale bien entonces iremos al paso 2.", // Descripción de la pantalla
                                        style: TextStyle(
                                          fontSize: isTabletDevice ? 10.5.sp : 10.sp, // Tamaño de la fuente
                                          color: const Color.fromARGB(255, 138, 138, 138), // Color de la fuente
                                        ),
                                        textAlign: TextAlign.center, // Alineación del texto
                                      ),
                                      const SizedBox(height: 10),
                                
                                      Container(
                                        padding: isTabletDevice ?  EdgeInsets.symmetric(horizontal: 1.h, vertical: 10.w) : EdgeInsets.symmetric(horizontal: 5.h, vertical: 10.w),
                                        // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                        margin: const EdgeInsets.only(top: 30),
                                        decoration: BoxDecoration(
                                          /*gradient: const LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 16, 110, 63),
                                              Color(0xFF155799),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),*/
                                          color: const Color.fromARGB(255, 16, 110, 63),
                                          borderRadius: BorderRadius.circular(100),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: isTabletDevice ? 17.sp : 17.sp,
                                              offset: const Offset(5, 10),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () => _requestPassword(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
                                            shadowColor: Colors.transparent, // Evitar sombras que cubran el degradado
                                            foregroundColor: const Color.fromARGB(255, 254, 255, 255),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(100)), // Borde redondeado
                                            ),
                                          ),
                                          child: Text(
                                            'Enviar Código de Recuperación',
                                            style: TextStyle(
                                              fontSize: isTabletDevice ? 15.5.sp : 17.sp,
                                              fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                
                                      Container(
                                        // padding: isTabletDevice ?  EdgeInsets.symmetric(horizontal: 60.h, vertical: 10.w) : EdgeInsets.symmetric(horizontal: 37.h, vertical: 15.w),
                                        padding: isTabletDevice ?  EdgeInsets.symmetric(horizontal: 73.h, vertical: 1.w) : EdgeInsets.symmetric(horizontal: 5.h, vertical: 10.w),
                                        margin: const EdgeInsets.only(top: 30),
                                        decoration: BoxDecoration(
                                          /* gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF155799),
                                              Color.fromARGB(255, 16, 110, 63),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),*/
                                          color: const Color.fromRGBO(255, 254, 254, 1),
                                          borderRadius: BorderRadius.circular(100),
                                          /*boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: isTabletDevice ? 17.sp : 17.sp,
                                              offset: const Offset(5, 10),
                                            ),
                                          ],*/
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => PresentationScreen(
                                                filtrarUsuarioController: widget.filtrarUsuarioController,
                                                filtrarEmailController: widget.filtrarEmailController,
                                                filtrarId: widget.filtrarId,
                                              ))
                                            );
                                          }, 
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
                                            shadowColor: Colors.transparent, // Evitar sombras que cubran el degradado
                                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(100)), // Borde redondeado
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el espacio
                                            children: [
                                              const Icon(
                                                Icons.arrow_back_ios_new_rounded,
                                                //size: isTabletDevice ? 14.sp : 17.sp,
                                              ),
                                              const SizedBox(width: 5), // Espacio entre el ícono y el texto
                                              Text(
                                                'Volver a inicio',
                                                style: TextStyle(
                                                  //fontSize: isTabletDevice ? 17.sp : 17.sp,
                                                  fontSize: isTabletDevice ? 15.sp : 17.sp,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ]
          ),
        ),
      ),
    );
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
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ResertpasswordScreen(
                          filtrarUsuarioController: widget.filtrarUsuarioController,
                          filtrarEmailController: widget.filtrarEmailController,
                          filtrarId: widget.filtrarId),
                      )
                    );
                  }, 
                  child: const Text('OK', style: TextStyle(fontSize: 18.0)),
                )
              ]
            )
          )
        );
      }
    );
  }

  // para mostrar los errores
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
}
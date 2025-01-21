import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formulario_opret/screens/login_Screen.dart';
import 'package:formulario_opret/screens/new_User.dart';

class PresentationScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  // final TextEditingController filtrarCedula;

  const PresentationScreen({
    required this.filtrarId,
    // required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    super.key
  });

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletWidth = size.width > 600; //En caso de ser una table
    final isTabletHeight = size.height > 920;

    return ScreenUtilInit(
      designSize: const Size(360, 740),
      builder: (context, child) => Scaffold(
        body: Container(
          decoration: const BoxDecoration( //para el fondo
            color: Colors.white,
          ),
          child: Stack(
            children: [
              // Fondo de la imagen
              FractionallySizedBox(
                widthFactor: 1.0, // Ocupa todo el ancho
                // heightFactor: 0.5, // Ocupa la mitad de la pantalla
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Fondo/metro1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Ajustando el contenido principal
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.05),
                      // Contenedor del logo
                      Center(
                        child: FractionallySizedBox(
                          // widthFactor: MediaQuery.of(context).orientation == Orientation.portrait ? 0.55 : 0.23, // Ajusta el tamaño del logo según la orientación
                          widthFactor: isTabletWidth && isTabletHeight ? 0.75 : 0.70,
                          child: AspectRatio(
                            aspectRatio: 1.0, // Mantener una proporción 1:1
                            child: Container(
                              decoration: BoxDecoration(
                                // borderRadius: BorderRadius.circular(200),
                                borderRadius: isTabletWidth && isTabletHeight ? BorderRadius.circular(300) : BorderRadius.circular(200),
                                color: const Color.fromARGB(255, 252, 249, 249),
                              ),
                              child: Padding(
                                padding: isTabletWidth && isTabletHeight ? const EdgeInsets.all(60.0) : const EdgeInsets.all(40.0),
                                child: Image.asset(
                                  'assets/Logo/Logo_Metro_transparente.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // const Spacer(flex: 1), // Espacio flexible entre el logo y los botones
                      // SizedBox(height: size.height * 0.05),
                      SizedBox(height: isTabletWidth && isTabletHeight ? 70.h : 90.h),
                      // Caja verde con bordes redondeados
                      Container(
                        // width: size.width * 0.9, // Ancho mayor al 100% del tamaño de la pantalla
                        width: isTabletWidth && isTabletHeight ? 0.9.sw : 0.9.sw,
                        // margin: EdgeInsets.only(top: 140.h),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(1, 135, 76, 1),
                          // borderRadius: BorderRadius.circular(100)
                          borderRadius: isTabletWidth && isTabletHeight ? BorderRadius.circular(170) : BorderRadius.circular(100)
                          // borderRadius: BorderRadius.only(
                          //   topRight: Radius.circular(50),
                          //   topLeft: Radius.circular(50),
                          // ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical:  50, horizontal: 20),
                        child: Column(
                          children: [
                            // Botón de registrar
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewUser(
                                      filtrarUsuarioController: widget.filtrarUsuarioController,
                                      filtrarEmailController: widget.filtrarEmailController,
                                      filtrarId: widget.filtrarId,
                                      // // filtrarCedula: widget.filtrarCedula,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  // horizontal: size.width * 0.2, // Tamaño adaptable
                                  // vertical: size.height * 0.02,
                                  horizontal: isTabletWidth && isTabletHeight ? 0.2.sw : 0.11.sw,
                                  vertical: isTabletWidth && isTabletHeight ? 10.h : 11.h,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80),
                                ),
                              ),
                              child: Text(
                                'Registrar',
                                style: TextStyle(
                                  fontSize: isTabletWidth && isTabletHeight ? 20.sp : 20.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20), // Espacio entre botones

                            // Botón de iniciar sesión
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  // Tamaño adaptable
                                  horizontal: isTabletWidth && isTabletHeight ? 0.15.sw : 0.06.sw,
                                  vertical: isTabletWidth && isTabletHeight ? 10.h : 11.h,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80),
                                ),
                              ),
                              child: Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: isTabletWidth && isTabletHeight ? 20.sp : 20.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'Encuesta Percepción del Servicio',
                              style: TextStyle(
                                fontSize: isTabletWidth && isTabletHeight ? 14.sp : 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        ),
                      ),
                      // const Spacer(flex: 2),
                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
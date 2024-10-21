import 'package:flutter/material.dart';
import 'package:formulario_opret/screens/login_Screen.dart';
import 'package:formulario_opret/screens/new_User.dart';

class PresentationScreen extends StatelessWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const PresentationScreen({
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration( //para el fondo 
          color: Colors.white,
        ),
        child: Stack(         
          children: [
            FractionallySizedBox(
              widthFactor: 1.0, // Ocupa todo el ancho
              heightFactor: 0.5, // Ocupa la mitad de la pantalla
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Fondo/metro1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                width: size.width, // Ancho mayor al 100% del tamaño de la pantalla
                margin: EdgeInsets.only(top: size.height * 0.25),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(1, 135, 76, 1),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Logo ajustado al tamaño de la pantalla
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: MediaQuery.of(context).orientation == Orientation.portrait ? 0.35 : 0.23, // Ajusta el tamaño del logo según la orientación
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
                    ),
                    const Spacer(flex: 1), // Espacio flexible entre el logo y los botones

                    // Botón de registrar
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewUser(
                              filtrarUsuarioController: filtrarUsuarioController,
                              filtrarEmailController: filtrarEmailController,
                              filtrarId: filtrarId,
                              filtrarCedula: filtrarCedula,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.2, // Tamaño adaptable
                          vertical: size.height * 0.02,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                      ),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(
                          fontSize: 25,
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
                          horizontal: size.width * 0.15, // Tamaño adaptable
                          vertical: size.height * 0.02,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
// import 'package:formulario_opret/screens/navbar/editar_screen.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/pregunta_screen_navBar.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/registro_Empldo.dart';
import 'package:formulario_opret/screens/interfaz_Admin/report_screen.dart';
import 'package:formulario_opret/screens/interfaz_Admin/settings_screen.dart';
import 'package:formulario_opret/services/login_services_token.dart';
// import 'package:formulario_opret/services/admin_services.dart';

class Navbar extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  // final TextEditingController filtrarCedula;

  const Navbar({
    super.key,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    required this.filtrarId,
    // required this.filtrarCedula,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  @override
  Widget build(BuildContext context) {
    final ApiServiceToken _apiServiceToken = ApiServiceToken('http://wepapi.somee.com',false);

    return Drawer(
      // Creación del menú desplegable
      child: ListView(
        padding: EdgeInsets.zero, 
        children: <Widget>[
          Container(
            height: 250,
            child: UserAccountsDrawerHeader(
              accountName: Text(
                widget.filtrarUsuarioController.text,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
              accountEmail: Text(
                widget.filtrarEmailController.text,
                style: const TextStyle(
                  fontSize: 25
                ),
              ),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset('assets/figuras/agregarfotos.png'),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(1, 135, 77, 0.344),
                image: DecorationImage(
                    image: AssetImage('assets/Fondo/metro2.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Color.fromRGBO(1, 135, 77, 0.344), BlendMode.srcATop)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.poll_outlined, size: 30.0),
            title: const Text(
              'Sección de Pregunta Encuesta',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PreguntaScreenNavbar(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  // // filtrarCedula: widget.filtrarCedula,
                )),
              );
              // Navigator.of(context).pop();
            }
          ),
          ListTile(
            leading: const Icon(Icons.app_registration, size: 30.0),
            title: const Text(
              'Registro de Usuarios',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistroEmpl(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  // // filtrarCedula: widget.filtrarCedula,
                ))
              );
            }
          ),
          
          ListTile(
            leading: const Icon(Icons.analytics, size: 30.0),
            title: const Text(
              'Reportes',
              style: TextStyle(fontSize: 20.0), // Aquí se cambia el tamaño del texto
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  // // filtrarCedula: widget.filtrarCedula,
                ))
              );
            }
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, size: 30.0),
            title: const Text(
              'Ajustes',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  // // filtrarCedula: widget.filtrarCedula,
                ))
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, size: 30.0),
            title: const Text(
              'Cerrar Sesion',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () async {
              await _apiServiceToken.logout(context); // Llama a la función para cerrar sesión
            },
          ),
      ]),
    );
  }
}
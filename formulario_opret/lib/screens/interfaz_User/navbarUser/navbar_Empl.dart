import 'package:flutter/material.dart';
import 'package:formulario_opret/screens/interfaz_User/form_Encuesta_Screen.dart';
import 'package:formulario_opret/screens/interfaz_User/form_hechos_screen.dart';
import 'package:formulario_opret/services/login_services_token.dart';
// import 'package:formulario_opret/screens/interfaz_User/formEncuesta_screen.dart';

class NavbarEmpl extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const NavbarEmpl({
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    super.key,
  });
  // const NavbarEmpl({super.key});

  @override
  State<NavbarEmpl> createState() => _NavbarEmplState();
}

class _NavbarEmplState extends State<NavbarEmpl> {
  @override
  Widget build(BuildContext context) {
    final ApiServiceToken _apiServiceToken = ApiServiceToken('https://10.0.2.2:7190',false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 250,
            child: UserAccountsDrawerHeader(
              accountName: Text(
                widget.filtrarUsuarioController.text,
                style: const TextStyle(
                  fontSize: 30, // Cambia este valor para ajustar el tamaño
                  fontWeight: FontWeight.bold // Puedes cambiar otras propiedades como el peso
                ),
              ), // Mostrar nombre de usuario
              accountEmail: Text(
                widget.filtrarEmailController.text,
                style: const TextStyle(
                  fontSize: 25
                ),
              ), // Mostrar email
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
              'Formularios Realizados',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormHechosScreen(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  filtrarCedula: widget.filtrarCedula,
                )),
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.poll_outlined, size: 30.0),
            title: const Text(
              'Registro Formulario',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormEncuestaScreen(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  filtrarCedula: widget.filtrarCedula,
                )),
              );
            }
          ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.account_circle_outlined, size: 30.0),
          //   title: const Text(
          //     'Perfile',
          //     style: TextStyle(fontSize: 20.0),
          //   ),
          //   onTap: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(builder: (context) => PagEdit(/*idAdmin: data*/))
          //     // );
          //   },
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, size: 30.0),
            title: const Text(
              'Cerrar Sesion',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () async {
              await _apiServiceToken.logout(context); // Llama a la función para cerrar sesión
            }
          ),
        ],
      ),
    );
  }
}
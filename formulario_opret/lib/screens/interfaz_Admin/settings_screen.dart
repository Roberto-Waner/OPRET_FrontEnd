import 'package:flutter/material.dart';
import 'package:formulario_opret/screens/interfaz_Admin/modifyTable_screen.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';

class SettingsScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const SettingsScreen({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final ApiServiceToken _apiServiceToken = ApiServiceToken('https://10.0.2.2:7190',false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(
        filtrarUsuarioController: widget.filtrarUsuarioController,
        filtrarEmailController: widget.filtrarEmailController,
        filtrarId: widget.filtrarId,
        filtrarCedula: widget.filtrarCedula,
      ),

      appBar: AppBar(title: const Text('Pantalla de Ajustes')),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: const Text('Modificar Tablas', style: TextStyle(fontSize: 20.0)),
            leading: const Icon(Icons.table_view, size: 30.0),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>   ModifyTable(
                  filtrarUsuarioController: widget.filtrarUsuarioController,
                  filtrarEmailController: widget.filtrarEmailController,
                  filtrarId: widget.filtrarId,
                  filtrarCedula: widget.filtrarCedula,
                ))
              );
            }
          )
        ],
      ),
    );
  }
}
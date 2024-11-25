import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_FormRegistro.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/form_Registro_services.dart';

class ReportFormulario extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  final TextEditingController filtrarCedula;

  const ReportFormulario({
    super.key,
    required this.filtrarId,
    required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<ReportFormulario> createState() => _ReportFormularioState();
}

class _ReportFormularioState extends State<ReportFormulario> {
  final ApiServiceFormRegistro _apiServiceFormRegistro = ApiServiceFormRegistro('https://10.0.2.2:7190');
  late Future<List<SpFiltrarFormRegistro>> _formRegistroData;
  final TextEditingController searchController = TextEditingController();
  List<SpFiltrarFormRegistro> formFiltrados = [];
  List<SpFiltrarFormRegistro> todosCampForm = [];
  String selectedFilter = 'ID del Usuario'; // Filtro por defecto

  @override
  void initState() {
    super.initState();
    _formRegistroData = Future.value([]);
    _formRegistroData = _apiServiceFormRegistro.getFormRegistro();
    _refreshFormularios();
  }

  Future<void> _refreshFormularios() async {
    final form = await _apiServiceFormRegistro.getFormRegistro();
    setState(() {
      todosCampForm = form;
      formFiltrados = form;
      _formRegistroData = Future.value(form);
    });
  }

  void _filtrarForm(String query) async {
    final queryLower = query.toLowerCase();
    final filtrar = todosCampForm.where((formulario) {
      switch (selectedFilter) {
        case 'ID del Usuario':
          return formulario.sp_IdUsuarios?.toLowerCase().contains(queryLower) ?? false;
        case 'Cedula de Identidad':
          return formulario.sp_Cedula?.toLowerCase().contains(queryLower) ?? false;
        case 'Usuarios':
          return formulario.sp_Usuarios?.toLowerCase().contains(queryLower) ?? false;
        case 'Nombre y Apellido':
          return formulario.sp_NombreApellido?.toLowerCase().contains(queryLower) ?? false;
        case 'Linea':
          return formulario.sp_NombreLinea?.toLowerCase().contains(queryLower) ?? false;
        case 'Estacion':
          return formulario.sp_NombrEstacion?.toLowerCase().contains(queryLower) ?? false;
        default:
          return false;
      }
    }).toList();

    setState(() {
      formFiltrados = filtrar;
    });
  }

  void _limpiarBusqueda() {
    searchController.clear();
    setState(() {
      formFiltrados = todosCampForm;
    });
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
        title: const Text('Tablas de Formularios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30.0),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() {
                _refreshFormularios();
              });
            },
          )
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'filtrar', 
                    initialValue: selectedFilter,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1)),
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por',
                      labelStyle: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold), 
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'ID del Usuario', 
                      'Cedula de Identidad', 
                      'Usuarios', 
                      'Nombre y Apellido', 
                      'Linea', 
                      'Estacion'
                    ].map((filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter)
                    )).toList(),
                    onChanged: (value) => setState(() {
                      selectedFilter = value!;
                    })
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 2,
                  child: FormBuilderTextField(
                    name: 'search',
                    controller: searchController,
                    style: const TextStyle(fontSize: 20.0),
                    decoration: InputDecoration( 
                      labelText: 'Buscar', 
                      labelStyle: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), 
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
                      if (value!.isNotEmpty) { 
                        _filtrarForm(value); 
                      } else { 
                        setState(() { 
                          formFiltrados = []; 
                        }); 
                      } 
                    },
                  ),
                )
              ],
            )
          ),
          Expanded(
            child: FutureBuilder<List<SpFiltrarFormRegistro>>(
              future: _formRegistroData, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }else if (snapshot.hasError){
                  return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
                } else {
                  final formularioData = formFiltrados.isNotEmpty
                        ? formFiltrados
                        : snapshot.data ?? [];

                  return SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: const Text('Reporte de Registros de los Usuarios antes de la Encuesta'),
                      columns: const [
                        DataColumn(label: Text('ID del Usuario', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Cedula de Identidad', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Usuarios', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Nombre y Apellido', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Fecha de form. Realizado', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Hora', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Linea de metro', style: TextStyle(fontSize: 23.0))),
                        DataColumn(label: Text('Estacion de metro', style: TextStyle(fontSize: 23.0))),
                      ],
                      source: FormularioDataSource(formularioData),
                      rowsPerPage: 11, //numeros de filas
                      columnSpacing: 30, //espacios entre columnas
                      horizontalMargin: 50, //para aplicarle un margin horizontal a los campo de la tabla
                      showCheckboxColumn: false, //oculta la columna de checkboxes
                      headingRowColor: WidgetStateProperty.all(Colors.grey[400]), //color del encabezado
                      dataRowMinHeight: 60.0,  // Altura mínima de fila
                      dataRowMaxHeight: 80.0,  // Altura máxima de fila
                      showFirstLastButtons: true,
                    ),
                  );
                }
              }
            ),
          ),
        ]
      )
    );
  }
}

class FormularioDataSource extends DataTableSource {
  final List<SpFiltrarFormRegistro> data;

  FormularioDataSource(this.data);

  @override
  DataRow getRow(int index) {
    final form = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(form.sp_IdUsuarios!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_Cedula!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_Usuarios!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_NombreApellido!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_FechaEncuesta!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_HoraEncuesta!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_NombreLinea!, style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(form.sp_NombrEstacion!, style: const TextStyle(fontSize: 20.0))),
      ]
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
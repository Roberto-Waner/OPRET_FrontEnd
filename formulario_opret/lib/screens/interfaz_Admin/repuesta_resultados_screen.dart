import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_Respuestas.dart';
import 'package:formulario_opret/screens/interfaz_Admin/graphic/graphic_Respuestas_Screen.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/respuestas_services.dart';

class RepuestaResultadosScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;
  // final TextEditingController filtrarCedula;

  const RepuestaResultadosScreen({
    super.key,
    required this.filtrarId,
    // required this.filtrarCedula,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
  });

  @override
  State<RepuestaResultadosScreen> createState() => _RepuestaResultadosScreenState();
}

class _RepuestaResultadosScreenState extends State<RepuestaResultadosScreen> {
  final ApiServiceRespuesta _apiServiceRespuesta =  ApiServiceRespuesta('http://wepapi.somee.com');
  late Future<List<SpFiltrarRespuestas>> _respuestaData;
  final TextEditingController searchController = TextEditingController();
  List<SpFiltrarRespuestas> respuestasFiltrados = [];
  List<SpFiltrarRespuestas> todasLasRespuestas = [];
  String selectedFilter = 'ID del Usuario'; 

  @override
  void initState() {
    super.initState();
    // _respuestaData = Future.value([]);
    _respuestaData = _apiServiceRespuesta.getRespuestas();
    _loadRespuestas();
  }

  Future<void> _loadRespuestas() async {
    final respuestas = await _apiServiceRespuesta.getRespuestas();
    setState(() {
      _respuestaData = Future.value(respuestas); // Actualiza el Future con los datos cargados
      todasLasRespuestas = respuestas; 
      respuestasFiltrados = respuestas;
    });
  }

  void _filtrarRespuestas(String query) async {

    final queryLower = query.toLowerCase();
    final respuestasFiltradasTemp = todasLasRespuestas.where((answer) {
      switch (selectedFilter) {
        case 'ID del Usuario':
          return answer.sp_IdUsuarios?.toLowerCase().contains(queryLower) ?? false;
        // case 'Cedula de Identidad':
        //   return answer.sp_Cedula?.toLowerCase().contains(queryLower) ?? false;
        case 'Usuarios':
          return answer.sp_Usuarios?.toLowerCase().contains(queryLower) ?? false;
        case 'Nombre y Apellido':
          return answer.sp_NombreApellido?.toLowerCase().contains(queryLower) ?? false;
        case 'Numero de Encuesta':
          return answer.sp_NoEncuesta?.toLowerCase().contains(queryLower) ?? false;
        case 'Numero de Seccion':
          return answer.sp_IdSesion?.toString().toLowerCase().contains(queryLower) ?? false;
        case 'Numero de Pregunta':
          return answer.sp_CodPreguntas?.toString().toLowerCase().contains(queryLower) ?? false;
        case 'Numero de Sub-Pregunta':
          return answer.sp_CodSupPreguntas?.toLowerCase().contains(queryLower) ?? false;
        default:
          return false;
      }
    }).toList();

    setState(() {
      respuestasFiltrados = respuestasFiltradasTemp;
    });
  }

  void _limpiarBusqueda() { 
    searchController.clear(); 
    setState(() { 
      respuestasFiltrados = todasLasRespuestas; 
    }); 
  }

  //En caso de ser un table
  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletWidth = size.width > 600;
    final isTabletHeight = size.height > 800;
    return isTabletWidth && isTabletHeight;
  }

  @override
  Widget build(BuildContext context) {
    final isTabletDevice = isTablet(context);

    return ScreenUtilInit(
      designSize: const Size(360, 740),
      builder: (context, child) => Scaffold(
        drawer: Navbar(
          filtrarUsuarioController: widget.filtrarUsuarioController,
          filtrarEmailController: widget.filtrarEmailController,
          filtrarId: widget.filtrarId,
          // // filtrarCedula: widget.filtrarCedula,
        ),
      
        appBar: AppBar(
          title: const Text('Tablas de Respuestas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 30.0),
              tooltip: 'Recargar',
              onPressed: () {
                setState(() {
                  _loadRespuestas();
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
                        // 'Cedula de Identidad',
                        'Usuarios', 
                        'Nombre y Apellido', 
                        'Numero de Encuesta',
                        'Numero de Seccion',
                        'Numero de Pregunta',
                        'Numero de Sub-Pregunta'
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
                        labelStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), 
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
                          _filtrarRespuestas(value); 
                        } else { 
                          setState(() { 
                            respuestasFiltrados = []; 
                          }); 
                        } 
                      },
                    ),
                  ),
                ],
              )
            ),
            Expanded(
              child: FutureBuilder<List<SpFiltrarRespuestas>>(
                future: _respuestaData, 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                        // child: CircularProgressIndicator()
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
                                  /*hasError ? 'Error' : */'Cargando...',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        )
                      );
                  }else if (snapshot.hasError){
                    print('Error al cargar los datos de las respuestas: ${snapshot.error}');
                    return Center(child: Text('"Lo sentimos, no pudimos cargar la información en este momento. \nPor favo, inténtalo nuevamente presionando el (botón Refrescar)"', style: TextStyle(fontSize: isTabletDevice ? 11.sp : 9.sp)));
                  } else {
                    final answerData = respuestasFiltrados.isNotEmpty
                        ? respuestasFiltrados
                        : snapshot.data ?? [];
      
                    return SingleChildScrollView(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.copyWith(
                            bodySmall: TextStyle(
                              fontSize: isTabletDevice ? 9.sp : 9.sp,          // Ajusta el tamaño del número
                              color: Colors.black,    // Cambia el color del texto (ajústalo según tu preferencia)
                              fontWeight: FontWeight.bold, // Hace el texto más visible
                            ),
                          ),
                        ),
                        child: PaginatedDataTable(
                          header: const Text('Reporte de las Respuesta'),
                          columns: [
                            DataColumn(label: Text('ID del Usuario', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Nombre y Apellido', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Usuarios', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('No. Encuesta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Número de Sección', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Número de Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Número de Sub-Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Sub-Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Respuesta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Comentarios', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Justificacion', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                          ], 
                          source: RespuestasDataSource(answerData, isTabletDevice),
                          rowsPerPage: isTabletDevice ? 7 : 5, //numeros de filas
                          columnSpacing: 30, //espacios entre columnas
                          horizontalMargin: 50, //para aplicarle un margin horizontal a los campo de la tabla
                          showCheckboxColumn: false, //oculta la columna de checkboxes
                          headingRowColor: WidgetStateProperty.all(Colors.grey[400]), //color del encabezado
                          dataRowMinHeight: 60.0,  // Altura mínima de fila
                          dataRowMaxHeight: 80.0,  // Altura máxima de fila
                          showFirstLastButtons: true,     
                        ),
                      ),
                    );
                  }
                }
              ),
            ),
            //boton para mostrar los graficos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GraphicRespScreen(data: respuestasFiltrados.isNotEmpty ? respuestasFiltrados : todasLasRespuestas),
                            )
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )
                      ),
                      child: const Text('Ver gráfica')
                    )
                  )
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}

class RespuestasDataSource extends DataTableSource {
  final List<SpFiltrarRespuestas> data;
  final bool isTabletDevice;

  RespuestasDataSource(this.data, this.isTabletDevice);

  @override
  DataRow? getRow(int index) {
    final answer = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        /*
        DataCell(answer.sp_IdUsuarios != null ? Text(answer.sp_IdUsuarios!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_NombreApellido != null ? Text(answer.sp_NombreApellido!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_Usuarios != null ? Text(answer.sp_Usuarios!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_NoEncuesta != null ? Text(answer.sp_NoEncuesta!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(Text(answer.sp_IdSesion.toString(), style: const TextStyle(fontSize: 20.0))),
        DataCell(Text(answer.sp_CodPreguntas.toString(), style: const TextStyle(fontSize: 20.0))),
        DataCell(answer.sp_Preguntas != null ? Text(answer.sp_Preguntas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_CodSupPreguntas != null ? Text(answer.sp_CodSupPreguntas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_SupPreguntas != null ? Text(answer.sp_SupPreguntas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_Respuestas != null ? Text(answer.sp_Respuestas!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_Comentarios != null ? Text(answer.sp_Comentarios!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        DataCell(answer.sp_Justificacion != null ? Text(answer.sp_Justificacion!, style: const TextStyle(fontSize: 20.0)) : const Text('')),
        */
        buildCell(answer.sp_IdUsuarios),
        buildCell(answer.sp_NombreApellido),
        buildCell(answer.sp_Usuarios),
        buildCell(answer.sp_NoEncuesta),
        buildCell(answer.sp_IdSesion.toString()),
        buildCell(answer.sp_CodPreguntas.toString()),
        buildCell(answer.sp_Preguntas),
        buildCell(answer.sp_CodSupPreguntas),
        buildCell(answer.sp_SupPreguntas),
        buildCell(answer.sp_Respuestas),
        buildCell(answer.sp_Comentarios),
        buildCell(answer.sp_Justificacion),
      ]
    );
  }

  DataCell buildCell(String? text) {
    return DataCell(
      text != null
          ? Container(
              constraints: const BoxConstraints(maxWidth: 420, minWidth: 170),
              child: Text(
                text,
                style: TextStyle(fontSize: isTabletDevice ? 9.5.sp : 10.sp),
                softWrap: true,
              ),
            )
          : const Text('')
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
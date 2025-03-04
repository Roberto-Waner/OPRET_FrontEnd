import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formulario_opret/models/Stored%20Procedure/Exportados/sp_Respuestas_Export.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_Respuestas.dart';
import 'package:formulario_opret/screens/interfaz_Admin/graphic/graphic_Respuestas_Screen.dart';
import 'package:formulario_opret/screens/interfaz_Admin/navbar/navbar.dart';
import 'package:formulario_opret/services/respuestas_services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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
  final ApiServiceRespuesta _apiServiceRespuesta =  ApiServiceRespuesta('https://10.0.2.2:7190');
  late Future<List<SpFiltrarRespuestas>> _respuestaData;
  List<SpRespuestasExport> report = [];
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
    // _exportReporte = _apiServiceRespuesta.getExportReporte();
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
        case 'Número de Encuesta':
          return answer.sp_NoEncuesta?.toLowerCase().contains(queryLower) ?? false;
        case 'Número de Seccion':
          return answer.sp_IdSesion?.toString().toLowerCase().contains(queryLower) ?? false;
        case 'Número de Pregunta':
          return answer.sp_CodPreguntas?.toString().toLowerCase().contains(queryLower) ?? false;
        case 'Número de Sub-Pregunta':
          return answer.sp_CodSupPreguntas?.toLowerCase().contains(queryLower) ?? false;
        case 'Por Linea':
          return answer.sp_NombreLinea?.toLowerCase().contains(queryLower) ?? false;
        case 'Por Estación':
          return answer.sp_NombrEstacion?.toLowerCase().contains(queryLower) ?? false;
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

  /*
  Future<void> openExcelReport() async {
    String endpoint = 'api/Report/ExportReporte';
    final Uri url = Uri.parse('https://10.0.2.2:7190/$endpoint');

    if(!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )){
      throw 'No se pudo abrir el archivo Excel $url';
    }
  }*/

  Future<void> exportToCsv(BuildContext context) async {
    try {
      // Obtener los datos desde el backend
      List<SpRespuestasExport> data = await _apiServiceRespuesta.getExportReporte();

      // Verificar si hay datos
      if (data.isEmpty) {
        _showErrorDialog(context, 'No hay datos disponibles para exportar.');
        return;
      }

      // Crear el contenido del archivo CSV
      final StringBuffer csvContent = StringBuffer();

      // Agregar encabezados
      csvContent.writeln(
        'ID Usuarios,Nombre y Apellido,Usuarios,Email,ID Formulario,Fecha Inicio Encuesta,Hora Inicio Encuesta,Nombre Línea,Nombre Estación,ID Sesión,Código Pregunta,Pregunta,Código Subpregunta,Subpregunta,No. Encuestas,Tipo Respuesta,Hora Respondida,Respuestas,Comentarios,Justificación'
      );

      // Agregar datos al CSV
      for (var item in data) {
        csvContent.writeln(
          '${item.rp_IdUsuarios ?? ""},'
          '${item.rp_NombreApellido ?? ""},'
          '${item.rp_Usuarios ?? ""},'
          '${item.rp_Email ?? ""},'
          '${item.rp_IdFormulario ?? 0},'
          '${item.rp_FechaInicioEncuesta ?? ""},'
          '${item.rp_HoraInicioEncuesta ?? ""},'
          '${item.rp_NombreLinea ?? ""},'
          '${item.rp_NombreEstacion ?? ""},'
          '${item.rp_IdSesion ?? 0},'
          '${item.rp_CodPreg ?? 0},'
          '${item.rp_Pregunta ?? ""},'
          '${item.rp_CodSubPreg ?? ""},'
          '${item.rp_SubPregunta ?? ""},'
          '${item.rp_NoEncuestas ?? ""},'
          '${item.rp_TipoResp ?? ""},'
          '${item.rp_HoraRespondida ?? ""},'
          '${item.rp_Respuestas ?? ""},'
          '${item.rp_Comentarios ?? ""},'
          '${item.rp_Justificacion ?? ""}'
        );
      }

      // Guardar el archivo CSV
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/Reporte.csv';
      File(path).writeAsStringSync(csvContent.toString());
      // _showSuccessDialog(context, 'Archivo descargado correctamente.');

      // Abrir el archivo
      OpenFile.open(path);

    } catch (e) {
      print('Error al exportar CSV: $e');
      _showErrorDialog(context, 'Error al exportar CSV.');
    }
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
                        'Número de Encuesta',
                        'Número de Seccion',
                        'Número de Pregunta',
                        'Número de Sub-Pregunta',
                        'Por Linea',
                        'Por Estación'
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
                            DataColumn(label: Text('No. Sección', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('No. Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('No. Sub-Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Sub-Pregunta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Hora Respondida', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Respuesta', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Comentarios', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Justificacion', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Linea del Metro', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
                            DataColumn(label: Text('Estación del Metro', style: TextStyle(fontSize: isTabletDevice ? 12.sp : 12.sp))),
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
                        _showView(context, 'Ver los resultado de las respuesta en Gráficas');
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
                  ),
                  const SizedBox(width: 20),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showDownload(context, "¿Deseas descargar los reportes de Respustas y Formularios en formato .csv?", report);
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 11, 209, 7),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )
                      ),
                      child: const Text('Exportar')
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

  void _showDownload (BuildContext context, String message, List<SpRespuestasExport> data) {
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
                const Icon(Icons.downloading_sharp, color: Color.fromARGB(255, 3, 18, 190), size: 80.0),
                const SizedBox(height: 20),
                const Text(
                  'Descargar Archivo',
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
                      child: Text('Cancelar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                    ),

                    const SizedBox(height: 10.0, width: 10.0),

                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await exportToCsv(context);
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

  void _showView (BuildContext context, String message) {
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
                const Icon(Icons.pie_chart_sharp, color: Color.fromARGB(255, 190, 3, 137), size: 80.0),
                const SizedBox(height: 20),
                const Text(
                  'Vista Gráfica',
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
                      child: Text('Cancelar', style: TextStyle(fontSize: isTabletDevice ? 10.sp : 10.sp, color: const Color.fromARGB(255, 243, 33, 33))),
                    ),

                    const SizedBox(height: 10.0, width: 10.0),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GraphicRespScreen(data: respuestasFiltrados.isNotEmpty ? respuestasFiltrados : todasLasRespuestas),
                          )
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

  void _showSuccessDialog(BuildContext context, String message) {
    final isTabletDevice = isTablet(context);
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
                  style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // exportToExcel(exportReporte);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text('Continuar', style: TextStyle(fontSize: isTabletDevice ? 13.sp : 13.sp, color: Colors.blue)),
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
        buildCell(answer.sp_IdUsuarios),
        buildCell(answer.sp_NombreApellido),
        buildCell(answer.sp_Usuarios),
        buildCell(answer.sp_NoEncuesta),
        buildCell(answer.sp_IdSesion.toString()),
        buildCell(answer.sp_CodPreguntas.toString()),
        buildCell(answer.sp_Preguntas),
        buildCell(answer.sp_CodSupPreguntas),
        buildCell(answer.sp_SupPreguntas),
        buildCell(answer.sp_HoraResp),
        buildCell(answer.sp_Respuestas),
        buildCell(answer.sp_Comentarios),
        buildCell(answer.sp_Justificacion),
        buildCell(answer.sp_NombreLinea),
        buildCell(answer.sp_NombrEstacion),
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
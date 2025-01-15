import 'dart:async';
import 'package:formulario_opret/data/section_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:formulario_opret/services/Stream/stream_services.dart';
import 'package:formulario_opret/services/sesion_services.dart';

class SectionController {
  final SectionCrud _sectionCrud = SectionCrud();
  final ApiServiceSesion2 _apiServiceSesion2 = ApiServiceSesion2('http://wepapi.somee.com');
  final StreamServices _streamServices = StreamServices('http://wepapi.somee.com');

  SectionController() {
    _streamServices.backendAvailabilityStream.listen((isAvailable) {
      if (isAvailable) {
        syncData();
      }
    });
  }

  Future<List<SpPreguntascompleta>> loadFromSQLite() async {
    try{
      return await _sectionCrud.querySectionCrud().timeout(const Duration(seconds: 5));
    } catch (e) { 
      print('Error loading from SQLite: $e'); 
      rethrow; 
    }
  }

  Future<List<SpPreguntascompleta>> loadFromApi() async {
    try{
      final response = await _apiServiceSesion2.getSpPreguntascompletaListada();
      // final responseCache = await _sectionCrud.querySectionCrud();

      if(response.isNotEmpty) {
        // await syncData(response);
        _sectionCrud.truncateSectionCrud();
        print('Datos de la cache vacia con éxito desde, guardando preguntas en SQLite.');
        return response;

      } else {
        // print('Datos sincronizados con éxito desde la API y guardando preguntas en SQLite.');
        // return response;
        throw Exception('Datos sincronizados con éxito desde la API y guardando preguntas en SQLite.');
        // print('Datos sincronizados con éxito desde la API y guardando preguntas en SQLite.');
      }

      // return response;
    } catch (e) { 
      print('Error loading from API: $e'); 
      rethrow; 
    }
  }

  // Sincronizar datos entre SQLite y la API
  Future<void> syncData([List<SpPreguntascompleta>? preguntasDesdeApi]) async {
    try {
      // Obtener preguntas desde la API y actualizar SQLite
      preguntasDesdeApi ??= await _apiServiceSesion2.getSpPreguntascompletaListada();

      // Filtrar preguntas con estado 'true'
      final preguntasFiltradas = preguntasDesdeApi.where((q) => q.sp_Estado == true).toList();

      final preguntasLocales = await _sectionCrud.querySectionCrud();

      // Mapear las preguntas locales por su ID
      final Map<String, SpPreguntascompleta> preguntasLocalesMap = {
        for (var question in preguntasLocales) question.sp_CodPregunta.toString(): question
      };

      for (SpPreguntascompleta apiQuestion in preguntasFiltradas) {
        final localQuestion = preguntasLocalesMap[apiQuestion.sp_CodPregunta.toString()];
        if (localQuestion == null || !compareQuestions(localQuestion, apiQuestion)) {
          await _sectionCrud.insertSectionCrud(apiQuestion); // Insertar o actualizar en SQLite
        }
      }

      print('Datos sincronizados con éxito.');
    } catch (e) {
      print('Error al sincronizar datos: $e');
    }
  }

  // Método para comparar preguntas
  bool compareQuestions(SpPreguntascompleta localQuestion, SpPreguntascompleta apiQuestion) {
    return localQuestion.sp_CodPregunta == apiQuestion.sp_CodPregunta &&
           localQuestion.sp_TipoRespuesta == apiQuestion.sp_TipoRespuesta &&
           localQuestion.sp_Pregunta == apiQuestion.sp_Pregunta &&
           localQuestion.sp_SubPregunta == apiQuestion.sp_SubPregunta &&
           localQuestion.sp_Estado == apiQuestion.sp_Estado &&
           localQuestion.sp_Rango == apiQuestion.sp_Rango;
  }
  /*
  El método compareQuestions tiene el propósito de comparar dos objetos SpPreguntascompleta y determinar si son equivalentes. 
  Este método es crucial cuando intentamos decidir si una pregunta obtenida desde la API debe ser actualizada en la base de 
  datos local SQLite.
  */
}
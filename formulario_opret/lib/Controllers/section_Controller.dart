import 'dart:async';
import 'package:formulario_opret/data/section_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:formulario_opret/services/Stream/stream_services.dart';
import 'package:formulario_opret/services/sesion_services.dart';

class SectionController {
  final SectionCrud _sectionCrud = SectionCrud();
  final ApiServiceSesion2 _apiServiceSesion2 = ApiServiceSesion2('https://10.0.2.2:7190');
  final StreamServices _streamServices = StreamServices('https://10.0.2.2:7190');

  SectionController() {
    _streamServices.backendAvailabilityStream.listen((isAvailable) {
      if (isAvailable) {
        syncData();
      }
    });
  }

  // Future<void> createQuestion(SpPreguntascompleta question) async {
  //   try{
  //     await _sectionCrud.insertSectionCrud(question);
  //     print('Sección de preguntas creada con éxito en SQLite');
  //     await syncData();
  //   } catch (e) {
  //     print('Error al crear sección de preguntas: $e');
  //   }
  // }

  // Future<List<SpPreguntascompleta>> getQuestion() async {
  //   try{
  //     return await _sectionCrud.querySectionCrud().timeout(const Duration(seconds: 5));
  //   } catch(e) {
  //     print('Error al cargar secciones de preguntas de la API, cargando desde SQLite: $e');
  //     return await _apiServiceSesion2.getSpPreguntascompletaListada();
  //   }
  // }

  Future<List<SpPreguntascompleta>> loadFromSQLite() async {
    try{
      return await _sectionCrud.querySectionCrud();
    } catch (e) { 
      print('Error loading from SQLite: $e'); 
      rethrow; 
    }
  }

  Future<List<SpPreguntascompleta>> loadFromApi() async {
    try{
      final response = await _apiServiceSesion2.getSpPreguntascompletaListada();
      if(response.isNotEmpty) {
        // await syncData(response);
        print('Datos sincronizados con éxito desde la API y guardando preguntas en SQLite.');
        return response;
      } else { 
        throw Exception('API response is empty.'); 
      }
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
      final preguntasLocales = await _sectionCrud.querySectionCrud();

      // Mapear las preguntas locales por su ID
      final Map<String, SpPreguntascompleta> preguntasLocalesMap = {
        for (var question in preguntasLocales) question.sp_CodPregunta.toString(): question
      };

      for (SpPreguntascompleta apiQuestion in preguntasDesdeApi) {
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
           localQuestion.sp_Rango == apiQuestion.sp_Rango;
  }
  /*
  El método compareQuestions tiene el propósito de comparar dos objetos SpPreguntascompleta y determinar si son equivalentes. 
  Este método es crucial cuando intentamos decidir si una pregunta obtenida desde la API debe ser actualizada en la base de 
  datos local SQLite.
  */
}
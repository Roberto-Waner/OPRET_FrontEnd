import 'package:formulario_opret/data/user_crud.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/services/Stream/stream_services.dart';
import 'package:formulario_opret/services/user_services.dart';

class UserController {
  final UserCrud _usuariosCRUD = UserCrud();
  final ApiServiceUser _apiServiceUser = ApiServiceUser('https://10.0.2.2:7190');
  final StreamServices _streamServices = StreamServices('https://10.0.2.2:7190');

  UserController() {
    _streamServices.backendAvailabilityStream.listen((isAvailable) {
      if (isAvailable) {
        syncData();
      }
    });
  }

  // para interactual en la base de datos local Sqflite

  // Crear un usuario
  Future<void> createUser(Usuarios user) async {
    try {
      final response = await _apiServiceUser.createUsuario(user).timeout(const Duration(seconds: 30));
      if (response.statusCode == 201) {
        print('Usuario creado con éxito en la API');
      } else {
        print('Error al crear usuario en la API: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        await _usuariosCRUD.insertUserCrud(user).timeout(const Duration(seconds: 30));
        // await syncData();
        print('Usuario creado con éxito en SQLite');
      }
    } catch (e) {
      print('Error al crear usuario: $e');
      await _usuariosCRUD.insertUserCrud(user).timeout(const Duration(seconds: 30));
      print('Usuario creado con éxito en SQLite');
    }
  }

  /*Crea un nuevo usuario en SQLite. Se usa cuando quieres agregar 
  un usuario en la base de datos local, como cuando el usuario 
  se registra en la aplicación sin conexión.*/

  // Obtener todos los usuarios
  Future<List<Usuarios>> getUsers() async {
    try {
      return await _apiServiceUser.getUsuarios().timeout(const Duration(seconds: 30));
    } catch (e) {
      print('Error al cargar usuarios de la API, cargando desde SQLite: $e');
      return await _usuariosCRUD.getUsersCrud().timeout(const Duration(seconds: 30));
    }
  }
  /*Recupera todos los usuarios guardados en SQLite. Este método 
  es útil para cargar la lista completa de usuarios almacenados 
  localmente, y es esencial para la sincronización inicial de 
  datos cuando se descargan todos los usuarios del servidor 
  al dispositivo.*/

  // Obtener un usuario por ID
  Future<Usuarios?> getOneUser(String id) async {
    try {
      return await _apiServiceUser.getOneUsuario(id).timeout(const Duration(seconds: 30));
    } catch (e) {
      print('Error al obtener el usuario de la API, cargando desde SQLite: $e');
      return await _usuariosCRUD.getOneUserCrud(id).timeout(const Duration(seconds: 30));
    }
  }
  /*getOneUser: Obtiene un usuario específico por su ID. Es útil 
  para verificar si un usuario ya existe antes de actualizarlo o 
  sincronizar datos con el servidor.*/

  // Actualizar un usuario
  Future<void> updateUser(String id, Usuarios user) async {
    try {
      final response = await _apiServiceUser.updateUsuario(id, user).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204) {
        print('Usuario actualizado con éxito en la API');
      } else {
        await _usuariosCRUD.updateUserCrud(id, user).timeout(const Duration(seconds: 30));
        // await syncData();
        print('Usuario actualizado con éxito en SQLite');
      }
    } catch (e) {
      print('Error al actualizar usuario: $e');
      await _usuariosCRUD.updateUserCrud(id, user).timeout(const Duration(seconds: 30));
      print('Usuario actualizado con éxito en SQLite');
    }
  }
  /*updateUser: Actualiza un usuario específico en SQLite. 
  Esto es necesario cuando se sincronizan datos del servidor al 
  cliente (SQLite), asegurando que los datos estén actualizados 
  localmente.*/

  // Eliminar un usuario
  Future<void> deleteUser(String id) async {
    try {
      final response = await _apiServiceUser.deleteUsuario(id).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204) {
        print('Usuario eliminado con éxito en la API');
      } else {
        await _usuariosCRUD.deleteUserCrud(id).timeout(const Duration(seconds: 30));
        // await syncData();
        print('Usuario marcado como eliminado en SQLite');
      }
    } catch (e) {
      print('Error al eliminar usuario: $e');
      await _usuariosCRUD.deleteUserCrud(id).timeout(const Duration(seconds: 30));
      print('Usuario marcado como eliminado en SQLite');
    }
  }
  /*deleteUser: Elimina un usuario de SQLite. Es útil para 
  eliminar usuarios localmente, lo que puede ser necesario si un 
  usuario ha sido eliminado en el servidor o si se debe remover 
  desde la aplicación.*/

  Future<void> syncData() async {
    try {
      // Obtener usuarios locales desde SQLite
      List<Usuarios> usuariosLocales = await _usuariosCRUD.getUsersCrud();

      for (Usuarios user in usuariosLocales) {
        final isCheckOk = await _apiServiceUser.service.check();

        if (isCheckOk) {
          if (user.isDeleted == 1) {
            // Si el usuario está marcado como eliminado
            final response = await _apiServiceUser.deleteUsuario(user.idUsuarios);
            if (response.statusCode == 204) {
              await _usuariosCRUD.clearSyncFlags(user.idUsuarios);
            } else {
              print('Error al eliminar usuario en la API: ${response.statusCode}');
            }
          } else if (user.isUpdated == 1) {
            // Si el usuario está marcado como actualizado
            final response = await _apiServiceUser.updateUsuario(user.idUsuarios, user);
            if (response.statusCode == 204) {
              await _usuariosCRUD.clearSyncFlags(user.idUsuarios);
            } else {
              print('Error al actualizar usuario en la API: ${response.statusCode}');
            }
          } else {
            // Si el usuario es nuevo
            final response = await _apiServiceUser.createUsuario(user);
            if (response.statusCode == 201) {
              await _usuariosCRUD.clearSyncFlags(user.idUsuarios);
            } else {
              print('Error al crear usuario en la API: ${response.statusCode}');
            }
          }
        } else {
          // Si la API no está disponible, guardar localmente y marcar como pendiente
          print('La API no está disponible, se guardarán los cambios localmente.');
        }
      }

      // Obtener usuarios desde la API y actualizar SQLite si hay discrepancias
      final usuariosDesdeApi = await _apiServiceUser.getUsuarios();
      for (Usuarios apiUser in usuariosDesdeApi) {
        final localUser = await _usuariosCRUD.getOneUserCrud(apiUser.idUsuarios);
        if (localUser == null || !compareUsersIgnoringFlags(localUser, apiUser)) {
          await _usuariosCRUD.updateUserCrud(apiUser.idUsuarios, apiUser);
        }
      }

      print('Datos sincronizados con éxito.');
    } catch (e) {
      print('Error al sincronizar datos: $e');
    }
  }

  // Método para comparar usuarios ignorando isUpdated e isDeleted
  bool compareUsersIgnoringFlags(Usuarios localUser, Usuarios apiUser) {
    return localUser.idUsuarios == apiUser.idUsuarios &&
          localUser.cedula == apiUser.cedula &&
          localUser.nombreApellido == apiUser.nombreApellido &&
          localUser.usuario1 == apiUser.usuario1 &&
          localUser.email == apiUser.email &&
          localUser.passwords == apiUser.passwords &&
          localUser.fechaCreacion == apiUser.fechaCreacion &&
          localUser.rol == apiUser.rol;
  }


  // Sincronizar datos entre SQLite y la API
  // Future<void> syncData() async {
  //   try {
  //     List<Usuarios> usuariosLocales = await _usuariosCRUD.getUsersCrud();
  //     for (Usuarios user in usuariosLocales) {
  //       final isCheckOk = await _apiServiceUser.service.check();
  //       if (isCheckOk) {
  //         final response = await _apiServiceUser.createUsuario(user);
  //         if (response.statusCode == 201) {
  //           await _usuariosCRUD.clearSyncFlags(user.idUsuarios);
  //         } else {
  //           print('Error al al crear usuario en la API: ${response.statusCode}');
  //         }
  //       } else {
  //         await _usuariosCRUD.insertUserCrud(user);
  //       }
  //     }
  //     print('Datos sincronizados con éxito.');
  //   } catch (e) {
  //     print('Error al sincronizar datos: $e');
  //   }
  // }
}

/*// Método para obtener usuarios actualizados desde SQLite
  Future<List<Usuarios>> getUpdatedUsers() async {
    // Suponiendo que en la clase UserCrud tienes una función que obtiene solo los usuarios actualizados
    return await _usuariosCRUD.getUpdatedUsersCrud();
  }

  // Método para obtener los IDs de los usuarios eliminados en SQLite
  Future<List<String>> getDeletedUserIds() async {
    // Suponiendo que en la clase UserCrud tienes una función que obtiene solo los IDs de los usuarios eliminados
    return await _usuariosCRUD.getDeletedUserIdsCrud();
  }

  // Sincronizar los usuarios de SQLite a la API cuando hay conexión
  Future<void> syncUsers() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // Sincronizar usuarios actualizados
      final updatedUsers = await getUpdatedUsers();
      for (var user in updatedUsers) {
        try {
          await _apiService.updateUsuario(user.idUsuarios, user);
          print("Usuario sincronizado con la API.");
        } catch (e) {
          print("Error al sincronizar usuario: $e");
        }
      }

      // Sincronizar usuarios eliminados
      final deletedUserIds = await getDeletedUserIds();
      for (var id in deletedUserIds) {
        try {
          await _apiService.deleteUsuario(id);
          print("Usuario eliminado en la API.");
        } catch (e) {
          print("Error al sincronizar eliminación de usuario: $e");
        }
      }
    } else {
      print("Sin conexión: la sincronización se mantiene solo en SQLite.");
    }
  } */
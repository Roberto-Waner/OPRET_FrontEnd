// import 'package:formulario_opret/Controllers/User_Controller.dart';
// import 'package:formulario_opret/models/usuarios.dart';
// import 'package:formulario_opret/services/user_services.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class SyncController {
//   final UserController _userController = UserController();
//   final ApiService _apiService = ApiService('https://10.0.2.2:7190');

//   // Constructor para iniciar la escucha de cambios de conexión
//   SyncController() {
//     _listenToConnectionChanges();
//   }

//   /*
//   // Método para sincronizar usuarios desde SQLite hacia el servidor
//   Future<void> sincronizarUsuarios() async {
//     List<Usuarios> usuariosLocales = await _userController.getUsers();

//     for (Usuarios user in usuariosLocales) {
//       await _apiService.createUsuarios(user); // Enviar a la API
//       print('Usuario sincronizado con éxito');
//     }
//   }*/

//   // Escuchar los cambios en la conectividad
//   void _listenToConnectionChanges() {
//     Connectivity().onConnectivityChanged.listen((result) {
//       if (result != ConnectivityResult.none) {
//         sincronizarDatos(); // Si hay conexión, sincroniza los datos
//       }
//     });
//   }
//   // void _listenToConnectionChanges() {
//   //   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//   //     if (result != ConnectivityResult.none) {
//   //       sincronizarDatos(); // Si hay conexión, sincroniza los datos
//   //     }
//   //   } as void Function(List<ConnectivityResult> event)?);
//   // }


//   // Sincronizar datos en ambas direcciones
//   Future<void> sincronizarDatos() async {
//     await sincronizarUsuariosDesdeServidor();
//     await sincronizarUsuarios();
//   }

//   Future<void> sincronizarUsuarios() async {
//     // Sincronizar usuarios modificados o nuevos
//     List<Usuarios> usuariosActualizados = await _userController.getUpdatedUsers();
//     for (Usuarios user in usuariosActualizados) {
//       await _apiService.createUsuarios(user); // Este método en el API debe actualizar o crear según sea el caso
//       print('Usuario actualizado o creado en el servidor');
//     }

//     // Sincronizar usuarios eliminados
//     List<String> idsUsuariosEliminados = await _userController.getDeletedUserIds();
//     for (String id in idsUsuariosEliminados) {
//       await _apiService.deleteUsuario(id); // Elimina el usuario del servidor
//       print('Usuario eliminado en el servidor');
//     }
//   }

//   // Método para sincronizar usuarios desde el servidor hacia SQLite
//   Future<void> sincronizarUsuariosDesdeServidor() async {
//     try {
//       List<Usuarios> usuariosServidor = await _apiService.getUsuarios();
//       for (var user in usuariosServidor) {
//         Usuarios? usuarioExistente = await _userController.getOneUser(user.idUsuarios);
//         if (usuarioExistente != null) {
//           await _userController.updateUser(user.idUsuarios, user);
//           print('Usuario actualizado en SQLite');
//         } else {
//           await _userController.createUser(user);
//           print('Usuario creado en SQLite');
//         }
//       }
//       print('Usuarios sincronizados desde el servidor con éxito');
//     } catch (e) {
//       print('Error al sincronizar desde el servidor: $e');
//     }
//   }

//   /*
//   // Método para sincronizar usuarios desde el servidor hacia SQLite
//   Future<void> sincronizarUsuariosDesdeServidor() async {
//     try {
//       List<Usuarios> usuariosServidor = await _apiService.getUsuarios();
//       for (var usuario in usuariosServidor) {
//         Usuarios user = Usuarios(
//           idUsuarios: usuario.idUsuarios$,
//           cedula: usuario.cedula$,
//           nombreApellido: usuario.nombreApellido$,
//           usuario1: usuario.usuario$,
//           email: usuario.email$,
//           passwords: usuario.passwords$ ?? '', // Maneja la contraseña según sea necesario
//           fechaCreacion: usuario.fechaCreacion$,
//           rol: usuario.rol$,
//         );
//         // Verifica si el usuario ya existe en SQLite
//         Usuarios? usuarioExistente = await _userController.getOneUser(usuario.idUsuarios$);
//         if (usuarioExistente != null) {
//           await _userController.updateUser(usuario.idUsuarios$, user); // Actualiza si existe
//           print('Usuario actualizado en SQLite');
//         } else {
//           await _userController.createUser(user); // Inserta si no existe
//           print('Usuario creado en SQLite');
//         }
//       }
//       print('Usuarios sincronizados desde el servidor con éxito');
//     } catch (e) {
//       print('Error al sincronizar desde el servidor: $e');
//     }
//   }*/
// }
// /*
// Usamos await _userController.createUser(user); para almacenar los datos obtenidos del 
//   servidor en tu base de datos local SQLite. De esta forma, los datos están disponibles 
//   offline en tu aplicación.

// Aquí está el flujo completo:

// Descargar Datos: getUsuarios obtiene los datos desde el servidor en forma de ObtenerEmpleados.

// Convertir Datos: Convertimos ObtenerEmpleados a Usuarios porque necesitamos almacenar los datos en SQLite.

// Guardar en SQLite: await _userController.createUser(user) almacena los datos en la base de datos local.
// */
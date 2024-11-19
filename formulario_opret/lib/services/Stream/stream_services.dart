import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class StreamServices {
  final String baseUrl;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  final Duration retryInterval; // Intervalo configurable para reintentos
  final Duration httpTimeout;
  final int maxRetries;
  int retryCount = 0;

  StreamServices(
        this.baseUrl,
        {
          this.retryInterval = const Duration(seconds: 5),
          this. httpTimeout = const Duration(seconds: 5),
          this.maxRetries = 5
        }
      ) {

    Connectivity().checkConnectivity().then((result) {
      if (result != ConnectivityResult.none) {
        _checkBackendAvailability();
      } else {
        _controller.sink.add(false);
      }
    });

    // Escuchar cambios en la conectividad
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _checkBackendAvailability();
      } else {
        _controller.sink.add(false);
      }
    });
  }

  Stream<bool> get backendAvailabilityStream => _controller.stream;

  Future<void> _checkBackendAvailability() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Check')).timeout(httpTimeout);
      if (response.statusCode == 200) {
        _controller.sink.add(true);
        retryCount = 0;
        _cancelRetryTimer(); // Cancelar cualquier intento de reintento programado si la conexión es exitosa
      } else {
        _controller.sink.add(false);
        _scheduleRetry(); // Programar un reintento en 5 minutos
      }
    } on TimeoutException {
      print('Tiempo de espera excedido.');
      _controller.sink.add(false);
      _scheduleRetry(); // Programar un reintento en 5 minutos
    } on SocketException {
      print('Error de red.');
      _controller.sink.add(false);
      _scheduleRetry();
    } catch (e) {
      print('Error desconocido: $e');
      _controller.sink.add(false);
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (retryCount < maxRetries) {
      _cancelRetryTimer();
      _timer = Timer(retryInterval, _checkBackendAvailability);
      retryCount++;
    } else {
      print('Máximo número de reintentos alcanzado.');
    }
  }

  void _cancelRetryTimer() {
    _timer?.cancel();
  }

  void dispose() {
    _cancelRetryTimer();
    _controller.close();
  }
}
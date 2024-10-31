import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class StreamServices {
  final String baseUrl;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;

  StreamServices(this.baseUrl) {
    Connectivity().onConnectivityChanged.listen((result) {
      _checkBackendAvailability();
    });
  }

  Stream<bool> get backendAvailabilityStream => _controller.stream;

  Future<void> _checkBackendAvailability() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Check')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        _controller.sink.add(true);
        _cancelRetryTimer(); // Cancelar cualquier intento de reintento programado si la conexión es exitosa
      } else {
        _controller.sink.add(false);
        _scheduleRetry(); // Programar un reintento en 5 minutos
      }
    } catch (e) {
      _controller.sink.add(false);
      _scheduleRetry(); // Programar un reintento en 5 minutos
    }
  }

  void _scheduleRetry() {
    _cancelRetryTimer();
    _timer = Timer(const Duration(minutes: 5), _checkBackendAvailability);
  }

  void _cancelRetryTimer() {
    _timer?.cancel();
  }

  void dispose() {
    _cancelRetryTimer();
    _controller.close();
  }
}
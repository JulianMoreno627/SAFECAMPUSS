import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  final _logger = Logger();
  
  final _nuevoReporteController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get nuevoReporteStream => _nuevoReporteController.stream;

  void init(String url) {
    if (_socket != null) return;
    
    _socket = io.io(url, io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
    );

    _socket!.onConnect((_) {
      _logger.i('Socket conectado: ${_socket!.id}');
    });

    _socket!.on('nuevo_reporte', (data) {
      _logger.i('Nuevo reporte recibido via socket: $data');
      if (data is Map<String, dynamic>) {
        _nuevoReporteController.add(data);
      }
    });

    _socket!.onDisconnect((_) {
      _logger.i('Socket desconectado');
    });
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _nuevoReporteController.close();
  }
}

final socketService = SocketService();

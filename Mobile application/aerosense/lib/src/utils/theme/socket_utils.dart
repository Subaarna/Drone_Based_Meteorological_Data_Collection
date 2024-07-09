import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

final logger = Logger();

class SocketUtils {
  static const String baseurl =
      'https://drone-based-meteorological-data.onrender.com';
  static late io.Socket socket;

  static void connect() {
    socket = io.io(baseurl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    logger.d('SOCKET CONNNETED  ::: ID ::: ${socket.id}');
    socket.on('connect', (_) {
      logger.d('Socket connected! ID: ${socket.id}');
    });

    socket.on('connect_error', (error) {
      logger.d('Socket connection error: $error');
    });

    socket.on('connect_timeout', (_) {
      logger.d('Socket connection timeout');
    });
  }
}

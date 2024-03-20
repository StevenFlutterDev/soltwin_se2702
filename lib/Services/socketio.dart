// socket_io_manager.dart

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketIOManager {
  late io.Socket socket;
  Function(String)? onMessageReceived;

  SocketIOManager(String url) {
    socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) => print('Socket.IO Connected'));
    socket.on('event', (data) => onMessageReceived?.call(data.toString()));
  }

  void emit(String event, dynamic data) {
    socket.emit(event, data);
  }

  void close() {
    socket.disconnect();
  }
}

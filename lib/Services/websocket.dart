import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServices{
  late WebSocketChannel channel;
  Function(String)? onMessageReceived;

  WebSocketServices(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen((message) {
      onMessageReceived?.call(message);
    });
  }

  void sendMessage(String message) {
    channel.sink.add(message);
    print('Message sent: $message');
  }

  void disconnect() {
    channel.sink.close();
  }
}
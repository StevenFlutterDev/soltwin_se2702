import 'package:flutter/material.dart';
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/main.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServices{
  late WebSocketChannel channel;
  Function(String)? onMessageReceived;

  WebSocketServices(String url) {
    try{
      channel = WebSocketChannel.connect(Uri.parse(url));
      channel.stream.listen((message) {
        onMessageReceived?.call(message);
      });
    }catch (e){
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (context)=>ShareMessageDialog(contentMessage: e.toString()));
    }

  }

  void sendMessage(String message) {
    channel.sink.add(message);
    print('Message sent: $message');
  }

  void disconnect() {
    channel.sink.close();
  }
}
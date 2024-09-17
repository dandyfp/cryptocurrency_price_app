import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketRepository {
  WebSocketChannel connect(String url);
  Stream<dynamic> getMessages();
  void disconnect();
}

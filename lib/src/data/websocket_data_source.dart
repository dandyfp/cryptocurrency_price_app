import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDataSource {
  WebSocketChannel? _channel;

  WebSocketChannel connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel!.sink
        .add(' {"action": "subscribe", "symbols": "ETH-USD,BTC-USD"}');
    return _channel!;
  }

  Stream<dynamic> get stream => _channel!.stream;

  void disconnect() {
    _channel?.sink.close();
  }
}

import 'package:cryptocurrency_price_app/src/domain/repositories/web_socket_repository.dart';

class ConnectWebSocket {
  final WebSocketRepository repository;

  ConnectWebSocket(this.repository);

  Stream<dynamic> call(String url) {
    repository.connect(url);
    return repository.getMessages();
  }

  void disconnect() {
    repository.disconnect();
  }
}

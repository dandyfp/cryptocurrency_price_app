import 'package:cryptocurrency_price_app/src/data/webSocket_data_source.dart';
import 'package:cryptocurrency_price_app/src/domain/repositories/web_socket_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketRepositoryImpl implements WebSocketRepository {
  final WebSocketDataSource dataSource;

  WebSocketRepositoryImpl(this.dataSource);

  @override
  WebSocketChannel connect(String url) {
    return dataSource.connect(url);
  }

  @override
  Stream<dynamic> getMessages() {
    return dataSource.stream;
  }

  @override
  void disconnect() {
    dataSource.disconnect();
  }
}

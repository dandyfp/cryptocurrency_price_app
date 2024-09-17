import 'package:cryptocurrency_price_app/src/data/webSocket_data_source.dart';
import 'package:cryptocurrency_price_app/src/data/websocket_data_source_impl.dart';
import 'package:cryptocurrency_price_app/src/domain/usecase/connect_websocket.dart';
import 'package:cryptocurrency_price_app/src/presentation/home/bloc/websocket_bloc.dart';
import 'package:cryptocurrency_price_app/src/presentation/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final WebSocketDataSource dataSource = WebSocketDataSource();
  final WebSocketRepositoryImpl repository =
      WebSocketRepositoryImpl(dataSource);
  final ConnectWebSocket connectWebSocket = ConnectWebSocket(repository);

  runApp(MyApp(connectWebSocket: connectWebSocket));
}

class MyApp extends StatelessWidget {
  final ConnectWebSocket connectWebSocket;

  const MyApp({super.key, required this.connectWebSocket});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebSocket BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => WebSocketBloc(connectWebSocket),
        child: const HomePage(),
      ),
    );
  }
}

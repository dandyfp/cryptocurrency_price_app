import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cryptocurrency_price_app/src/domain/usecase/connect_websocket.dart';
import 'package:rxdart/rxdart.dart';
import 'websocket_event.dart';
import 'websocket_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final ConnectWebSocket connectWebSocket;
  StreamSubscription? _subscription;
  DateTime? _lastUpdateTime;

  WebSocketBloc(this.connectWebSocket) : super(WebSocketInitial()) {
    on<ConnectToWebSocket>(_onConnectWebSocket);
    on<DisconnectWebSocket>(_onDisconnectWebSocket);
    on<WebSocketMessageReceived>(_onMessageReceived);
  }

  void _onConnectWebSocket(
      ConnectToWebSocket event, Emitter<WebSocketState> emit) {
    _subscription = connectWebSocket
        .call('wss://ws.eodhistoricaldata.com/ws/crypto?api_token=demo')
        .throttleTime(const Duration(seconds: 1))
        .listen((message) {
      add(WebSocketMessageReceived(message));
    });
    emit(WebSocketConnected());
  }

  void _onDisconnectWebSocket(
      DisconnectWebSocket event, Emitter<WebSocketState> emit) {
    _subscription?.cancel();
    connectWebSocket.disconnect();
    emit(WebSocketDisconnected());
  }

  void _onMessageReceived(
      WebSocketMessageReceived event, Emitter<WebSocketState> emit) {
    final currentTime = DateTime.now();

    if (_lastUpdateTime == null ||
        currentTime.difference(_lastUpdateTime!) >=
            const Duration(seconds: 1)) {
      _lastUpdateTime = currentTime;
      emit(WebSocketMessageReceivedState(event.message));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    connectWebSocket.disconnect();
    return super.close();
  }
}

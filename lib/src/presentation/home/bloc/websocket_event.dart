import 'package:equatable/equatable.dart';

abstract class WebSocketEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ConnectToWebSocket extends WebSocketEvent {}

class DisconnectWebSocket extends WebSocketEvent {}

class WebSocketMessageReceived extends WebSocketEvent {
  final String message;

  WebSocketMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

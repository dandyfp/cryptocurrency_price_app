import 'package:equatable/equatable.dart';

abstract class WebSocketState extends Equatable {
  @override
  List<Object> get props => [];
}

class WebSocketInitial extends WebSocketState {}

class WebSocketConnected extends WebSocketState {}

class WebSocketDisconnected extends WebSocketState {}

class WebSocketMessageReceivedState extends WebSocketState {
  final String message;

  WebSocketMessageReceivedState(this.message);

  @override
  List<Object> get props => [message];
}

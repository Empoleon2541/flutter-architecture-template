import 'package:equatable/equatable.dart';
import '../../domain/entities/realtime_event.dart';

abstract class RealtimeBlocState extends Equatable {
  const RealtimeBlocState();

  @override
  List<Object?> get props => [];
}

class RealtimeInitial extends RealtimeBlocState {
  const RealtimeInitial();
}

class RealtimeConnecting extends RealtimeBlocState {
  const RealtimeConnecting();
}

class RealtimeConnected extends RealtimeBlocState {
  final List<RealtimeEvent> events;

  const RealtimeConnected({required this.events});

  @override
  List<Object?> get props => [events];
}

class RealtimeDisconnected extends RealtimeBlocState {
  const RealtimeDisconnected();
}

class RealtimeError extends RealtimeBlocState {
  final String message;

  const RealtimeError(this.message);

  @override
  List<Object?> get props => [message];
}

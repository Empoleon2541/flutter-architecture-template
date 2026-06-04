import 'package:equatable/equatable.dart';
import '../../domain/entities/realtime_event.dart';

abstract class RealtimeBlocEvent extends Equatable {
  const RealtimeBlocEvent();

  @override
  List<Object?> get props => [];
}

class RealtimeConnectRequested extends RealtimeBlocEvent {
  const RealtimeConnectRequested();
}

class RealtimeDisconnectRequested extends RealtimeBlocEvent {
  const RealtimeDisconnectRequested();
}

class RealtimeEventReceived extends RealtimeBlocEvent {
  final RealtimeEvent event;

  const RealtimeEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

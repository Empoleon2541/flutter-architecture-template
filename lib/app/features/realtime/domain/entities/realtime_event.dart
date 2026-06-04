import 'package:equatable/equatable.dart';

class RealtimeEvent extends Equatable {
  final String id;
  final String type; // 'notification' | 'price_update' | 'chat_message'
  final String payload;
  final DateTime timestamp;

  const RealtimeEvent({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, type, payload, timestamp];

  @override
  String toString() =>
      'RealtimeEvent(id: $id, type: $type, payload: $payload)';
}

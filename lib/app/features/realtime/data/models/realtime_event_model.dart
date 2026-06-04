import '../../domain/entities/realtime_event.dart';

class RealtimeEventModel extends RealtimeEvent {
  const RealtimeEventModel({
    required super.id,
    required super.type,
    required super.payload,
    required super.timestamp,
  });

  factory RealtimeEventModel.fromJson(Map<String, dynamic> json) {
    return RealtimeEventModel(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: json['payload'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RealtimeEventModel.fromEntity(RealtimeEvent event) {
    return RealtimeEventModel(
      id: event.id,
      type: event.type,
      payload: event.payload,
      timestamp: event.timestamp,
    );
  }
}

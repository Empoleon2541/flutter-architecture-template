import 'dart:async';
import 'package:requests_inspector/requests_inspector.dart';
import '../../../../common/utils/app_constants.dart';
import '../models/realtime_event_model.dart';

abstract class MockWebSocketDataSource {
  Stream<RealtimeEventModel> get eventStream;
  void connect();
  void disconnect();
  bool get isConnected;
}

class MockWebSocketDataSourceImpl implements MockWebSocketDataSource {
  StreamController<RealtimeEventModel>? _controller;
  Timer? _timer;
  int _eventCounter = 0;
  bool _isConnected = false;

  final _eventTypes = ['notification', 'price_update', 'chat_message'];

  final _payloads = {
    'notification': [
      'New follower: @john_dev',
      'Your post was liked by 12 people',
      'System update available v2.1.0',
      'Reminder: Meeting in 15 minutes',
      'New comment on your post',
    ],
    'price_update': [
      'BTC: \$67,432 (+2.3%)',
      'ETH: \$3,201 (-0.8%)',
      'AAPL: \$189.50 (+1.2%)',
      'TSLA: \$248.30 (+3.7%)',
      'SOL: \$142.80 (+5.1%)',
    ],
    'chat_message': [
      'Hello there! How is the project going?',
      'Meeting at 3pm in the main conference room',
      'Can you review my PR when you have a moment?',
      'Great work on the architecture demo!',
      'The build is passing on CI now.',
    ],
  };

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<RealtimeEventModel> get eventStream {
    if (_controller == null || _controller!.isClosed) {
      throw StateError('WebSocket not connected. Call connect() first.');
    }
    return _controller!.stream;
  }

  @override
  void connect() {
    if (_isConnected) return;

    _controller = StreamController<RealtimeEventModel>.broadcast();
    _isConnected = true;
    _eventCounter = 0;

    // Emit first event immediately after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isConnected && !(_controller?.isClosed ?? true)) {
        _emitEvent();
      }
    });

    // Then emit every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_isConnected && !(_controller?.isClosed ?? true)) {
        _emitEvent();
      }
    });
  }

  void _emitEvent() {
    final type = _eventTypes[_eventCounter % _eventTypes.length];
    final payloadList = _payloads[type]!;
    final payload = payloadList[_eventCounter % payloadList.length];
    final now = DateTime.now();

    final event = RealtimeEventModel(
      id: 'evt_${_eventCounter.toString().padLeft(4, '0')}',
      type: type,
      payload: payload,
      timestamp: now,
    );

    _controller?.add(event);
    _reportToInspector(event, now);
    _eventCounter++;
  }

  void _reportToInspector(RealtimeEventModel event, DateTime timestamp) {
    if (!AppConstants.enableRequestsInspector) return;

    InspectorController().addNewRequest(
      RequestDetails(
        requestName: 'WS · ${event.type}',
        requestMethod: RequestMethod.GET,
        url: 'ws://mock.local/realtime',
        statusCode: 200,
        requestBody: {'channel': 'realtime', 'event_id': event.id},
        responseBody: {
          'id': event.id,
          'type': event.type,
          'payload': event.payload,
          'timestamp': event.timestamp.toIso8601String(),
        },
        sentTime: timestamp,
        receivedTime: timestamp,
      ),
    );
  }

  @override
  void disconnect() {
    _isConnected = false;
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}

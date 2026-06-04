import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/utils/app_constants.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/usecases/subscribe_to_events_usecase.dart';
import 'realtime_bloc_event.dart';
import 'realtime_bloc_state.dart';

class RealtimeBloc extends Bloc<RealtimeBlocEvent, RealtimeBlocState> {
  final SubscribeToEventsUseCase subscribeToEventsUseCase;

  StreamSubscription<dynamic>? _eventSubscription;

  RealtimeBloc({required this.subscribeToEventsUseCase})
      : super(const RealtimeInitial()) {
    on<RealtimeConnectRequested>(_onConnectRequested);
    on<RealtimeDisconnectRequested>(_onDisconnectRequested);
    on<RealtimeEventReceived>(_onEventReceived);
  }

  Future<void> _onConnectRequested(
    RealtimeConnectRequested event,
    Emitter<RealtimeBlocState> emit,
  ) async {
    if (state is RealtimeConnected || state is RealtimeConnecting) return;

    emit(const RealtimeConnecting());

    // Cancel any existing subscription
    await _eventSubscription?.cancel();
    _eventSubscription = null;

    try {
      final stream = subscribeToEventsUseCase.call();

      _eventSubscription = stream.listen(
        (either) {
          either.fold(
            (failure) {
              if (!isClosed) {
                emit(RealtimeError(failure.message));
              }
            },
            (realtimeEvent) {
              if (!isClosed) {
                add(RealtimeEventReceived(realtimeEvent));
              }
            },
          );
        },
        onError: (error) {
          if (!isClosed) {
            emit(RealtimeError('Stream error: $error'));
          }
        },
        cancelOnError: false,
      );

      // Emit connected state immediately after subscribing
      emit(const RealtimeConnected(events: []));
    } catch (e) {
      emit(RealtimeError('Failed to connect: $e'));
    }
  }

  Future<void> _onDisconnectRequested(
    RealtimeDisconnectRequested event,
    Emitter<RealtimeBlocState> emit,
  ) async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;

    await subscribeToEventsUseCase.disconnect();
    emit(const RealtimeDisconnected());
  }

  void _onEventReceived(
    RealtimeEventReceived event,
    Emitter<RealtimeBlocState> emit,
  ) {
    final currentEvents = state is RealtimeConnected
        ? (state as RealtimeConnected).events
        : <RealtimeEvent>[];

    final updatedEvents = [
      event.event,
      ...currentEvents,
    ].take(AppConstants.maxRealtimeEvents).toList();

    emit(RealtimeConnected(events: updatedEvents));
  }

  @override
  Future<void> close() async {
    await _eventSubscription?.cancel();
    await subscribeToEventsUseCase.disconnect();
    return super.close();
  }
}

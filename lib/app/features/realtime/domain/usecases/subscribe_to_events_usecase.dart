import 'package:dartz/dartz.dart';
import '../../../../common/error/failures.dart';
import '../entities/realtime_event.dart';
import '../repositories/realtime_repository.dart';

class SubscribeToEventsUseCase {
  final RealtimeRepository repository;

  SubscribeToEventsUseCase(this.repository);

  Stream<Either<Failure, RealtimeEvent>> call() {
    return repository.subscribeToEvents();
  }

  Future<Either<Failure, void>> disconnect() {
    return repository.disconnect();
  }
}

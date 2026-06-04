import 'package:dartz/dartz.dart';
import '../../../../common/error/failures.dart';
import '../entities/realtime_event.dart';

abstract class RealtimeRepository {
  Stream<Either<Failure, RealtimeEvent>> subscribeToEvents();
  Future<Either<Failure, void>> disconnect();
}

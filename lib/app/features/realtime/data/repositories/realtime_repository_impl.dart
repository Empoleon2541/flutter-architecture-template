import 'package:dartz/dartz.dart';
import '../../../../common/error/failures.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/repositories/realtime_repository.dart';
import '../datasources/mock_websocket_datasource.dart';

class RealtimeRepositoryImpl implements RealtimeRepository {
  final MockWebSocketDataSource dataSource;

  RealtimeRepositoryImpl({required this.dataSource});

  @override
  Stream<Either<Failure, RealtimeEvent>> subscribeToEvents() {
    dataSource.connect();

    return dataSource.eventStream.map<Either<Failure, RealtimeEvent>>(
      (event) => Right(event),
    ).handleError(
      (error) => Left(
        ServerFailure('WebSocket error: $error'),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      dataSource.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to disconnect: $e'));
    }
  }
}

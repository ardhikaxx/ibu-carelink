import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/kick_session_entity.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../datasources/kick_counter_local_data_source.dart';
import '../datasources/kick_counter_remote_data_source.dart';
import '../models/kick_session_model.dart';

class KickCounterRepositoryImpl implements KickCounterRepository {
  final KickCounterRemoteDataSource remoteDataSource;
  final KickCounterLocalDataSource localDataSource;

  KickCounterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, KickSessionEntity>> saveSession(KickSessionEntity session, String userId) async {
    try {
      final model = KickSessionModel(
        id: session.id,
        pregnancyId: session.pregnancyId,
        startTime: session.startTime,
        sessionDurationSeconds: session.sessionDurationSeconds,
        totalKicks: session.totalKicks,
        isCompleted: session.isCompleted,
      );
      final remote = await remoteDataSource.saveSession(model, userId);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KickSessionEntity>>> getSessions(String userId, String pregnancyId) async {
    try {
      final cached = await localDataSource.getCachedSessions(pregnancyId);
      if (cached.isNotEmpty) {
        remoteDataSource.getSessions(userId, pregnancyId).then((remote) {
          localDataSource.cacheSessions(pregnancyId, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getSessions(userId, pregnancyId);
      await localDataSource.cacheSessions(pregnancyId, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

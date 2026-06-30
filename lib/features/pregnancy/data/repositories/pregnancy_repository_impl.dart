import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pregnancy_entity.dart';
import '../../domain/entities/symptom_log_entity.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../datasources/pregnancy_local_data_source.dart';
import '../datasources/pregnancy_remote_data_source.dart';
import '../models/symptom_log_model.dart';

class PregnancyRepositoryImpl implements PregnancyRepository {
  final PregnancyRemoteDataSource remoteDataSource;
  final PregnancyLocalDataSource localDataSource;

  PregnancyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PregnancyEntity?>> getActivePregnancy(String userId) async {
    try {
      final cached = await localDataSource.getCachedActivePregnancy(userId);
      if (cached != null) {
        remoteDataSource.getActivePregnancy(userId).then((remote) {
          if (remote != null) localDataSource.cacheActivePregnancy(remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getActivePregnancy(userId);
      if (remote != null) {
        await localDataSource.cacheActivePregnancy(remote);
      }
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PregnancyEntity>> createPregnancy(String userId, DateTime hpht, double preWeight) async {
    try {
      final remote = await remoteDataSource.createPregnancy(userId, hpht, preWeight);
      await localDataSource.cacheActivePregnancy(remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SymptomLogEntity>> logSymptom(SymptomLogEntity log) async {
    try {
      final model = SymptomLogModel(
        id: log.id,
        pregnancyId: log.pregnancyId,
        date: log.date,
        nauseaLevel: log.nauseaLevel,
        fatigueLevel: log.fatigueLevel,
        moodNote: log.moodNote,
        triggers: log.triggers,
      );
      // Butuh userId untuk path di Firestore. Ambil dari cache pregnancy atau lewat model.
      // Kita kirim ke remoteDataSource
      final active = await localDataSource.getCachedActivePregnancy('');
      final userId = active?.userId ?? 'current_user';
      final remote = await remoteDataSource.logSymptom(model, userId);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SymptomLogEntity>>> getSymptomLogs(String userId, String pregnancyId) async {
    try {
      final cached = await localDataSource.getCachedSymptomLogs(pregnancyId);
      if (cached.isNotEmpty) {
        remoteDataSource.getSymptomLogs(userId, pregnancyId).then((remote) {
          localDataSource.cacheSymptomLogs(pregnancyId, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getSymptomLogs(userId, pregnancyId);
      await localDataSource.cacheSymptomLogs(pregnancyId, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

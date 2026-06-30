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
      final active = await localDataSource.getCachedActivePregnancy('');
      final userId = active?.userId ?? 'current_user';

      try {
        final existing = await localDataSource.getCachedSymptomLogs(log.pregnancyId);
        final updated = [model, ...existing.where((x) => x.id != model.id)];
        await localDataSource.cacheSymptomLogs(log.pregnancyId, updated);
      } catch (_) {}

      try {
        final remote = await remoteDataSource.logSymptom(model, userId);
        return Right(remote);
      } catch (_) {
        return Right(model);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SymptomLogEntity>>> getSymptomLogs(String userId, String pregnancyId) async {
    try {
      final cached = await localDataSource.getCachedSymptomLogs(pregnancyId);
      try {
        final remote = await remoteDataSource.getSymptomLogs(userId, pregnancyId);
        final Map<String, SymptomLogModel> map = {};
        for (final item in remote) {
          map[item.id] = item;
        }
        for (final item in cached) {
          if (!map.containsKey(item.id)) {
            map[item.id] = item;
          }
        }
        final merged = map.values.toList();
        merged.sort((a, b) => b.date.compareTo(a.date));
        await localDataSource.cacheSymptomLogs(pregnancyId, merged);
        return Right(merged);
      } catch (_) {
        return Right(cached);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/growth_log_entity.dart';
import '../../domain/repositories/child_growth_repository.dart';
import '../datasources/child_local_data_source.dart';
import '../datasources/child_remote_data_source.dart';
import '../models/child_model.dart';
import '../models/growth_log_model.dart';

class ChildGrowthRepositoryImpl implements ChildGrowthRepository {
  final ChildRemoteDataSource remoteDataSource;
  final ChildLocalDataSource localDataSource;

  ChildGrowthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<ChildEntity>>> getChildren(String userId) async {
    try {
      final cached = await localDataSource.getCachedChildren(userId);
      if (cached.isNotEmpty) {
        remoteDataSource.getChildren(userId).then((remote) {
          localDataSource.cacheChildren(userId, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getChildren(userId);
      await localDataSource.cacheChildren(userId, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildEntity>> addChild(ChildEntity child, String userId) async {
    try {
      final model = ChildModel(
        id: child.id,
        userId: userId,
        name: child.name,
        gender: child.gender,
        dateOfBirth: child.dateOfBirth,
        birthWeightKg: child.birthWeightKg,
        birthLengthCm: child.birthLengthCm,
        childOrder: child.childOrder,
      );
      final remote = await remoteDataSource.addChild(model, userId);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrowthLogEntity>> logGrowth(GrowthLogEntity log, ChildEntity child, String userId) async {
    try {
      final logModel = GrowthLogModel(
        id: log.id,
        childId: child.id,
        measurementDate: log.measurementDate,
        weightKg: log.weightKg,
        heightCm: log.heightCm,
        headCircumferenceCm: log.headCircumferenceCm,
      );
      final childModel = ChildModel(
        id: child.id,
        userId: userId,
        name: child.name,
        gender: child.gender,
        dateOfBirth: child.dateOfBirth,
        birthWeightKg: child.birthWeightKg,
        birthLengthCm: child.birthLengthCm,
        childOrder: child.childOrder,
      );
      final remote = await remoteDataSource.logGrowth(logModel, childModel, userId);
      try {
        final existing = await localDataSource.getCachedGrowthLogs(child.id);
        final updated = [remote, ...existing.where((x) => x.id != remote.id)];
        await localDataSource.cacheGrowthLogs(child.id, updated);
      } catch (_) {}
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GrowthLogEntity>>> getGrowthLogs(String userId, ChildEntity child) async {
    try {
      final cached = await localDataSource.getCachedGrowthLogs(child.id);
      final childModel = ChildModel(
        id: child.id,
        userId: userId,
        name: child.name,
        gender: child.gender,
        dateOfBirth: child.dateOfBirth,
        birthWeightKg: child.birthWeightKg,
        birthLengthCm: child.birthLengthCm,
        childOrder: child.childOrder,
      );

      if (cached.isNotEmpty) {
        remoteDataSource.getGrowthLogs(userId, childModel).then((remote) {
          localDataSource.cacheGrowthLogs(child.id, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getGrowthLogs(userId, childModel);
      await localDataSource.cacheGrowthLogs(child.id, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

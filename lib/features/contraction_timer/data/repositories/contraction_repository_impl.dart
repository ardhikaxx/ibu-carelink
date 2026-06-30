import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/contraction_entity.dart';
import '../../domain/repositories/contraction_repository.dart';
import '../datasources/contraction_local_data_source.dart';
import '../datasources/contraction_remote_data_source.dart';
import '../models/contraction_model.dart';

class ContractionRepositoryImpl implements ContractionRepository {
  final ContractionRemoteDataSource remoteDataSource;
  final ContractionLocalDataSource localDataSource;

  ContractionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ContractionEntity>> saveContraction(ContractionEntity contraction, String userId) async {
    try {
      final model = ContractionModel(
        id: contraction.id,
        pregnancyId: contraction.pregnancyId,
        startTime: contraction.startTime,
        endTime: contraction.endTime,
        durationSeconds: contraction.durationSeconds,
        intervalSeconds: contraction.intervalSeconds,
        intensityLevel: contraction.intensityLevel,
      );
      final remote = await remoteDataSource.saveContraction(model, userId);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContractionEntity>>> getContractions(String userId, String pregnancyId) async {
    try {
      final cached = await localDataSource.getCachedContractions(pregnancyId);
      if (cached.isNotEmpty) {
        remoteDataSource.getContractions(userId, pregnancyId).then((remote) {
          localDataSource.cacheContractions(pregnancyId, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getContractions(userId, pregnancyId);
      await localDataSource.cacheContractions(pregnancyId, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

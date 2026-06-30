import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/immunization_entity.dart';
import '../../domain/repositories/immunization_repository.dart';
import '../datasources/immunization_local_data_source.dart';
import '../datasources/immunization_remote_data_source.dart';
import '../models/immunization_model.dart';

class ImmunizationRepositoryImpl implements ImmunizationRepository {
  final ImmunizationRemoteDataSource remoteDataSource;
  final ImmunizationLocalDataSource localDataSource;

  ImmunizationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<ImmunizationEntity>>> getImmunizations(String userId, String childId) async {
    try {
      final cached = await localDataSource.getCachedImmunizations(childId);
      if (cached.isNotEmpty) {
        remoteDataSource.getImmunizations(userId, childId).then((remote) {
          localDataSource.cacheImmunizations(childId, remote);
        }).catchError((_) {});
        return Right(cached);
      }
      final remote = await remoteDataSource.getImmunizations(userId, childId);
      await localDataSource.cacheImmunizations(childId, remote);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ImmunizationEntity>> updateImmunizationStatus(ImmunizationEntity immunization, String userId) async {
    try {
      final model = ImmunizationModel(
        id: immunization.id,
        childId: immunization.childId,
        vaccineName: immunization.vaccineName,
        targetAgeMonths: immunization.targetAgeMonths,
        isCompleted: immunization.isCompleted,
        dateAdministered: immunization.dateAdministered,
        batchNumber: immunization.batchNumber,
        clinicName: immunization.clinicName,
      );
      final remote = await remoteDataSource.updateImmunization(model, userId);
      return Right(remote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

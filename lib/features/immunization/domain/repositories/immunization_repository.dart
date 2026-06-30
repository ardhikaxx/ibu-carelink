import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/immunization_entity.dart';

abstract class ImmunizationRepository {
  Future<Either<Failure, List<ImmunizationEntity>>> getImmunizations(String userId, String childId);
  Future<Either<Failure, ImmunizationEntity>> updateImmunizationStatus(ImmunizationEntity immunization, String userId);
}
